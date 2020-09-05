import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/utils/navigation_helper.dart';
import 'package:flutter_chan_viewer/pages/base/base_page.dart';
import 'package:flutter_chan_viewer/pages/thread_detail/thread_detail_page.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/view/list_widget_archive_thread.dart';
import 'package:flutter_chan_viewer/view/list_widget_thread.dart';

import 'bloc/board_archive_bloc.dart';
import 'bloc/board_archive_event.dart';
import 'bloc/board_archive_state.dart';

class BoardArchivePage extends StatefulWidget {
  static const String ARG_BOARD_ID = "ArchiveListPage.ARG_BOARD_ID";

  final String boardId;

  BoardArchivePage(this.boardId);

  @override
  _BoardArchivePageState createState() => _BoardArchivePageState();
}

class _BoardArchivePageState extends BasePageState<BoardArchivePage> {
  BoardArchiveBloc _archiveListBloc;
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _archiveListBloc = BlocProvider.of<BoardArchiveBloc>(context);
    _archiveListBloc.add(ChanEventFetchData());
    _scrollController.addListener(_onScroll);
  }

  @override
  String getPageTitle() => "/${widget.boardId}";

  @override
  List<AppBarAction> getAppBarActions(BuildContext context) => [
        AppBarAction("Search", Icons.search, _onSearchClick),
        AppBarAction("Refresh", Icons.refresh, _onRefreshClick),
      ];

  void _onSearchClick() async {
    ThreadItem thread = await showSearch<ThreadItem>(context: context, delegate: CustomSearchDelegate(_archiveListBloc));
    _archiveListBloc.searchQuery = '';

    if (thread != null) {
      _openThreadDetailPage(thread);
    }
  }

  void _onRefreshClick() => _archiveListBloc.add(ChanEventFetchData());

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    bool isLoading = (_archiveListBloc.state as BoardArchiveStateContent)?.lazyLoading;
    if (!isLoading && _archiveListBloc.isMoreThreadsAvailable() && maxScroll - currentScroll <= _scrollThreshold) {
      _archiveListBloc.add(BoardArchiveEventFetchDetailsLazy());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardArchiveBloc, ChanState>(
        cubit: _archiveListBloc,
        builder: (context, state) => buildScaffold(
              context,
              buildBody(context, state, _scrollController, ((thread) => _openThreadDetailPage(thread))),
            ));
  }

  static Widget buildBody(BuildContext context, ChanState state, ScrollController scrollController, Function(ThreadItem) onItemClicked) {
    if (state is ChanStateLoading) {
      return Constants.centeredProgressIndicator;
    } else if (state is BoardArchiveStateContent) {
      if (state.threads.isEmpty) {
        return Constants.noDataPlaceholder;
      }

      return Scrollbar(
        child: ListView.builder(
          controller: scrollController,
          itemCount: state.threads.length,
          itemBuilder: (context, index) {
            ThreadItem thread = state.threads[index].threadDetailModel.thread;
            if (state.threads[index].isLoading) {
              return ArchiveThreadListWidget(
                thread: thread,
                isLoading: state.threads[index].isLoading,
              );
            } else {
              return InkWell(
                child: ThreadListWidget(
                  thread: thread,
                  showProgress: false,
                ),
                onTap: () => onItemClicked(thread),
              );
            }
          },
        ),
      );
    } else {
      return BasePageState.buildErrorScreen(context, (state as ChanStateError)?.message);
    }
  }

  void _openThreadDetailPage(ThreadItem thread) {
    Navigator.of(context).push(
      NavigationHelper.getRoute(
        Constants.threadDetailRoute,
        ThreadDetailPage.createArguments(thread.boardId, thread.threadId),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<ThreadItem> {
  CustomSearchDelegate(this._boardDetailBloc);

  final BoardArchiveBloc _boardDetailBloc;

  @override
  ThemeData appBarTheme(BuildContext context) => Constants.searchBarTheme(context);

  @override
  List<Widget> buildActions(BuildContext context) => null;

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        _boardDetailBloc.add(ChanEventSearch(query));
        close(context, null);
      });

  @override
  Widget buildResults(BuildContext context) {
    _boardDetailBloc.add(ChanEventSearch(query));

    return BlocBuilder<BoardArchiveBloc, ChanState>(
      cubit: _boardDetailBloc,
      builder: (context, state) => _BoardArchivePageState.buildBody(context, state, null, ((thread) => close(context, thread))),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _boardDetailBloc.add(ChanEventSearch(query));

    return BlocBuilder<BoardArchiveBloc, ChanState>(
      cubit: _boardDetailBloc,
      builder: (context, state) => _BoardArchivePageState.buildBody(context, state, null, ((thread) => close(context, thread))),
    );
  }
}