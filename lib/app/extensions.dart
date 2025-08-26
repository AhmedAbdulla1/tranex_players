import 'package:flutter/material.dart';

extension NonNullableString on String? {
  String orEmpty() {
    if (this == null) {
      return "";
    } else {
      return this!;
    }
  }
}

extension NonNullableInteger on int? {
  int orZero() {
    if (this == null) {
      return 0;
    } else {
      return this!;
    }
  }
}

extension IntegerExtension on int {
  // Calculate hours, minutes, and seconds
  String convertSecondsToHMS() {
    // Calculate hours, minutes, and seconds
    int hours = this ~/ 3600;
    int minutes = (this % 3600) ~/ 60;
    int secs = this % 60;

    // Build the result string conditionally
    List<String> result = [];
    if (hours > 0) {
      result.add('${hours}h');
    }
    if (minutes > 0) {
      result.add('${minutes}m');
    }
    if (secs > 0) {
      result.add('${secs}s');
    } else if (secs == 0) {
      result.add('0s');
    }
    return result.join(' ');
  }
}

extension FristName on String {
  String toCapitalizedCase(){
    if(length!=0){
    final characters = this.characters.toList();
    characters[0]=this[0].toUpperCase();
    int index= indexOf(' ', 0);
    characters[index + 1]=this[index+1].toUpperCase();
      return characters.join('');
    }else {
      return this;
    }
  }

  // String smallSentence() {
  //   if (length > 30) {
  //     return substring(0, 30);
  //   } else {
  //     return this;
  //   }
  // }


  String firstName() {
    int startIndex = 0, indexOfSpace=0;
    indexOfSpace = indexOf(' ', startIndex);
      if (indexOfSpace == -1) {
        //-1 is when character is not found
        return this;
      }
    return substring(0,indexOfSpace);
  }
  // String doctorName
}
extension Space on double? {

  double formatNum({int decimals = 2}) {
    if (this == null) return 0.0;
    if (this is num) {
      if (this!.isInfinite || this!.isNaN) return 0.0;
      return double.parse(this!.toStringAsFixed(decimals));
    }
    return 0.0;
  }

  SizedBox ph() {
    return SizedBox(
      height: this,
    );
  }

  SizedBox pw() {
    return SizedBox(
      width: this,
    );
  }
}
