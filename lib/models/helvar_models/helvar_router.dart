import '../../utils/core/path_utils.dart';
import 'helvar_device.dart';
import 'device_type.dart';

class HelvarRouter {
  String address;
  final String ipAddress;
  String description;
  List<String>? deviceAddresses;
  bool isConnected;

  int version;
  int clusterId;
  int clusterMemberId;
  int? deviceTypeCode;
  String? deviceState;
  int? deviceStateCode;
  Map<int, List<HelvarDevice>> devicesBySubnet = {};
  String? deviceType;
  List<HelvarDevice> devices;

  String get pathSegment =>
      sanitizePathSegment(description.isNotEmpty ? description : ipAddress);

  HelvarRouter({
    this.address = "",
    required this.ipAddress,
    this.version = 2,
    this.description = '',
    this.isConnected = true,
    List<String>? alarmGroupIds,
    this.clusterId = 1,
    this.clusterMemberId = 1,
    this.deviceTypeCode,
    this.deviceState,
    this.deviceType,
    this.deviceStateCode,
    List<HelvarDevice>? devices,
  }) : devices = devices ?? [] {
    if (ipAddress.contains('.')) {
      final ipParts = ipAddress.split('.');
      if (ipParts.length == 4) {
        try {
          clusterId = int.parse(ipParts[2]);
          clusterMemberId = int.parse(ipParts[3]);
          address = '@${ipParts[2]}.${ipParts[3]}';
        } catch (e) {
          print(e.toString());
        }
      }
    }

    if (devices != null && devices.isNotEmpty) {
      organizeDevicesBySubnet();
    }
  }

  void organizeDevicesBySubnet() {
    devicesBySubnet.clear();
    for (final device in devices) {
      final parts = device.address.split('.');
      if (parts.length >= 3) {
        final subnet = int.parse(parts[2]);
        if (!devicesBySubnet.containsKey(subnet)) {
          devicesBySubnet[subnet] = [];
        }
        devicesBySubnet[subnet]!.add(device);
      }
    }
  }

  void addDevice(HelvarDevice device) {
    if (devices.any((d) => d.address == device.address)) {
      throw StateError(
        'Device with address ${device.address} already exists in router $address',
      );
    }

    devices.add(device);

    final subnet = device.subnet;
    if (!devicesBySubnet.containsKey(subnet)) {
      devicesBySubnet[subnet] = [];
    }
    devicesBySubnet[subnet]!.add(device);
  }

  void removeDevice(HelvarDevice device) {
    devices.remove(device);

    final subnet = device.subnet;
    if (devicesBySubnet.containsKey(subnet)) {
      devicesBySubnet[subnet]!.remove(device);
      if (devicesBySubnet[subnet]!.isEmpty) {
        devicesBySubnet.remove(subnet);
      }
    }
  }

  List<HelvarDevice> getDevicesByType(DeviceType deviceType) {
    return devices.where((device) => device.deviceType == deviceType).toList();
  }

  List<HelvarDevice> getDevicesBySubnet(int subnet) {
    return devicesBySubnet[subnet] ?? [];
  }
}
