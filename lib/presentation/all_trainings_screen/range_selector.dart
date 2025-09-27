import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CustomRangeSelector extends StatefulWidget {
  final double min;
  final double max;
  final SfRangeValues initialValues;
  final Function(SfRangeValues) onChanged;
  final double interval;

  const CustomRangeSelector({
    super.key,
    required this.min,
    required this.max,
    required this.initialValues,
    required this.onChanged,
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
    final int start = values.start.round();
    final int end = values.end.round();
    final newValues = SfRangeValues(start.toDouble(), end.toDouble());

    setState(() {
      _currentValues = newValues;
    });

    widget.onChanged(newValues);
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

    widget.onChanged(newValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SfRangeSelector(
          activeColor: Colors.deepOrangeAccent,
          key: ValueKey(_currentValues),
          min: widget.min,
          max: widget.max,
          initialValues: _currentValues,
          onChanged: _onRangeChanged,
          showLabels: true,
          showTicks: true,
          showDividers: true,
          interval: widget.interval,
          stepSize: 1.0,
          child: Container(
            height: 20.h,
            color: Colors.grey.withOpacity(0.1),
            child: Center(
              child: Text(
                'Range: ${_currentValues.start.toStringAsFixed(0)} - ${_currentValues.end.toStringAsFixed(0)} s',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: [
            const Text(
              'Quarter',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            _buildQuarterButton('1st', 0),
            _buildQuarterButton('2nd', 1),
            _buildQuarterButton('3rd', 2),
            _buildQuarterButton('4th', 3),
          ],
        ),
      ],
    );
  }

  Widget _buildQuarterButton(String label, int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        backgroundColor: Colors.deepOrangeAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      onPressed: () => _selectQuarter(index),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }
}
