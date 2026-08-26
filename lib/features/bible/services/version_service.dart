import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// A Bible translation the app knows about. KJV ships bundled in assets;
/// the rest are public-domain translations downloadable from getbible.net
/// and stored locally so they keep working fully offline.
class BibleVersion {
  final String abbrev;
  final String name;
  final String copyright;
  final bool bundled;

  const BibleVersion({
    required this.abbrev,
    required this.name,
    required this.copyright,
    this.bundled = false,
  });
}

class VersionService {
  static const String _downloadBaseUrl = 'https://api.getbible.net/v2';

  static const List<BibleVersion> catalog = [
    BibleVersion(
      abbrev: 'kjv',
      name: 'King James Version',
      copyright:
          'Text from the CrossWire Bible Society KJV2003 project, offered '
          'freely for any purpose. Rights in the Authorized (King James) '
          'Version in the United Kingdom are vested in the Crown.',
      bundled: true,
    ),
    BibleVersion(
      abbrev: 'web',
      name: 'World English Bible',
      copyright: 'Public domain.',
    ),
    BibleVersion(
      abbrev: 'asv',
      name: 'American Standard Version',
      copyright: 'Public domain.',
    ),
    BibleVersion(
      abbrev: 'akjv',
      name: 'American King James Version',
      copyright: 'Public domain.',
    ),
    BibleVersion(
      abbrev: 'basicenglish',
      name: 'Bible in Basic English',
      copyright: 'Public domain.',
    ),
    BibleVersion(
      abbrev: 'ylt',
      name: 'Young\'s Literal Translation',
      copyright: 'Public domain.',
    ),
    // Note: getbible.net's 'darby' slug is the FRENCH Darby (lang=fr). It was
    // listed here as an English translation, and because its book names are
    // French ("Genèse", "Apocalypse") 56 of 66 books resolved to nothing.
    // There is no English Darby on this API. Webster's Bible is the
    // replacement: verified 66 books, all names matching booktitle.json.
    BibleVersion(
      abbrev: 'wb',
      name: "Webster's Bible",
      copyright: 'Public domain.',
    ),
  ];

  static BibleVersion byAbbrev(String abbrev) {
    return catalog.firstWhere(
      (v) => v.abbrev == abbrev,
      orElse: () => catalog.first,
    );
  }

  static Future<Directory> _biblesDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/bibles');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> versionFile(String abbrev) async {
    final dir = await _biblesDir();
    return File('${dir.path}/$abbrev.json');
  }

  static Future<bool> isAvailable(String abbrev) async {
    if (byAbbrev(abbrev).bundled) return true;
    return (await versionFile(abbrev)).exists();
  }

  /// Partial download left behind by a crash or a full disk. Never a valid
  /// translation, and never visible to [downloadedAbbrevs].
  static Future<File> _partialFile(String abbrev) async {
    final dir = await _biblesDir();
    return File('${dir.path}/$abbrev.json.part');
  }

  static Future<List<String>> downloadedAbbrevs() async {
    final dir = await _biblesDir();
    final files = await dir.list().toList();
    return files
        .whereType<File>()
        .where((f) => f.path.endsWith('.json')) // .json.part is excluded
        .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''))
        .toList();
  }

  /// Published SHA-1 of each upstream translation file, fetched once per
  /// download so a corrupted or truncated transfer is caught before it is
  /// written rather than surfacing later as an unparseable Bible.
  static Future<String?> _publishedChecksum(String abbrev) async {
    try {
      final response = await http
          .get(Uri.parse('$_downloadBaseUrl/checksum.json'))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;
      final map = json.decode(response.body) as Map<String, dynamic>;
      return map[abbrev]?.toString();
    } catch (_) {
      // Integrity checking is best-effort: if the checksum index is
      // unreachable we still allow the download, we just cannot verify it.
      return null;
    }
  }

  /// Downloads a translation and stores it in the app's local format (the same
  /// flat verse list shape as the bundled kjv.json asset).
  ///
  /// [onProgress] receives 0.0-1.0 when the server reports a content length,
  /// and -1 while the size is unknown. These files are 8-9MB, so a download
  /// with no feedback looks indistinguishable from a hang.
  static Future<void> download(
    String abbrev, {
    void Function(double progress)? onProgress,
  }) async {
    final expectedSha1 = await _publishedChecksum(abbrev);

    final client = http.Client();
    final Uint8List bytes;
    try {
      final request =
          http.Request('GET', Uri.parse('$_downloadBaseUrl/$abbrev.json'));
      final response =
          await client.send(request).timeout(const Duration(minutes: 3));
      if (response.statusCode != 200) {
        throw Exception('Download failed (HTTP ${response.statusCode})');
      }

      final total = response.contentLength ?? 0;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response.stream) {
        builder.add(chunk);
        onProgress?.call(total > 0 ? builder.length / total : -1);
      }
      bytes = builder.takeBytes();
    } finally {
      client.close();
    }

    if (expectedSha1 != null) {
      final actual = sha1.convert(bytes).toString();
      if (actual != expectedSha1) {
        throw Exception(
            'Downloaded file failed its integrity check. Please try again.');
      }
    }

    final normalized =
        await Isolate.run(() => normalizeGetBibleJson(utf8.decode(bytes)));

    // Reject a translation the app cannot actually display. Book lookup is by
    // name, so a text using different names (a non-English edition, or a
    // different canon) would install cleanly and then render empty chapters.
    final expected = await _expectedBookNames();
    final present = _bookNamesIn(normalized);
    final missing = expected.difference(present);
    if (missing.length > 3) {
      throw Exception(
          'This translation is missing ${missing.length} of ${expected.length} '
          'books and cannot be displayed.');
    }

    // Write to a scratch path and rename into place. A rename within one
    // directory is atomic, so an interrupted download can never leave a
    // truncated file that `isAvailable` would report as a usable translation.
    final partial = await _partialFile(abbrev);
    final target = await versionFile(abbrev);
    try {
      await partial.writeAsString(normalized, flush: true);
      await partial.rename(target.path);
    } catch (e) {
      if (await partial.exists()) {
        await partial.delete();
      }
      rethrow;
    }
  }

  /// On-disk size of a downloaded translation, for the manage-versions list.
  /// Book names the app can render, from the bundled index.
  static Future<Set<String>> _expectedBookNames() async {
    final raw = await rootBundle.loadString('assets/booktitle.json');
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => (e as Map<String, dynamic>)['key'].toString())
        .toSet();
  }

  /// Book names present in a normalized flat verse list.
  static Set<String> _bookNamesIn(String normalizedJson) {
    final list = json.decode(normalizedJson) as List<dynamic>;
    return list
        .map((e) => (e as Map<String, dynamic>)['book_name'].toString())
        .toSet();
  }

  static Future<int> sizeOnDisk(String abbrev) async {
    final file = await versionFile(abbrev);
    if (!await file.exists()) return 0;
    return file.length();
  }

  static Future<void> delete(String abbrev) async {
    final file = await versionFile(abbrev);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Converts getbible.net's nested books/chapters/verses JSON into the
  /// app's flat verse list format, aligning book names with the bundled data.
  static String normalizeGetBibleJson(String rawJson) {
    const bookNameFixes = {
      'Song of Songs': 'Song of Solomon',
    };

    final data = json.decode(rawJson) as Map<String, dynamic>;
    final books = data['books'] as List<dynamic>;
    final flat = <Map<String, dynamic>>[];

    for (final book in books) {
      final bookMap = book as Map<String, dynamic>;
      final rawName = (bookMap['name'] as String).trim();
      final bookName = bookNameFixes[rawName] ?? rawName;
      final bookId = 'b${bookMap['nr']}';

      for (final chapter in bookMap['chapters'] as List<dynamic>) {
        final chapterMap = chapter as Map<String, dynamic>;
        for (final verse in chapterMap['verses'] as List<dynamic>) {
          final verseMap = verse as Map<String, dynamic>;
          flat.add({
            'book_id': bookId,
            'book_name': bookName,
            'chapter': verseMap['chapter'],
            'verse': verseMap['verse'],
            'text': (verseMap['text'] as String).trim(),
          });
        }
      }
    }

    return json.encode(flat);
  }
}
