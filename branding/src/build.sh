#!/usr/bin/env bash
# Regenerate every icon source in ../ from the vector geometry, then squeeze
# the PNGs. Run this instead of editing the PNGs by hand.
#
#   ./branding/src/build.sh
#
# Afterwards, push the results into the platform folders with:
#   dart run flutter_launcher_icons
#   dart run flutter_native_splash:create
set -euo pipefail
cd "$(dirname "$0")"
out="$(cd .. && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
swiftc -O Geometry.swift Render.swift export.swift main.swift -o "$tmp/generate"
"$tmp/generate" "$out"
python3 pngopt.py "$out"/*.png
echo "done -> $out"
