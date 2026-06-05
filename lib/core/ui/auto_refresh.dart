import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drives periodic invalidation of one or more Riverpod providers so a
/// screen's data stays fresh while it's mounted and the window is visible.
///
/// Behavior:
/// - Invalidates immediately when first mounted (covers cold open).
/// - Re-invalidates on a fixed interval (default 60s).
/// - Re-invalidates when the app resumes from background.
/// - Cancels its timer while the app is backgrounded (no wasted requests).
class AutoRefresh extends ConsumerStatefulWidget {
  final List<ProviderOrFamily> providers;
  final Duration interval;
  final Widget child;
  final bool refreshOnResume;
  final bool refreshOnMount;

  const AutoRefresh({
    super.key,
    required this.providers,
    required this.child,
    this.interval = const Duration(seconds: 60),
    this.refreshOnResume = true,
    this.refreshOnMount = false,
  });

  @override
  ConsumerState<AutoRefresh> createState() => _AutoRefreshState();
}

class _AutoRefreshState extends ConsumerState<AutoRefresh>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _appActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.refreshOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _invalidate();
      });
    }
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AutoRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval) {
      _timer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.interval == Duration.zero) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (mounted && _appActive) _invalidate();
    });
  }

  void _invalidate() {
    for (final p in widget.providers) {
      ref.invalidate(p);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _appActive;
    _appActive = state == AppLifecycleState.resumed;
    if (!wasActive && _appActive && widget.refreshOnResume) {
      _invalidate();
    }
    if (_appActive) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
