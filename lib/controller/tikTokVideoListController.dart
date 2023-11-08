import 'dart:async';
import 'dart:math';

import 'package:flutter_tiktok/mock/video.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

typedef LoadMoreVideo = Future<List<VPVideoController>> Function(
  int index,
  List<VPVideoController> list,
);

/// TikTokVideoListController is a controller for a series of videos, internally managing an array of video controllers.
/// It provides preloading/release/loading more functionality.
class TikTokVideoListController extends ChangeNotifier {
  TikTokVideoListController({
    this.loadMoreCount = 1,
    this.preloadCount = 2,

    /// TODO: VideoPlayer has a bug (on Android), currently can only be set to 0
    /// When set to 0, any video not on screen will be released
    /// If not set to 0, Android will not be able to load videos starting from the third one
    this.disposeCount = 0,
  });

  /// Trigger preload at which video, for example, 1: the last one, 2: second to last.
  final int loadMoreCount;

  /// Preload how many videos.
  final int preloadCount;

  /// How many videos are exceeded, they are released.
  final int disposeCount;

  /// Video provider builder.
  LoadMoreVideo? _videoProvider;

  loadIndex(int target, {bool reload = false}) {
    if (!reload) {
      if (index.value == target) return;
    }
    // Play the current one, pause the others.
    var oldIndex = index.value;
    var newIndex = target;

    // Pause the previous video.
    if (!(oldIndex == 0 && newIndex == 0)) {
      playerOfIndex(oldIndex)?.controller.seekTo(Duration.zero);
      playerOfIndex(oldIndex)?.pause();
      print('Paused $oldIndex');
    }
    // Start playing the current video.
    playerOfIndex(newIndex)?.controller.addListener(_didUpdateValue);
    playerOfIndex(newIndex)?.showPauseIcon.addListener(_didUpdateValue);
    playerOfIndex(newIndex)?.play();
    print('Playing $newIndex');
    // Handle preloading/releasing memory.
    for (var i = 0; i < playerList.length; i++) {
      /// Need to release videos before [disposeCount].
      /// i < newIndex - disposeCount to release videos when scrolling down.
      /// i > newIndex + max(disposeCount, 2) to release videos when scrolling up and also prevent losing video preload function when disposeCount is set to 0.
      if (i < newIndex - disposeCount || i > newIndex + max(disposeCount, 2)) {
        print('Releasing $i');
        playerOfIndex(i)?.controller.removeListener(_didUpdateValue);
        playerOfIndex(i)?.showPauseIcon.removeListener(_didUpdateValue);
        playerOfIndex(i)?.dispose();
        continue;
      }
      // Preloading is needed.
      if (i > newIndex && i < newIndex + preloadCount) {
        print('Preloading $i');
        playerOfIndex(i)?.init();
        continue;
      }
    }
    // Near the bottom, add more videos.
    if (playerList.length - newIndex <= loadMoreCount + 1) {
      _videoProvider?.call(newIndex, playerList).then(
        (list) async {
          playerList.addAll(list);
          notifyListeners();
        },
      );
    }

    // Done.
    index.value = target;
  }

  _didUpdateValue() {
    notifyListeners();
  }

  /// Get player of specified index.
  VPVideoController? playerOfIndex(int index) {
    if (index < 0 || index > playerList.length - 1) {
      return null;
    }
    return playerList[index];
  }

  /// Total number of videos.
  int get videoCount => playerList.length;

  /// Initialize.
  init({
    required PageController pageController,
    required List<VPVideoController> initialList,
    required LoadMoreVideo videoProvider,
  }) async {
    playerList.addAll(initialList);
    _videoProvider = videoProvider;
    pageController.addListener(() {
      var p = pageController.page!;
      if (p % 1 == 0) {
        loadIndex(p ~/ 1);
      }
    });
    loadIndex(0, reload: true);
    notifyListeners();
  }

  /// Current video sequence number.
  ValueNotifier<int> index = ValueNotifier<int>(0);

  /// Video list.
  List<VPVideoController> playerList = [];

  ///
  VPVideoController get currentPlayer => playerList[index.value];

  /// Dispose of everything.
  void dispose() {
    // Destroy everything.
    for (var player in playerList) {
      player.showPauseIcon.dispose();
      player.dispose();
    }
    playerList = [];
    super.dispose();
  }
}

typedef ControllerSetter<T> = Future<void> Function(T controller);
typedef ControllerBuilder<T> = T Function();

/// Abstract class, as a video controller must implement these methods.
abstract class TikTokVideoController<T> {
  /// Get the current controller instance.
  T? get controller;

  /// Whether to show the pause button.
  ValueNotifier<bool> get showPauseIcon;

  /// Load the video, after init, should start downloading video content.
  Future<void> init({ControllerSetter<T>? afterInit});

  /// Video destruction, after dispose, should release any memory resources.
  Future<void> dispose();

  /// Play.
  Future<void> play();

  /// Pause.
  Future<void> pause({bool showPauseIcon: false});
}

/// Asynchronous method concurrency lock.
Completer<void>? _syncLock;

class VPVideoController extends TikTokVideoController<VideoPlayerController> {
  VideoPlayerController? _controller;
  ValueNotifier<bool> _showPauseIcon = ValueNotifier<bool>(false);

  final UserVideo? videoInfo;

  final ControllerBuilder<VideoPlayerController> _builder;
  final ControllerSetter<VideoPlayerController>? _afterInit;
  VPVideoController({
    this.videoInfo,
    required ControllerBuilder<VideoPlayerController> builder,
    ControllerSetter<VideoPlayerController>? afterInit,
  })  : this._builder = builder,
        this._afterInit = afterInit;

  @override
  VideoPlayerController get controller {
    if (_controller == null) {
      _controller = _builder.call();
    }
    return _controller!;
  }

  bool get isDispose => _disposeLock != null;
  bool get prepared => _prepared;
  bool _prepared = false;

  Completer<void>? _disposeLock;

  /// Prevent asynchronous methods from running concurrently.
  Future<void> _syncCall(Future Function()? fn) async {
    // Set synchronous waiting.
    var lastCompleter = _syncLock;
    var completer = Completer<void>();
    _syncLock = completer;
    // Wait for other synchronous tasks to complete.
    await lastCompleter?.future;
    // Main task.
    await fn?.call();
    // End.
    completer.complete();
  }

  @override
  Future<void> dispose() async {
    if (!prepared) return;
    _prepared = false;
    await _syncCall(() async {
      print('+++dispose ${this.hashCode}');
      await this.controller.dispose();
      _controller = null;

      _disposeLock = Completer<void>();
    });
  }

  @override
  Future<void> init({
    ControllerSetter<VideoPlayerController>? afterInit,
  }) async {
    if (prepared) return;
    await _syncCall(() async {
      print('+++initialize ${this.hashCode}');
      await this.controller.initialize();
      await this.controller.setLooping(true);
      afterInit ??= this._afterInit;
      await afterInit?.call(this.controller);
      print('+++==initialize ${this.hashCode}');
      _prepared = true;
    });
    if (_disposeLock != null) {
      _disposeLock?.complete();
      _disposeLock = null;
    }
  }

  @override
  Future<void> pause({bool showPauseIcon: false}) async {
    await init();
    if (!prepared) return;
    if (_disposeLock != null) {
      await _disposeLock?.future;
    }
    await this.controller.pause();
    _showPauseIcon.value = true;
  }

  @override
  Future<void> play() async {
    await init();
    if (!prepared) return;
    if (_disposeLock != null) {
      await _disposeLock?.future;
    }
    await this.controller.play();
    _showPauseIcon.value = false;
  }

  @override
  ValueNotifier<bool> get showPauseIcon => _showPauseIcon;
}
