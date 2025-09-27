import 'package:flutter/material.dart';

class ResultView extends StatefulWidget {
  const ResultView({Key? key}) : super(key: key);

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  @override
  Widget build(BuildContext context) {
    return  Center(child: Text('Result ',style: Theme.of(context).textTheme.labelLarge,));
  }


}

