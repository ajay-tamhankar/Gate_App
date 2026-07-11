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
/// - Cancels its timer while the host route is **covered** by another route
///   (e.g., user navigates to a detail page). Previously the timer kept
///   firing on hidden routes and the heavy JSON-parsing-on-main-thread it
///   triggered would freeze whatever screen the user *was* on.
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
    with WidgetsBindingObserver, RouteAware {
  Timer? _timer;
  bool _appActive = true;
  bool _routeVisible = true;
  ModalRoute<dynamic>? _route;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Track the current route so we know whether we're the visible screen.
    final route = ModalRoute.of(context);
    if (route != _route) {
      _route = route;
      _routeVisible = route?.isCurrent ?? true;
    }
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
      // Be strict about when we fire: mounted, app foregrounded, AND the
      // host route is current (not pushed-under by a detail screen).
      if (mounted && _appActive && _isRouteCurrent()) _invalidate();
    });
  }

  bool _isRouteCurrent() {
    if (!_routeVisible) return false;
    // If we had a stale ModalRoute reference, recheck on the fly.
    final route = _route ?? ModalRoute.of(context);
    return route?.isCurrent ?? true;
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
    if (!wasActive && _appActive && widget.refreshOnResume && _isRouteCurrent()) {
      _invalidate();
    }
    if (_appActive) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update route visibility each rebuild — cheap and avoids needing a
    // RouteObserver wired up in the router config. A route is "current"
    // when nothing is on top of it; this flips back automatically when the
    // user pops back to the host screen.
    final route = ModalRoute.of(context);
    _routeVisible = route?.isCurrent ?? true;
    return widget.child;
  }
}
