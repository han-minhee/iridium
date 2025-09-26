import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

/// Floating panel showing contextual actions (translate, info, TTS) for the current
/// selection or page. Consumers provide callbacks for actions.
class FloatingReaderPanel extends StatelessWidget {
  final ReaderContext readerContext;
  final ValueNotifier<Selection?> selectionNotifier;
  final VoidCallback? onTranslate;
  final VoidCallback? onExtraInfo;
  final VoidCallback? onTts;

  const FloatingReaderPanel({
    super.key,
    required this.readerContext,
    required this.selectionNotifier,
    this.onTranslate,
    this.onExtraInfo,
    this.onTts,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Selection?>(
        valueListenable: selectionNotifier,
        builder: (context, selection, _) {
          final isVisible = selection != null || _hasActivePage(readerContext);
          if (!isVisible) return const SizedBox.shrink();
          final String snippet = selection?.locator.text.highlight ?? '';
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Material(
              elevation: 6,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: Theme.of(context).colorScheme.surface,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (snippet.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Icon(Icons.text_snippet,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ),
                    if (snippet.isNotEmpty)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            snippet,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    _buildIcon(context, Icons.translate, 'Translate', onTranslate),
                    _buildIcon(context, Icons.info_outline, 'Info', onExtraInfo),
                    _buildIcon(context, Icons.volume_up, 'Read aloud', onTts),
                  ],
                ),
              ),
            ),
          );
        },
      );

  bool _hasActivePage(ReaderContext ctx) => ctx.paginationInfo != null;

  Widget _buildIcon(
          BuildContext context, IconData icon, String tooltip, VoidCallback? cb) =>
      IconButton(
        tooltip: tooltip,
        onPressed: cb,
        icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      );
}



