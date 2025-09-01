import '../point_value_type.dart';
import 'device_point_status.dart';

/// Defines the standard output points available for a Helvar output device.
enum OutputPointName {
  deviceState,
  lampFailure,
  missing,
  faulty,
  outputLevel,
  powerConsumption,
}

extension OutputPointNameExtension on OutputPointName {
  /// String representation used when serializing the point function.
  String get functionName {
    switch (this) {
      case OutputPointName.deviceState:
        return 'DeviceState';
      case OutputPointName.lampFailure:
        return 'LampFailure';
      case OutputPointName.missing:
        return 'Missing';
      case OutputPointName.faulty:
        return 'Faulty';
      case OutputPointName.outputLevel:
        return 'OutputLevel';
      case OutputPointName.powerConsumption:
        return 'PowerConsumption';
    }
  }

  /// Default Helvar point id for this output point.
  int get id => index + 1;

  /// Default point type used by this output point.
  PointValueType get pointType =>
      (this == OutputPointName.outputLevel ||
          this == OutputPointName.powerConsumption)
      ? PointValueType.numeric
      : PointValueType.boolean;

  /// Default initial value for this point.
  dynamic get defaultValue => pointType.defaultValue;

  /// Generate a point name for a given device.
  String nameForDevice(String deviceName) => '${deviceName}_$functionName';
}

class OutputPoint {
  final String id;
  String name;
  final String function;
  final int pointId;
  final PointValueType pointType;
  dynamic value;
  DevicePointStatus status;
  bool enabled;

  OutputPoint({
    required this.id,
    required this.name,
    required this.function,
    required this.pointId,
    required this.pointType,
    this.value,
    this.status = DevicePointStatus.available,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'function': function,
      'pointId': pointId,
      'pointType': pointType.name,
      'value': value,
      'status': status.string,
      'enabled': enabled,
    };
  }
}
