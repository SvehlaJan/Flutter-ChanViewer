import 'package:equatable/equatable.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';
import 'package:flutter_chan_viewer/models/thread_detail_model.dart';

class BoardArchiveStateContent extends ChanStateContent {
  final List<ArchiveThreadWrapper> threads;

  const BoardArchiveStateContent({
    required showSearchBar,
    required showLazyLoading,
    required event,
    required this.threads,
  }) : super(
          showSearchBar: showSearchBar,
          showLazyLoading: showLazyLoading,
          event: event,
        );

  @override
  List<Object?> get props => super.props..addAll([threads]);
}

class ArchiveThreadWrapper extends Equatable {
  final ThreadDetailModel threadDetailModel;
  final bool isLoading;

  ArchiveThreadWrapper(this.threadDetailModel, this.isLoading);

  @override
  List<Object> get props => [threadDetailModel, isLoading];
}
