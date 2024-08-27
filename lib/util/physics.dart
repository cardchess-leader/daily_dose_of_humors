import 'package:flutter/material.dart';

class FastSnapScrollPhysics extends FixedExtentScrollPhysics {
  final double speedFactor;
  final double frictionFactor;

  const FastSnapScrollPhysics({
    super.parent,
    this.speedFactor = 2.0,
    this.frictionFactor = 0.5,
  });

  @override
  FastSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastSnapScrollPhysics(
      parent: buildParent(ancestor),
      speedFactor: speedFactor, // Pass the speed factor to the new instance
      frictionFactor: frictionFactor,
    );
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Simulation? simulation =
        super.createBallisticSimulation(position, velocity * frictionFactor);
    if (simulation != null && velocity.abs() > 0) {
      return ClampingScrollSimulation(
        position: position.pixels,
        velocity: simulation.dx(0) * speedFactor, // Use the speed factor
        tolerance: toleranceFor(position), // Use the new toleranceFor method
      );
    }
    return simulation;
  }
}
