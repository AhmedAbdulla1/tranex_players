import 'package:tranex_users/domain/models/models.dart';
import 'package:flutter/material.dart';

class WeightSelector extends StatefulWidget {
  const WeightSelector(
      {super.key, required this.accessory, required this.onChanged});

  final AccessoryData accessory;
  final ValueChanged<num> onChanged;

  @override
  State<WeightSelector> createState() => _WeightSelectorState();
}

class _WeightSelectorState extends State<WeightSelector> {
  late num weightNum;
  late num min;
  late num max;
  late num interval;
  late String accessoryName;
  late num weight;
  @override
  void initState() {
    weightNum = widget.accessory.min;
    min = widget.accessory.min;
    max = widget.accessory.max;
    interval = widget.accessory.interval;
    accessoryName = widget.accessory.accessoryName;
    weight = widget.accessory.weight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        child: Text(accessoryName[0]),
      ),
      title: Text(
        accessoryName,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => setState(() {
              if(weightNum > min){
                weightNum -=interval;
                widget.onChanged(-weight*interval);
              }
            }),
          ),
          Text(weightNum.toString()),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() {
              print(weightNum);
              if(weightNum < max){
                weightNum += interval;
                widget.onChanged(weight*interval);
              }
            }),
          ),
        ],
      ),
    );
  }
}
