import 'package:flutter/material.dart' hide SelectionListener;
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/selection/simple_selection_listener.dart';

/// Notifies listeners about selection events while preserving existing popups.
class CustomSelectionListener extends SimpleSelectionListener {
  final ValueNotifier<Selection?> selectionNotifier;

  CustomSelectionListener(
    State state,
    ReaderContext readerContext,
    BuildContext context,
    this.selectionNotifier,
  ) : super(state, readerContext, context);

  void _notify(Selection selection) {
    selectionNotifier.value = selection;
  }

  @override
  void displayPopup(Selection selection) {
    _notify(selection);
    super.displayPopup(selection);
  }

  @override
  void showHighlightPopup(Selection selection, HighlightStyle style, Color tint,
      {String? highlightId}) {
    _notify(selection);
    super.showHighlightPopup(selection, style, tint, highlightId: highlightId);
  }

  @override
  void showAnnotationPopup(Selection selection,
      {HighlightStyle? style, Color? tint, String? highlightId}) {
    _notify(selection);
    super.showAnnotationPopup(selection,
        style: style, tint: tint, highlightId: highlightId);
  }

  @override
  void hidePopup() {
    selectionNotifier.value = null;
    super.hidePopup();
  }
}



