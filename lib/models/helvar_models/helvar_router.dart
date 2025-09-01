import 'package:flutter/foundation.dart';
import 'package:simulator/utils/core/path_utils.dart';
import 'helvar_device.dart';
import 'device_type.dart';

class HelvarRouter {
  String address;
  final String ipAddress;
  String description;
  List<String>? deviceAddresses;
  bool isConnected;
  List<String> alarmGroupIds;

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
  }) : alarmGroupIds = alarmGroupIds ?? [],
       devices = devices ?? [] {
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelvarRouter &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          address == other.address &&
          listEquals(alarmGroupIds, other.alarmGroupIds);

  @override
  int get hashCode =>
      Object.hash(description, address, Object.hashAll(alarmGroupIds));

  factory HelvarRouter.fromJson(Map<String, dynamic> json) {
    return HelvarRouter(
      address: json['address'] as String,
      ipAddress: json['ipAddress'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isConnected: json['isNormal'] as bool? ?? true,
      alarmGroupIds:
          (json['alarmGroupIds'] as List?)?.cast<String>() ??
          (json['alarmGroupId'] != null ? [json['alarmGroupId']] : []),
      version: json['version'] as int? ?? 2,
      clusterId: json['clusterId'] as int? ?? 1,
      clusterMemberId: json['clusterMemberId'] as int? ?? 1,
      deviceTypeCode: json['deviceTypeCode'] as int?,
      deviceType: json['deviceType'] as String?,
      deviceState: json['deviceState'] as String?,
      deviceStateCode: json['deviceStateCode'] as int?,
      devices:
          (json['devices'] as List?)
              ?.map(
                (deviceJson) => HelvarDevice.fromJson(
                  Map<String, dynamic>.from(deviceJson as Map),
                ),
              )
              .whereType<HelvarDevice>()
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    final subnetsJson = <String, List<Map<String, dynamic>>>{};
    devicesBySubnet.forEach((subnet, subnetDevices) {
      subnetsJson['subnet$subnet'] = subnetDevices
          .map((device) => device.toJson())
          .toList();
    });

    return {
      'address': address,
      'ipAddress': ipAddress,
      'description': description,
      'isNormal': isConnected,
      'alarmGroupIds': alarmGroupIds,
      'version': version,
      'clusterId': clusterId,
      'clusterMemberId': clusterMemberId,
      'deviceTypeCode': deviceTypeCode,
      'deviceType': deviceType,
      'deviceState': deviceState,
      'deviceStateCode': deviceStateCode,
      'devicesBySubnet': subnetsJson,
      'devices': devices.map((device) => device.toJson()).toList(),
    };
  }

  HelvarRouter copyWith({List<String>? alarmGroupIds}) {
    return HelvarRouter(
      address: address,
      ipAddress: ipAddress,
      version: version,
      description: description,
      isConnected: isConnected,
      alarmGroupIds: alarmGroupIds ?? List<String>.from(this.alarmGroupIds),
      clusterId: clusterId,
      clusterMemberId: clusterMemberId,
      deviceTypeCode: deviceTypeCode,
      deviceType: deviceType,
      deviceState: deviceState,
      deviceStateCode: deviceStateCode,
      devices: devices,
    );
  }
}
