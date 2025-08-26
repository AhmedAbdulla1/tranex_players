import 'package:flutter/material.dart';

class BatteryLevelBar extends StatelessWidget {
  final double batteryLevel;

  const BatteryLevelBar({
    Key? key,
    required this.batteryLevel,
  }) : super(key: key);

  // Voltage and width range settings
  static const double minVoltage = 1.8;
  static const double maxVoltage = 2.2;
  static const double maxWidth = 50;

  // Map battery level voltage to container width
  double _calculateWidth(double voltage) {
    double clampedVoltage = voltage.clamp(minVoltage, maxVoltage);
    return ((clampedVoltage - minVoltage) / (maxVoltage - minVoltage)) * maxWidth;
  }

  // Get color based on battery level voltage
  Color _getBatteryColor(double width) {
    if (width < maxWidth * 0.3) {
      return Colors.red; // Low battery
    } else if (width < maxWidth * 0.7) {
      return Colors.orange; // Medium battery
    } else {
      return Colors.green; // High battery
    }
  }

  @override
  Widget build(BuildContext context) {
    final double batteryWidth = _calculateWidth(batteryLevel);
    final Color batteryColor = _getBatteryColor(batteryWidth);

    return Container(
      width: maxWidth, // Fixed container width
      height: 20, // Adjust height as needed
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          // Battery level indicator
          Container(
            width: batteryWidth,
            height: 20,
            decoration: BoxDecoration(
              color: batteryColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          // Display either charging icon or battery percentage
          Center(
            child: Text(
              '${(batteryWidth / maxWidth * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
