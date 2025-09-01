enum DevicePointStatus { available, notAvailable, faultStale }

extension DevicePointStatusExtension on DevicePointStatus {
  String get string => name;

  String get displayString {
    switch (this) {
      case DevicePointStatus.available:
        return 'Available';
      case DevicePointStatus.notAvailable:
        return 'N/A';
      case DevicePointStatus.faultStale:
        return 'Fault';
    }
  }

  static DevicePointStatus fromString(String value) {
    switch (value) {
      case 'notAvailable':
        return DevicePointStatus.notAvailable;
      case 'faultStale':
        return DevicePointStatus.faultStale;
      case 'available':
      default:
        return DevicePointStatus.available;
    }
  }
}
