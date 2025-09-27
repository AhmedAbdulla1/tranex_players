// matches_entity.dart
enum MatchStatus {
  waitingBluetoothPlayer1,
  waitingBluetoothPlayer2,
  waitingNFC1,
  waitingNFC2,
  checkingNFC1,
  checkingNFC2,
  errorNFC1,
  errorNFC2,
  inMatch,
  paused,
  ended,
  disconnected,
}

class PlayerMovementData {
  final double speed;
  final int direction;
  final int timeInMs;
  PlayerMovementData({required this.speed, required this.direction, required this.timeInMs});
}

class PointDataEntity {
  final int timeInMs;
  final double speed;
  PointDataEntity({required this.timeInMs, required this.speed});
}
