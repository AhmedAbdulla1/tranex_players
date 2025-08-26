import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/main_screen/screens/training/widgets/weight_selector.dart';
import 'package:flutter/material.dart';

class WeightSection extends StatefulWidget {
  const WeightSection({super.key, required this.deviceDataStream,required this.onWeightChanged});
  final Function(num) onWeightChanged;
  final Stream<DeviceData> deviceDataStream;

  @override
  State<WeightSection> createState() => _WeightSectionState();
}

class _WeightSectionState extends State<WeightSection> {
  late List<AccessoryData> accessories;
  int total = 0;

  @override
  void initState() {
    super.initState();
    accessories=[];
    // total = (accessories.first.min*accessories.first.weight).toInt(); // Reset total if needed when the device changes
    // Listen to the stream and update the state when new data arrives
    widget.deviceDataStream.listen((deviceData) {
      setState(() {
        accessories = deviceData.accessories;
        total = (accessories.first.min*accessories.first.weight).toInt(); // Reset total if needed when the device changes
        widget.onWeightChanged(total);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildWeightDisplay(), _buildWeightSelectors()],
    );
  }

  Widget _buildWeightDisplay() {
    return Text(
      'Your weight is $total g',
      style: Theme.of(context).textTheme.labelMedium,
    );
  }

  Widget _buildWeightSelectors() {
    return Column(
      children: accessories.map((e) {
        return WeightSelector(
         key: ValueKey(e.accessoryName),
          accessory: e,
          onChanged: (value) {
            setState(() {
              total += value.toInt();
              widget.onWeightChanged(total);
            });
          },
        );
      }).toList(),
    );
  }
}
