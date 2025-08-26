import 'dart:async';

import 'package:firesport_users/data/network/network_info.dart';
import 'package:rxdart/rxdart.dart';

class MainViewModel extends MainViewModelOutput {
  final StreamController<int> _streamController = BehaviorSubject<int>();
  final NetworkInfo _networkInfo;
  MainViewModel(this._networkInfo);
  @override
  Sink<int> get inputIndex => _streamController.sink;

  @override
  Stream<int> get outIndex => _streamController.stream.map((event) => event);

  @override
  start()async{
    if(! (await _networkInfo.isConnected)){
     inputIndex.add(1);
    }
  }

  @override
  setIndex(int index) {
    inputIndex.add(index);
  }
}

abstract class MainViewModelInput {
  start();
  setIndex(int index);

  Sink<int> get inputIndex;
}

abstract class MainViewModelOutput extends MainViewModelInput {
  Stream<int> get outIndex;
}
