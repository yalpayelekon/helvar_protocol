import 'package:simulator/utils/core/path_utils.dart';

import 'output_point.dart';
import '../../protocol/protocol_utils.dart';
import 'package:flutter/foundation.dart';
import 'emergency_device.dart';
import 'device_action.dart';
import 'input_device.dart';
import 'input_point.dart';
import 'output_device.dart';

abstract class HelvarDevice {
  final String id;
  int cluster;
  int routerId;
  int subnet;
  int deviceIndex;
  int? subDeviceIndex;
  int deviceId;
  String address;
  String state;
  String name;
  String description;
  String props;
  String iconPath;
  String hexId;
  String addressingScheme;
  bool emergency;
  String blockId;
  String sceneId;
  String out;
  String helvarType;

  /// Timestamp of the last successful message received for this device.
  DateTime? lastMessageTime;

  int? deviceTypeCode;
  int? deviceStateCode;

  bool isButtonDevice;
  bool isMultisensor;

  /// Identifiers of the alarm groups this device is assigned to.
  List<String> alarmGroupIds;

  Map<String, dynamic> sensorInfo;

  String get pathSegment => sanitizePathSegment(
    (description.isNotEmpty
        ? description
        : (name.isNotEmpty ? name : 'device_$deviceId')),
  );

  HelvarDevice({
    required this.id,
    this.cluster = 1,
    this.routerId = 1,
    this.subnet = 1,
    this.deviceIndex = 1,
    this.subDeviceIndex,
    this.deviceId = 1,
    this.address = "@",
    this.state = "",
    this.description = "",
    this.name = "",
    this.props = "",
    this.iconPath = "",
    this.hexId = "",
    this.addressingScheme = "",
    this.emergency = false,
    this.blockId = "1",
    this.sceneId = "",
    this.out = "",
    this.helvarType = "output",
    this.lastMessageTime,
    this.deviceTypeCode,
    this.deviceStateCode,
    this.isButtonDevice = false,
    this.isMultisensor = false,
    List<String>? alarmGroupIds,
    Map<String, dynamic>? sensorInfo,
  }) : alarmGroupIds = alarmGroupIds ?? [],
       sensorInfo = sensorInfo ?? {} {
    if (address.startsWith('@')) {
      address = address.substring(1);
    }

    // Parse the device address and validate each component.
    // Valid ranges (from Helvar router documentation):
    //   cluster: 1-255
    //   router: 1-255
    //   subnet: 1-255
    //   device: 1-65499
    //   sub device: 0-255
    final parts = address.split('.');
    if (parts.length >= 4) {
      try {
        final parsedCluster = int.parse(parts[0]);
        final parsedRouter = int.parse(parts[1]);
        final parsedSubnet = int.parse(parts[2]);
        final parsedDevice = int.parse(parts[3]);

        ProtocolUtils.validateCluster(parsedCluster);
        ProtocolUtils.validateRouter(parsedRouter);
        ProtocolUtils.validateSubnet(parsedSubnet);
        ProtocolUtils.validateDevice(parsedDevice);

        cluster = parsedCluster;
        routerId = parsedRouter;
        subnet = parsedSubnet;
        deviceIndex = parsedDevice;

        if (parts.length >= 5) {
          final parsedSubDevice = int.parse(parts[4]);
          ProtocolUtils.validateSubDevice(parsedSubDevice);
          subDeviceIndex = parsedSubDevice;
        }
      } catch (e) {
        print("Error in HelvarDevice creation:$e");
        rethrow;
      }
    } else {
      throw FormatException('Invalid Helvar device address: $address');
    }
  }

  factory HelvarDevice.fromJson(Map<String, dynamic> json) {
    final helvarType = json['helvarType'] as String? ?? 'output';
    final parsedLastMessageTime = json['lastMessageTime'] != null
        ? DateTime.tryParse(json['lastMessageTime'] as String)
        : null;

    final inputPoints = <InputPoint>[];
    if (json['inputPoints'] != null) {
      for (var point in (json['inputPoints'] as List)) {
        inputPoints.add(
          InputPoint.fromJson(Map<String, dynamic>.from(point as Map)),
        );
      }
    }

    if (helvarType == "input") {
      return HelvarDriverInputDevice(
        id: json['id'] as String,
        deviceId: json['deviceId'] as int? ?? 1,
        address: json['address'] as String? ?? '@',
        state: json['state'] as String? ?? '',
        description: json['description'] as String? ?? '',
        name: json['name'] as String? ?? '',
        props: json['props'] as String? ?? '',
        iconPath: json['iconPath'] as String? ?? '',
        hexId: json['hexId'] as String? ?? '',
        addressingScheme: json['addressingScheme'] as String? ?? '',
        emergency: json['emergency'] as bool? ?? false,
        blockId: json['blockId'] as String? ?? '1',
        sceneId: json['sceneId'] as String? ?? '',
        out: json['out'] as String? ?? '',
        helvarType: json['helvarType'] as String? ?? 'input',
        subDeviceIndex: json['subDeviceIndex'] as int?,
        deviceTypeCode: json['deviceTypeCode'] as int?,
        deviceStateCode: json['deviceStateCode'] as int?,
        isButtonDevice: json['isButtonDevice'] as bool? ?? false,
        isMultisensor: json['isMultisensor'] as bool? ?? false,
        alarmGroupIds:
            (json['alarmGroupIds'] as List?)?.cast<String>() ??
            (json['alarmGroupId'] != null ? [json['alarmGroupId']] : []),
        inputPoints: inputPoints,
        sensorInfo: json['sensorInfo'] != null
            ? Map<String, dynamic>.from(json['sensorInfo'] as Map)
            : {},
        lastMessageTime: parsedLastMessageTime,
      );
    }
    if (helvarType == "output") {
      final outputPoints = <OutputPoint>[];
      if (json['outputPoints'] != null) {
        for (var point in (json['outputPoints'] as List)) {
          outputPoints.add(
            OutputPoint.fromJson(Map<String, dynamic>.from(point as Map)),
          );
        }
      }

      return HelvarDriverOutputDevice(
        id: json['id'] as String,
        deviceId: json['deviceId'] as int? ?? 1,
        address: json['address'] as String? ?? '@',
        state: json['state'] as String? ?? '',
        description: json['description'] as String? ?? '',
        name: json['name'] as String? ?? '',
        props: json['props'] as String? ?? '',
        iconPath: json['iconPath'] as String? ?? '',
        hexId: json['hexId'] as String? ?? '',
        addressingScheme: json['addressingScheme'] as String? ?? '',
        emergency: json['emergency'] as bool? ?? false,
        blockId: json['blockId'] as String? ?? '1',
        sceneId: json['sceneId'] as String? ?? '',
        out: json['out'] as String? ?? '',
        helvarType: json['helvarType'] as String? ?? 'output',
        subDeviceIndex: json['subDeviceIndex'] as int?,
        missing: json['missing'] as bool? ?? false,
        faulty: json['faulty'] as bool? ?? false,
        level: json['level'] as int?,
        proportion: json['proportion'] as int? ?? 0,
        deviceTypeCode: json['deviceTypeCode'] as int?,
        deviceStateCode: json['deviceStateCode'] as int?,
        isButtonDevice: json['isButtonDevice'] as bool? ?? false,
        isMultisensor: json['isMultisensor'] as bool? ?? false,
        alarmGroupIds:
            (json['alarmGroupIds'] as List?)?.cast<String>() ??
            (json['alarmGroupId'] != null ? [json['alarmGroupId']] : []),
        sensorInfo: json['sensorInfo'] != null
            ? Map<String, dynamic>.from(json['sensorInfo'] as Map)
            : {},
        outputPoints: outputPoints,
        lastMessageTime: parsedLastMessageTime,
      );
    } else {
      final outputPoints = <OutputPoint>[];
      if (json['outputPoints'] != null) {
        for (var point in (json['outputPoints'] as List)) {
          outputPoints.add(
            OutputPoint.fromJson(Map<String, dynamic>.from(point as Map)),
          );
        }
      }
      return HelvarDriverEmergencyDevice(
        id: json['id'] as String,
        deviceId: json['deviceId'] as int? ?? 1,
        address: json['address'] as String? ?? '@',
        state: json['state'] as String? ?? '',
        description: json['description'] as String? ?? '',
        name: json['name'] as String? ?? '',
        props: json['props'] as String? ?? '',
        iconPath: json['iconPath'] as String? ?? '',
        hexId: json['hexId'] as String? ?? '',
        addressingScheme: json['addressingScheme'] as String? ?? '',
        emergency: json['emergency'] as bool? ?? true,
        blockId: json['blockId'] as String? ?? '1',
        sceneId: json['sceneId'] as String? ?? '',
        out: json['out'] as String? ?? '',
        helvarType: json['helvarType'] as String? ?? 'emergency',
        subDeviceIndex: json['subDeviceIndex'] as int?,
        missing: json['missing'] as bool? ?? false,
        faulty: json['faulty'] as bool? ?? false,
        deviceTypeCode: json['deviceTypeCode'] as int?,
        deviceStateCode: json['deviceStateCode'] as int?,
        isButtonDevice: json['isButtonDevice'] as bool? ?? false,
        isMultisensor: json['isMultisensor'] as bool? ?? false,
        alarmGroupIds:
            (json['alarmGroupIds'] as List?)?.cast<String>() ??
            (json['alarmGroupId'] != null ? [json['alarmGroupId']] : []),
        sensorInfo: json['sensorInfo'] != null
            ? Map<String, dynamic>.from(json['sensorInfo'] as Map)
            : {},
        outputPoints: outputPoints,
        lastMessageTime: parsedLastMessageTime,
      );
    }
  }

  void started();
  void stopped();
  void recallScene(String sceneParams);
  void clearResult() {
    out = "";
  }

  String? performAction(DeviceAction action, dynamic value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelvarDevice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listEquals(alarmGroupIds, other.alarmGroupIds);

  @override
  int get hashCode => Object.hash(id, Object.hashAll(alarmGroupIds));

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'address': address,
      'state': state,
      'description': description,
      'name': name,
      'props': props,
      'iconPath': iconPath,
      'hexId': hexId,
      'addressingScheme': addressingScheme,
      'emergency': emergency,
      'blockId': blockId,
      'sceneId': sceneId,
      'out': out,
      'helvarType': helvarType,
      'subDeviceIndex': subDeviceIndex,
      'deviceTypeCode': deviceTypeCode,
      'deviceStateCode': deviceStateCode,
      'isButtonDevice': isButtonDevice,
      'isMultisensor': isMultisensor,
      'alarmGroupIds': alarmGroupIds,
      'sensorInfo': sensorInfo,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
    };
  }

  String getIconPath() => iconPath;
  void setIconPath(String path) {
    iconPath = path;
  }
}
