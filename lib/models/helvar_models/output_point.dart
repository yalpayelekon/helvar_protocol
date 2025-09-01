import 'workgroup.dart';
import '../point_value_type.dart';
import 'device_point.dart';
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

/// Defines the emergency specific output points for an emergency device.
enum EmergencyOutputPointName {
  emergencyFunctionTestTime,
  emergencyFunctionTestState,
  emergencyDurationTestTime,
  emergencyDurationTestState,
  emergencyBatteryCharge,
  emergencyBatteryTime,
  emergencyTotalLampTime,
  missing,
}

extension EmergencyOutputPointNameExtension on EmergencyOutputPointName {
  /// String representation used when serializing the point function.
  String get functionName {
    switch (this) {
      case EmergencyOutputPointName.emergencyFunctionTestTime:
        return 'EmergencyFunctionTestTime';
      case EmergencyOutputPointName.emergencyFunctionTestState:
        return 'EmergencyFunctionTestState';
      case EmergencyOutputPointName.emergencyDurationTestTime:
        return 'EmergencyDurationTestTime';
      case EmergencyOutputPointName.emergencyDurationTestState:
        return 'EmergencyDurationTestState';
      case EmergencyOutputPointName.emergencyBatteryCharge:
        return 'EmergencyBatteryCharge';
      case EmergencyOutputPointName.emergencyBatteryTime:
        return 'EmergencyBatteryTime';
      case EmergencyOutputPointName.emergencyTotalLampTime:
        return 'EmergencyTotalLampTime';
      case EmergencyOutputPointName.missing:
        return 'Missing';
    }
  }

  /// Default Helvar point id for this emergency output point.
  int get id => index + 1;

  /// Default point type used by this output point.
  PointValueType get pointType {
    if (this == EmergencyOutputPointName.emergencyFunctionTestState ||
        this == EmergencyOutputPointName.emergencyDurationTestState ||
        this == EmergencyOutputPointName.missing) {
      return PointValueType.boolean;
    }
    if (this == EmergencyOutputPointName.emergencyFunctionTestTime ||
        this == EmergencyOutputPointName.emergencyDurationTestTime ||
        this == EmergencyOutputPointName.emergencyBatteryTime) {
      return PointValueType.string;
    }
    return PointValueType.numeric;
  }

  /// Default initial value for this point.
  dynamic get defaultValue => pointType.defaultValue;

  /// Generate a point name for a given device.
  String nameForDevice(String deviceName) => '${deviceName}_$functionName';
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

class OutputPoint implements DevicePoint {
  @override
  final String id;
  @override
  String name;
  final String function;
  @override
  final int pointId;
  final PointValueType pointType;
  @override
  final PointPollingRate pollingRate;
  @override
  dynamic value;
  @override
  DevicePointStatus status;
  @override
  bool enabled;

  OutputPoint({
    required this.id,
    required this.name,
    required this.function,
    required this.pointId,
    required this.pointType,
    this.pollingRate = PointPollingRate.normal,
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
      'pollingRate': pollingRate.name,
      'value': value,
      'status': status.string,
      'enabled': enabled,
    };
  }

  factory OutputPoint.fromJson(Map<String, dynamic> json) {
    return OutputPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      function: json['function'] as String,
      pointId: json['pointId'] as int,
      pointType: json['pointType'] != null
          ? PointValueTypeExtension.fromString(json['pointType'] as String)
          : PointValueType.boolean,
      pollingRate: json['pollingRate'] != null
          ? PointPollingRate.fromString(json['pollingRate'] as String)
          : PointPollingRate.normal,
      value: json['value'],
      status: json['status'] != null
          ? DevicePointStatusExtension.fromString(json['status'] as String)
          : DevicePointStatus.available,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  @override
  OutputPoint copyWith({
    String? id,
    String? name,
    String? function,
    int? pointId,
    PointValueType? pointType,
    PointPollingRate? pollingRate,
    dynamic value,
    DevicePointStatus? status,
    bool? enabled,
  }) {
    return OutputPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      function: function ?? this.function,
      pointId: pointId ?? this.pointId,
      pointType: pointType ?? this.pointType,
      pollingRate: pollingRate ?? this.pollingRate,
      value: value ?? this.value,
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputPoint &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
