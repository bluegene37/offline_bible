import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

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
          'Rights in the Authorized (King James) Version in the United Kingdom '
          'are vested in the Crown. Published by permission of the Crown\'s '
          'patentee, Cambridge University Press',
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
    BibleVersion(
      abbrev: 'darby',
      name: 'Darby Translation',
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

  static Future<List<String>> downloadedAbbrevs() async {
    final dir = await _biblesDir();
    final files = await dir.list().toList();
    return files
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''))
        .toList();
  }

  /// Downloads a translation and stores it in the app's local format
  /// (the same flat verse list shape as the bundled kjv.json asset).
  static Future<void> download(String abbrev) async {
    final response = await http
        .get(Uri.parse('$_downloadBaseUrl/$abbrev.json'))
        .timeout(const Duration(minutes: 3));
    if (response.statusCode != 200) {
      throw Exception('Download failed (HTTP ${response.statusCode})');
    }

    final normalized = await Isolate.run(
        () => normalizeGetBibleJson(utf8.decode(response.bodyBytes)));

    final file = await versionFile(abbrev);
    await file.writeAsString(normalized);
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
