import '../../utils/core/path_utils.dart';
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

class InputPoint {
  final String id;
  String name;
  final int pointId;
  final InputPointType pointType;
  dynamic value;
  DevicePointStatus status;
  bool enabled;

  String get pathSegment =>
      sanitizePathSegment(name.isNotEmpty ? name : 'point_\$pointId');

  InputPoint({
    required this.id,
    required this.name,
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
      'pointId': pointId,
      'pointType': pointType.name,
      'value': value,
      'status': status.string,
      'enabled': enabled,
    };
  }
}
