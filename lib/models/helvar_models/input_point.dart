import 'package:simulator/utils/core/path_utils.dart';

import 'device_point.dart';
import 'workgroup.dart';
import 'device_point_status.dart';

enum InputPointType {
  button,
  ir,
  slider,
  pushOnOff,
  inputBool,
  inputNumeric,
  pir,
  lightSensor,
  missing,
}

class InputPoint implements DevicePoint {
  @override
  final String id;
  @override
  String name;
  @override
  final int pointId;
  final InputPointType pointType;
  @override
  final PointPollingRate pollingRate;
  @override
  dynamic value;
  @override
  DevicePointStatus status;
  @override
  bool enabled;

  String get pathSegment =>
      sanitizePathSegment(name.isNotEmpty ? name : 'point_\$pointId');

  InputPoint({
    required this.id,
    required this.name,
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
      'pointId': pointId,
      'pointType': pointType.name,
      'pollingRate': pollingRate.name,
      'value': value,
      'status': status.string,
      'enabled': enabled,
    };
  }

  factory InputPoint.fromJson(Map<String, dynamic> json) {
    return InputPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      pointId: json['pointId'] as int,
      pointType: InputPointType.values.firstWhere(
        (e) => e.name == (json['pointType'] as String? ?? 'button'),
        orElse: () => InputPointType.button,
      ),
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
  InputPoint copyWith({
    String? id,
    String? name,
    int? pointId,
    InputPointType? pointType,
    PointPollingRate? pollingRate,
    dynamic value,
    DevicePointStatus? status,
    bool? enabled,
  }) {
    return InputPoint(
      id: id ?? this.id,
      name: name ?? this.name,
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
      other is InputPoint && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
