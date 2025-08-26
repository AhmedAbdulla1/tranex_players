// custom_range_selector.dart
import 'dart:async';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CustomRangeSelector extends StatefulWidget {
  final double min;
  final double max;
  final SfRangeValues initialValues;
  final StreamController<SfRangeValues> rangeStreamController;
  final double interval;

  const CustomRangeSelector({
    super.key,
    required this.min,
    required this.max,
    required this.initialValues,
    required this.rangeStreamController,
    required this.interval,
  });

  @override
  _CustomRangeSelectorState createState() => _CustomRangeSelectorState();
}

class _CustomRangeSelectorState extends State<CustomRangeSelector> {
  late SfRangeValues _currentValues;

  @override
  void initState() {
    super.initState();
    _currentValues = widget.initialValues;
  }

  void _onRangeChanged(SfRangeValues values) {
    // Snap to integer values
    final int start = values.start.round();
    final int end = values.end.round();
    final newValues = SfRangeValues(start.toDouble(), end.toDouble());

    setState(() {
      _currentValues = newValues;
    });

    // Emit the new range to the stream
    widget.rangeStreamController.add(newValues);
  }

  void _selectQuarter(int quarter) {
    final double totalRange = widget.max - widget.min;
    final double quarterSize = totalRange / 4;
    final double start = quarter * quarterSize;
    final double end = (quarter + 1) * quarterSize;

    final newValues = SfRangeValues(start, end.clamp(start, widget.max));
    setState(() {
      _currentValues = newValues;
    });

    // Emit the new range to the stream
    widget.rangeStreamController.add(newValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quarter Selector Buttons

        // Range Selector
        SfRangeSelector(
          key: ValueKey(_currentValues), // Force rebuild when values change
          min: widget.min,
          max: widget.max,
          initialValues: _currentValues, // Use dynamic values
          onChanged: _onRangeChanged,
          showLabels: true,
          showTicks: true,
          showDividers: true,
          interval: widget.interval,
          stepSize: 1.0, // Snap to integer values
          child: Container(
            height:AppSize.s20,
            color: Colors.grey.withOpacity(0.1),
            child: Center(
              child: Text(
                'Range: ${_currentValues.start.toStringAsFixed(0)} - ${_currentValues.end.toStringAsFixed(0)} s',
                style: TextStyle(fontSize:FontSize.s12,color: Colors.black),
              ),
            ),
          ),
        ),
        const SizedBox(height:AppSize.s5),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Quarter', style: TextStyle(color: Colors.black)),
            ElevatedButton(
              onPressed: () => _selectQuarter(0),
              child: const Text('1st',style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () => _selectQuarter(1),
              child: const Text('2nd',style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () => _selectQuarter(2),
              child: const Text('3rd',style: TextStyle(color: Colors.white) ,),
            ),
            ElevatedButton(
              onPressed: () => _selectQuarter(3),
              child: const Text('4th',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ],
    );
  }
}