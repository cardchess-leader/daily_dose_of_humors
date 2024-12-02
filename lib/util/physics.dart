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
      speedFactor: speedFactor,
      frictionFactor: frictionFactor,
    );
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // Prevent overscrolling by ensuring position stays within bounds
    if (position.outOfRange) {
      return ScrollSpringSimulation(
        SpringDescription.withDampingRatio(
          mass: 1.0,
          stiffness: 100.0,
          ratio: 1.0,
        ),
        position.pixels,
        position.pixels
            .clamp(position.minScrollExtent, position.maxScrollExtent),
        velocity,
      );
    }

    final Simulation? simulation =
        super.createBallisticSimulation(position, velocity * frictionFactor);
    if (simulation != null && velocity.abs() > 0) {
      return ClampingScrollSimulation(
        position: position.pixels,
        velocity: simulation.dx(0) * speedFactor,
        tolerance: toleranceFor(position),
      );
    }
    return simulation;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.minScrollExtent) {
      // Prevent overscrolling past the start
      return value - position.minScrollExtent;
    } else if (value > position.maxScrollExtent) {
      // Prevent overscrolling past the end
      return value - position.maxScrollExtent;
    }
    return 0.0; // No boundary conditions violated
  }
}
