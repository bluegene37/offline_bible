import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_controller.dart';
import '../models/book_model.dart';
import '../services/bible_service.dart';
import '../services/cross_reference_service.dart';

/// Cross-references for a single verse, with the referenced text inline so the
/// reader can weigh a passage without losing their place.
class CrossReferenceSheet extends StatelessWidget {
  final String verseKey;

  const CrossReferenceSheet({super.key, required this.verseKey});

  static void show(BuildContext context, String verseKey) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CrossReferenceSheet(verseKey: verseKey),
    );
  }

  String get _reference {
    final parts = verseKey.split(':');
    if (parts.length < 3) return verseKey;
    final book = parts.sublist(0, parts.length - 2).join(':');
    return '$book ${parts[parts.length - 2]}:${parts.last}';
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cross-references',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _reference,
                          style: TextStyle(
                            fontSize: 13,
                            color: appController.activeThemeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildList(context, appController)),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildList(BuildContext context, AppController appController) {
    return FutureBuilder<List<CrossReference>>(
      future: CrossReferenceService.forVerse(verseKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final refs = snapshot.data ?? const <CrossReference>[];
        if (refs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No cross-references for this verse.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: refs.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 20),
          itemBuilder: (context, index) {
            if (index == refs.length) return _buildAttribution(context);
            return _buildTile(context, refs[index], appController);
          },
        );
      },
    );
  }

  Widget _buildTile(
      BuildContext context, CrossReference ref, AppController appController) {
    return ListTile(
      title: Text(
        ref.label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: appController.activeThemeColor,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          _textFor(ref),
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            fontFamily: appController.globalFont.value,
          ),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        Navigator.pop(context);
        appController.navigateToVerse(ref.book, ref.chapter, ref.startVerse);
      },
    );
  }

  /// Reads the referenced verses out of the active translation, so the panel
  /// follows whichever version the reader is using.
  String _textFor(CrossReference ref) {
    final buffer = StringBuffer();
    for (var v = ref.startVerse; v <= ref.endVerse; v++) {
      final Book? verse = BibleService.verseOrNull(ref.book, ref.chapter, v);
      if (verse == null) continue;
      if (buffer.isNotEmpty) buffer.write(' ');
      if (ref.isRange) buffer.write('[$v] ');
      buffer.write(verse.text);
    }
    return buffer.isEmpty
        ? 'Not available in this translation.'
        : buffer.toString();
  }

  Widget _buildAttribution(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Text(
        'Cross-reference data from openbible.info, used under CC BY.',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
    );
  }
}
