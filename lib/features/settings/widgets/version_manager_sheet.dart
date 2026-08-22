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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshDownloaded();
  }

  Future<void> _refreshDownloaded() async {
    final abbrevs = await VersionService.downloadedAbbrevs();
    if (!mounted) return;
    setState(() {
      _downloaded = abbrevs.toSet();
      _loading = false;
    });
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
          version.bundled
              ? '${version.abbrev.toUpperCase()} • Included'
              : isAvailable
                  ? '${version.abbrev.toUpperCase()} • Downloaded'
                  : '${version.abbrev.toUpperCase()} • Tap to download',
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

  Widget? _buildTrailing(BibleVersion version, bool isAvailable,
      bool isDownloading, bool isActive) {
    if (isDownloading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
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
    setState(() => _downloading.add(abbrev));
    try {
      await VersionService.download(abbrev);
      await _refreshDownloaded();
      Get.snackbar('Downloaded',
          '${VersionService.byAbbrev(abbrev).name} is ready to use offline');
    } catch (e) {
      Get.snackbar('Download failed',
          'Check your internet connection and try again.');
    } finally {
      if (mounted) setState(() => _downloading.remove(abbrev));
    }
  }

  Future<void> _deleteVersion(String abbrev) async {
    await VersionService.delete(abbrev);
    await _refreshDownloaded();
  }
}
