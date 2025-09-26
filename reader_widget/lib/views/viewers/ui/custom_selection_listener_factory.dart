import 'package:flutter/widgets.dart' hide SelectionListener;
import 'package:iridium_reader_widget/views/viewers/ui/custom_selection_listener.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/src/publication/reader_context.dart';

class CustomSelectionListenerFactory extends SelectionListenerFactory {
  final State state;
  final ValueNotifier<Selection?> selectionNotifier;

  CustomSelectionListenerFactory(this.state, this.selectionNotifier);

  @override
  SelectionListener create(ReaderContext readerContext, BuildContext context) =>
      CustomSelectionListener(state, readerContext, context, selectionNotifier);
}



