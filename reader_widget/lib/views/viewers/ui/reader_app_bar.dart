// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iridium_reader_widget/views/viewers/ui/reader_navigation_screen.dart';
import 'package:iridium_reader_widget/views/viewers/ui/settings/settings_panel.dart';
import 'package:iridium_reader_widget/util/router.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class ReaderAppBar extends StatefulWidget {
  final ReaderContext readerContext;
  final PublicationController publicationController;

  const ReaderAppBar({
    super.key,
    required this.readerContext,
    required this.publicationController,
  });

  @override
  State<StatefulWidget> createState() => ReaderAppBarState();
}

class ReaderAppBarState extends State<ReaderAppBar> {
  static const double height = kToolbarHeight;
  final GlobalKey _settingsKey = GlobalKey();
  late StreamSubscription<bool> _streamSubscription;
  double opacity = 0.0;

  ReaderContext get readerContext => widget.readerContext;

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.readerContext.toolbarStream.listen((visible) {
      setState(() {
        opacity = (visible) ? 1.0 : 0.0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: IgnorePointer(
          ignoring: opacity < 1.0,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              height: height,
              child: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                actions: [
                  IconButton(
                    onPressed: _onSearchPressed,
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: _onBookmarkPressed,
                    icon: const ImageIcon(
                      AssetImage(
                        'packages/iridium_reader_widget/assets/images/icon_bookmark.png',
                      ),
                    ),
                  ),
                  IconButton(
                    key: _settingsKey,
                    onPressed: _onSettingsPressed,
                    icon: const ImageIcon(
                      AssetImage(
                        'packages/iridium_reader_widget/assets/images/icon_settings.png',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onMenuPressed,
                    icon: const ImageIcon(
                      AssetImage(
                        'packages/iridium_reader_widget/assets/images/icon_menu.png',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _onBookmarkPressed() {
    readerContext.toggleBookmark();
  }

  void _onSettingsPressed() {
    ViewerSettingsBloc viewerSettingsBloc =
        BlocProvider.of<ViewerSettingsBloc>(context);
    ReaderThemeBloc readerThemeBloc = BlocProvider.of<ReaderThemeBloc>(context);
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              RenderBox? renderButton =
                  _settingsKey.currentContext?.findRenderObject() as RenderBox?;
              Offset? position = renderButton
                  ?.localToGlobal(renderButton.size.bottomCenter(Offset.zero));
              return SafeArea(
                child: Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.pop(context),
                    ),
                    Positioned(
                      top: (position?.dy ?? 0.0) -
                          MediaQuery.of(context).padding.top,
                      right: 0,
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      child: SettingsPanel(
                        readerContext: readerContext,
                        viewerSettingsBloc: viewerSettingsBloc,
                        readerThemeBloc: readerThemeBloc,
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  void _onMenuPressed() {
    MyRouter.pushPage(
        context, ReaderNavigationScreen(readerContext: readerContext));
  }

  void _onSearchPressed() async {
    final query = await showSearch<String>(
      context: context,
      delegate: _InBookSearchDelegate(),
    );
    if (query != null && query.trim().isNotEmpty) {
      final link = readerContext.currentSpineItem;
      if (link == null) return;
      final locator = Locator(
        href: link.href,
        type: link.type ?? 'application/xhtml+xml',
        title: link.title,
        locations: Locations(),
        text: LocatorText(highlight: query.trim()),
      );
      readerContext.execute(GoToLocationCommand.locator(locator));
    }
  }
}

class _InBookSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, '');
            } else {
              query = '';
              showSuggestions(context);
            }
          },
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(16),
      child: Text(
        'Search in current chapter',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
