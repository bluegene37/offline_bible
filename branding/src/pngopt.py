#!/usr/bin/env python3
"""Re-encode a PNG with adaptive filtering, max deflate, and no metadata.

CoreGraphics writes correct but bulky PNGs (it dithers gradients and emits an
eXIf chunk). These are build-time art sources that land in git, so it is worth
squeezing them properly. Drops the alpha channel when the image is fully opaque.
"""
import struct, zlib, sys

def decode(path):
    d = open(path, 'rb').read()
    assert d[:8] == b'\x89PNG\r\n\x1a\n', 'not a png'
    i, idat = 8, b''
    while i < len(d):
        ln = struct.unpack('>I', d[i:i+4])[0]
        typ = d[i+4:i+8]
        if typ == b'IHDR':
            w, h, bd, ct, cm, fm, il = struct.unpack('>IIBBBBB', d[i+8:i+8+13])
            assert bd == 8 and ct == 6 and il == 0, 'expect 8-bit RGBA, non-interlaced'
        elif typ == b'IDAT':
            idat += d[i+8:i+8+ln]
        i += 12 + ln
    raw = zlib.decompress(idat)
    stride, bpp = w * 4, 4
    out = bytearray(stride * h)
    prev = bytearray(stride)
    pos = 0
    for y in range(h):
        f = raw[pos]; pos += 1
        line = bytearray(raw[pos:pos+stride]); pos += stride
        if f == 1:
            for x in range(bpp, stride): line[x] = (line[x] + line[x-bpp]) & 255
        elif f == 2:
            for x in range(stride): line[x] = (line[x] + prev[x]) & 255
        elif f == 3:
            for x in range(stride):
                a = line[x-bpp] if x >= bpp else 0
                line[x] = (line[x] + ((a + prev[x]) >> 1)) & 255
        elif f == 4:
            for x in range(stride):
                a = line[x-bpp] if x >= bpp else 0
                b = prev[x]; c = prev[x-bpp] if x >= bpp else 0
                p = a + b - c
                pa, pb, pc = abs(p-a), abs(p-b), abs(p-c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        out[y*stride:(y+1)*stride] = line
        prev = line
    return w, h, out

def encode(w, h, rgba, path):
    opaque = all(rgba[i] == 255 for i in range(3, len(rgba), 4))
    if opaque:
        bpp, ct = 3, 2
        px = bytearray(w * h * 3)
        for i in range(w * h):
            px[i*3:i*3+3] = rgba[i*4:i*4+3]
    else:
        bpp, ct = 4, 6
        px = rgba
    stride = w * bpp
    lines = []
    prev = bytearray(stride)
    for y in range(h):
        cur = px[y*stride:(y+1)*stride]
        best, bestf = None, 0
        for f in range(5):
            if f == 0:
                cand = bytes(cur)
            elif f == 1:
                cand = bytes((cur[x] - (cur[x-bpp] if x >= bpp else 0)) & 255 for x in range(stride))
            elif f == 2:
                cand = bytes((cur[x] - prev[x]) & 255 for x in range(stride))
            elif f == 3:
                cand = bytes((cur[x] - (((cur[x-bpp] if x >= bpp else 0) + prev[x]) >> 1)) & 255 for x in range(stride))
            else:
                cand = bytearray(stride)
                for x in range(stride):
                    a = cur[x-bpp] if x >= bpp else 0
                    b = prev[x]; c = prev[x-bpp] if x >= bpp else 0
                    p = a + b - c
                    pa, pb, pc = abs(p-a), abs(p-b), abs(p-c)
                    pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                    cand[x] = (cur[x] - pr) & 255
                cand = bytes(cand)
            # minimum sum of absolute differences heuristic
            score = sum(min(v, 256 - v) for v in cand)
            if best is None or score < best[0]:
                best, bestf = (score, cand), f
        lines.append(bytes([bestf]) + best[1])
        prev = cur
    body = zlib.compress(b''.join(lines), 9)

    def chunk(t, data):
        return struct.pack('>I', len(data)) + t + data + struct.pack('>I', zlib.crc32(t + data) & 0xffffffff)

    with open(path, 'wb') as fh:
        fh.write(b'\x89PNG\r\n\x1a\n')
        fh.write(chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, ct, 0, 0, 0)))
        fh.write(chunk(b'IDAT', body))
        fh.write(chunk(b'IEND', b''))

if __name__ == '__main__':
    for p in sys.argv[1:]:
        import os
        before = os.path.getsize(p)
        w, h, rgba = decode(p)
        encode(w, h, rgba, p)
        after = os.path.getsize(p)
        print(f'{p}: {before//1024}K -> {after//1024}K')
