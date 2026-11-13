import 'dart:async';

import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:flutter/widgets.dart';

/// A transparent layer on which small pictures fly from one place to
/// another: a collected item from the scene into its inventory slot.
///
/// Put it on top of everything and keep a `GlobalKey<FlightLayerState>` to
/// call [FlightLayerState.fly]. It never takes touches.
class FlightLayer extends StatefulWidget {
  const FlightLayer({super.key});

  @override
  State<FlightLayer> createState() => FlightLayerState();
}

class FlightLayerState extends State<FlightLayer>
    with TickerProviderStateMixin {
  final _flights = <_Flight>[];

  /// Flies [child] from [from] to wherever [to] points when the flight
  /// starts (both in global coordinates). Completes when it has landed.
  ///
  /// [to] is a callback because the destination often appears only after
  /// the event that triggers the flight (a new inventory slot).
  Future<void> fly({
    required Rect from,
    required Rect? Function() to,
    required Widget child,
  }) async {
    // Wait for the next frame, so the destination has been laid out.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final target = to();
    final box = context.findRenderObject();
    if (target == null || box is! RenderBox) return;

    final origin = box.localToGlobal(Offset.zero);
    final controller = AnimationController(
      vsync: this,
      duration: AppDurations.itemFlight,
    );
    final flight = _Flight(
      controller: controller,
      rect:
          RectTween(
            begin: from.shift(-origin),
            end: target.shift(-origin),
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic),
          ),
      child: child,
    );

    setState(() => _flights.add(flight));
    try {
      await controller.forward().orCancel;
    } on TickerCanceled {
      // The layer was removed mid-flight; nothing left to do.
    }
    // When the layer itself was disposed, it already cleaned up the flight.
    if (!_flights.remove(flight)) return;
    controller.dispose();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final flight in _flights) {
      flight.controller.dispose();
    }
    _flights.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final flight in _flights)
            AnimatedBuilder(
              animation: flight.rect,
              builder: (context, child) =>
                  Positioned.fromRect(rect: flight.rect.value!, child: child!),
              child: flight.child,
            ),
        ],
      ),
    );
  }
}

class _Flight {
  _Flight({required this.controller, required this.rect, required this.child});

  final AnimationController controller;
  final Animation<Rect?> rect;
  final Widget child;
}
