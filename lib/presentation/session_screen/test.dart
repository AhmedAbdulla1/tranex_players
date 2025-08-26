import 'dart:async';
import 'dart:math';

/// Simulates an acceleration wave for accelerometer readings every 100ms with varying amplitude and frequency.
/// Returns a stream of acceleration readings (as doubles).
Stream<double> generateAccelerationWave({
  double baseAmplitude = 5.0, // Base amplitude for acceleration (m/s²)
  double amplitudeVariation = 1.5, // Max change in amplitude per cycle
  double basePeriod = 2.0, // Base period in seconds
  double periodVariation = 0.5, // Max change in period per cycle
  double noiseLevel = 0.5, // Random noise level (±0.5 m/s²)
  int durationSeconds = 60, // Simulation duration in seconds
}) async* {
  final random = Random();
  final interval = Duration(milliseconds: 100); // 100ms interval
  double time = 0.0;
  double cycleTime = 0.0;
  double currentAmplitude = baseAmplitude;
  double currentPeriod = basePeriod;
  final endTime = durationSeconds.toDouble();

  while (time < endTime) {
    // Calculate angular frequency (ω = 2π / period)
    final angularFrequency = 2 * pi / currentPeriod;
    // Generate sine wave value: A * sin(ωt)
    final acceleration = currentAmplitude * sin(angularFrequency * cycleTime);
    // Add random noise
    final noise = (random.nextDouble() * 2 - 1) * noiseLevel;
    yield acceleration + noise;

    // Increment time by 0.1 seconds (100ms)
    time += 0.1;
    cycleTime += 0.1;

    // Check if a cycle is complete
    if (cycleTime >= currentPeriod) {
      // Reset cycle time
      cycleTime = 0.0;
      // Update amplitude randomly
      final amplitudeChange = (random.nextDouble() * 2 - 1) * amplitudeVariation;
      currentAmplitude = (baseAmplitude + amplitudeChange).clamp(
        baseAmplitude - amplitudeVariation,
        baseAmplitude + amplitudeVariation,
      );
      // Update period randomly
      final periodChange = (random.nextDouble() * 2 - 1) * periodVariation;
      currentPeriod = (basePeriod + periodChange).clamp(
        basePeriod - periodVariation,
        basePeriod + periodVariation,
      );
    }

    // Wait for the next interval (100ms)
    await Future.delayed(interval);
  }
}

