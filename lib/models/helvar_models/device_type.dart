import 'helvar_device.dart';

enum DeviceType { output, input }

extension DeviceTypeExtension on DeviceType {
  String get string => name;

  static DeviceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'input':
        return DeviceType.input;
      default:
        return DeviceType.output;
    }
  }
}

DeviceType deviceTypeFromString(String value) =>
    DeviceTypeExtension.fromString(value);

extension HelvarDeviceTypeExt on HelvarDevice {
  DeviceType get deviceType => deviceTypeFromString(helvarType);
}
