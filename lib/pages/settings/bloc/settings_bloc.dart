import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/data/local/local_data_source.dart';
import 'package:flutter_chan_viewer/locator.dart';
import 'package:flutter_chan_viewer/models/helper/moor_db_overview.dart';
import 'package:flutter_chan_viewer/models/local/threads_table.dart';
import 'package:flutter_chan_viewer/models/ui/board_item.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';
import 'package:flutter_chan_viewer/repositories/chan_downloader.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/chan_logger.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';
import 'package:flutter_chan_viewer/utils/preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<ChanEvent, ChanState> {
  final ChanDownloader _downloader = getIt<ChanDownloader>();
  final ChanStorage _chanStorage = getIt<ChanStorage>();
  final LocalDataSource _localDataSource = getIt<LocalDataSource>();

  AppTheme _appTheme;
  List<DownloadFolderInfo> _downloads = List();
  MoorDbOverview _dbOverview = MoorDbOverview();
  bool _showSfwOnly;

  SettingsBloc() : super(ChanStateLoading());

  get showNsfw => !_showSfwOnly;

  get _contentState => SettingsStateContent(_appTheme, _downloads, showNsfw, _dbOverview);

  @override
  Stream<ChanState> mapEventToState(ChanEvent event) async* {
    try {
      if (event is SettingsEventSetTheme) {
        Preferences.setInt(Preferences.KEY_SETTINGS_THEME, event.theme.index);
        _appTheme = event.theme;
        yield _contentState;
      } else if (event is ChanEventFetchData) {
        int appThemeIndex = Preferences.getInt(Preferences.KEY_SETTINGS_THEME) ?? 0;
        _appTheme = AppTheme.values[appThemeIndex];
        _downloads = _chanStorage.getAllDownloadFoldersInfo();
        _showSfwOnly = Preferences.getBool(Preferences.KEY_SETTINGS_SHOW_SFW_ONLY, def: true);

        yield _contentState;
      } else if (event is SettingsEventExperiment) {
        yield ChanStateLoading();
        _dbOverview.boards.clear();
        List<BoardItem> boards = await _localDataSource.getBoards(true);
        for (BoardItem board in boards) {
          List<ThreadItem> threads = await _localDataSource.getThreadsByBoardId(board.boardId);
          if (threads.isEmpty) {
            continue;
          }

          MoorBoardOverview boardsOverview = new MoorBoardOverview(
            board.boardId,
            threads.where((thread) => thread.onlineStatus == OnlineState.ONLINE).length,
            threads.where((thread) => thread.onlineStatus == OnlineState.ARCHIVED).length,
            threads.where((thread) => thread.onlineStatus == OnlineState.NOT_FOUND).length,
            threads.where((thread) => thread.onlineStatus == OnlineState.UNKNOWN).length,
          );
          _dbOverview.boards.add(boardsOverview);
        }

        yield _contentState;
      } else if (event is SettingsEventToggleShowSfwOnly) {
        yield ChanStateLoading();
        _showSfwOnly = !event.showNsfw;
        Preferences.setBool(Preferences.KEY_SETTINGS_SHOW_SFW_ONLY, _showSfwOnly);
        yield _contentState;
      } else if (event is SettingsEventCancelDownloads) {
        yield ChanStateLoading();
        _downloader.cancelAllDownloads();
        yield _contentState;
      } else if (event is SettingsEventDeleteFolder) {
        yield ChanStateLoading();
        _chanStorage.deleteMediaDirectory(event.cacheDirective);
        _downloads = _chanStorage.getAllDownloadFoldersInfo();
        yield _contentState;
      }
    } catch (e, stackTrace) {
      ChanLogger.e("Event error!", e, stackTrace);
      yield ChanStateError(e.toString());
    }
  }
}
