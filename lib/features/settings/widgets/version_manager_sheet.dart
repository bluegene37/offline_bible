import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../bible/services/version_service.dart';

/// Bottom sheet for choosing the active Bible translation and managing
/// downloads. Every listed translation is public domain (or bundled KJV);
/// once downloaded it works fully offline.
class VersionManagerSheet extends StatefulWidget {
  const VersionManagerSheet({super.key});

  @override
  State<VersionManagerSheet> createState() => _VersionManagerSheetState();
}

class _VersionManagerSheetState extends State<VersionManagerSheet> {
  final AppController _appController = Get.find<AppController>();
  Set<String> _downloaded = {};
  final Set<String> _downloading = {};
  /// abbrev -> 0.0-1.0, or -1 when the server sent no content length.
  final Map<String, double> _progress = {};
  Map<String, int> _sizes = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshDownloaded();
  }

  Future<void> _refreshDownloaded() async {
    final abbrevs = await VersionService.downloadedAbbrevs();
    final sizes = <String, int>{};
    for (final abbrev in abbrevs) {
      sizes[abbrev] = await VersionService.sizeOnDisk(abbrev);
    }
    if (!mounted) return;
    setState(() {
      _downloaded = abbrevs.toSet();
      _sizes = sizes;
      _loading = false;
    });
  }

  static String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Bible Versions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _appController.activeThemeColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Downloaded versions work fully offline.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: VersionService.catalog
                      .map((version) => _buildVersionTile(version))
                      .toList(),
                ),
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionTile(BibleVersion version) {
    return Obx(() {
      final isActive = _appController.bibleVersion.value == version.abbrev;
      final isAvailable =
          version.bundled || _downloaded.contains(version.abbrev);
      final isDownloading = _downloading.contains(version.abbrev);

      return ListTile(
        leading: Icon(
          isActive ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isActive ? _appController.activeThemeColor : null,
        ),
        title: Text(version.name),
        subtitle: Text(
          _subtitleFor(version, isAvailable, isDownloading),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: _buildTrailing(version, isAvailable, isDownloading, isActive),
        onTap: isDownloading
            ? null
            : () => isAvailable
                ? _selectVersion(version.abbrev)
                : _downloadVersion(version.abbrev),
      );
    });
  }

  String _subtitleFor(
      BibleVersion version, bool isAvailable, bool isDownloading) {
    final code = version.abbrev.toUpperCase();
    if (isDownloading) {
      final value = _progress[version.abbrev] ?? -1;
      return value >= 0
          ? '$code • Downloading ${(value * 100).round()}%'
          : '$code • Downloading…';
    }
    if (version.bundled) return '$code • Included';
    if (isAvailable) {
      final size = _formatSize(_sizes[version.abbrev] ?? 0);
      return size.isEmpty
          ? '$code • Downloaded'
          : '$code • Downloaded ($size)';
    }
    return '$code • Tap to download (about 9 MB)';
  }

  Widget? _buildTrailing(BibleVersion version, bool isAvailable,
      bool isDownloading, bool isActive) {
    if (isDownloading) {
      final value = _progress[version.abbrev] ?? -1;
      return SizedBox(
        width: 22,
        height: 22,
        // Determinate once the server reports a size, so an 9MB download over
        // a slow connection reads as progress rather than as a hang.
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          value: value >= 0 ? value : null,
        ),
      );
    }
    if (!isAvailable) {
      return Icon(Icons.download_rounded,
          color: _appController.activeThemeColor);
    }
    if (!version.bundled && !isActive) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Remove download',
        onPressed: () => _deleteVersion(version.abbrev),
      );
    }
    return null;
  }

  Future<void> _selectVersion(String abbrev) async {
    await _appController.changeBibleVersion(abbrev);
    if (mounted) Get.back();
  }

  Future<void> _downloadVersion(String abbrev) async {
    setState(() {
      _downloading.add(abbrev);
      _progress[abbrev] = -1;
    });
    try {
      await VersionService.download(
        abbrev,
        onProgress: (value) {
          if (!mounted) return;
          // Only repaint on whole-percent changes; the stream fires per chunk.
          final previous = _progress[abbrev] ?? -1;
          if (value < 0 || (value - previous).abs() >= 0.01 || value >= 1.0) {
            setState(() => _progress[abbrev] = value);
          }
        },
      );
      await _refreshDownloaded();
      Get.snackbar('Downloaded',
          '${VersionService.byAbbrev(abbrev).name} is ready to use offline');
    } catch (e) {
      final failedIntegrity = e.toString().contains('integrity');
      Get.snackbar(
        'Download failed',
        failedIntegrity
            ? 'The file arrived damaged and was discarded. Please try again.'
            : 'Check your internet connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloading.remove(abbrev);
          _progress.remove(abbrev);
        });
      }
    }
  }

  Future<void> _deleteVersion(String abbrev) async {
    await VersionService.delete(abbrev);
    await _refreshDownloaded();
  }
}
