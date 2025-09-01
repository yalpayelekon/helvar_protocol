import 'device_point_status.dart';
import 'workgroup.dart';

abstract class DevicePoint {
  String get id;
  String get name;
  int get pointId;
  PointPollingRate get pollingRate;
  dynamic get value;
  DevicePointStatus get status;
  bool get enabled;

  DevicePoint copyWith({
    String? id,
    String? name,
    int? pointId,
    PointPollingRate? pollingRate,
    dynamic value,
    DevicePointStatus? status,
    bool? enabled,
  });
}
