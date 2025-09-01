import 'package:simulator/utils/core/path_utils.dart';
import 'package:simulator/utils/device_utils.dart';

import 'output_point.dart';
import '../../protocol/query_commands.dart';
import 'device_action.dart';
import 'helvar_device.dart';
import 'device_point_status.dart';

class HelvarDriverOutputDevice extends HelvarDevice {
  bool missing;
  bool faulty;
  int? level;
  int proportion;
  double powerConsumption;
  List<OutputPoint> outputPoints;

  HelvarDriverOutputDevice({
    required super.id,
    super.deviceId,
    super.address,
    super.state,
    super.description,
    super.name,
    super.props,
    super.iconPath,
    super.hexId,
    super.addressingScheme,
    super.emergency,
    super.blockId,
    super.sceneId,
    super.out,
    super.helvarType = "output",
    super.deviceTypeCode,
    super.deviceStateCode,
    super.isButtonDevice,
    super.isMultisensor,
    super.alarmGroupIds,
    super.sensorInfo,
    super.subDeviceIndex,
    super.lastMessageTime,
    this.missing = false,
    this.faulty = false,
    this.level,
    this.proportion = 0,
    this.powerConsumption = 0,
    List<OutputPoint>? outputPoints,
  }) : outputPoints = outputPoints ?? [];

  /// Resets transient state when a router disconnects.
  void resetOnDisconnect() {
    deviceStateCode = null;
    state = DevicePointStatus.notAvailable.displayString;
    level = null;

    final levelPoint = getPointById(5);
    if (levelPoint != null) {
      levelPoint.status = DevicePointStatus.notAvailable;
      levelPoint.value = null;
    }
  }

  HelvarDriverOutputDevice copyWith({
    String? id,
    int? deviceId,
    String? address,
    String? state,
    String? description,
    String? name,
    String? props,
    String? iconPath,
    String? hexId,
    String? addressingScheme,
    bool? emergency,
    String? blockId,
    String? sceneId,
    String? out,
    String? helvarType,
    int? subDeviceIndex,
    int? deviceTypeCode,
    int? deviceStateCode,
    bool? isButtonDevice,
    bool? isMultisensor,
    List<String>? alarmGroupIds,
    Map<String, dynamic>? sensorInfo,
    DateTime? lastMessageTime,
    bool? missing,
    bool? faulty,
    int? level,
    int? proportion,
    double? powerConsumption,
    List<OutputPoint>? outputPoints,
  }) {
    return HelvarDriverOutputDevice(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      address: address ?? this.address,
      state: state ?? this.state,
      description: description ?? this.description,
      name: name ?? this.name,
      props: props ?? this.props,
      iconPath: iconPath ?? this.iconPath,
      hexId: hexId ?? this.hexId,
      addressingScheme: addressingScheme ?? this.addressingScheme,
      emergency: emergency ?? this.emergency,
      blockId: blockId ?? this.blockId,
      sceneId: sceneId ?? this.sceneId,
      out: out ?? this.out,
      helvarType: helvarType ?? this.helvarType,
      subDeviceIndex: subDeviceIndex ?? this.subDeviceIndex,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      deviceTypeCode: deviceTypeCode ?? this.deviceTypeCode,
      deviceStateCode: deviceStateCode ?? this.deviceStateCode,
      isButtonDevice: isButtonDevice ?? this.isButtonDevice,
      isMultisensor: isMultisensor ?? this.isMultisensor,
      alarmGroupIds: alarmGroupIds ?? List<String>.from(this.alarmGroupIds),
      sensorInfo: sensorInfo ?? Map<String, dynamic>.from(this.sensorInfo),
      missing: missing ?? this.missing,
      faulty: faulty ?? this.faulty,
      level: level ?? this.level,
      proportion: proportion ?? this.proportion,
      powerConsumption: powerConsumption ?? this.powerConsumption,
      outputPoints: outputPoints ?? List<OutputPoint>.from(this.outputPoints),
    );
  }

  @override
  void recallScene(String sceneParams) {
    out = handleRecallScene(sceneParams);
  }

  String? directLevel(String levelParams) {
    try {
      var parts = levelParams.split(',');
      if (parts.length == 1) {
        parts.add('0');
      }
      if (parts.length != 2) {
        throw const FormatException(
          'Expected two comma separated values for level and fade time',
        );
      }

      final level = int.parse(parts[0].trim());
      final fade = int.parse(parts[1].trim());

      if (level < 0 || level > 100) {
        throw RangeError('Level must be between 0 and 100');
      }
      if (fade < 0 || fade > 65535) {
        throw RangeError('Fade time must be between 0 and 65535');
      }

      final command = HelvarNetCommands.directLevelDevice(
        address,
        level,
        fadeTime: fade,
      );

      final timestamp = DateTime.now().toString();
      final s = 'Success ($timestamp) Direct Level Device: $level Fade: $fade';
      print(s);
      out = s;
      return command;
    } on FormatException catch (e) {
      print('Failed to parse level parameters "$levelParams": $e');
      out = 'Failed to parse level parameters';
    } on RangeError catch (e) {
      print(e.toString());
      out = e.toString();
    }
    return null;
  }

  String? directProportion(String proportionParams) {
    try {
      var parts = proportionParams.split(',');
      if (parts.length == 1) {
        parts.add('0');
      }
      if (parts.length != 2) {
        throw const FormatException(
          'Expected two comma separated values for proportion and fade time',
        );
      }

      final proportion = int.parse(parts[0].trim());
      final fade = int.parse(parts[1].trim());

      if (proportion < -100 || proportion > 100) {
        throw RangeError('Proportion must be between -100 and 100');
      }
      if (fade < 0 || fade > 65535) {
        throw RangeError('Fade time must be between 0 and 65535');
      }

      final addrParts = address.split('.');
      if (addrParts.length < 4) {
        throw FormatException('Invalid device address "$address"');
      }
      final cluster = int.parse(addrParts[0]);
      final router = int.parse(addrParts[1]);
      final subnet = int.parse(addrParts[2]);
      final device = int.parse(addrParts[3]);
      final subDevice = addrParts.length > 4 ? int.parse(addrParts[4]) : null;

      final command = HelvarNetCommands.directProportionDevice(
        cluster,
        router,
        subnet,
        device,
        proportion,
        subDevice: subDevice,
        fadeTime: fade,
      );

      final timestamp = DateTime.now().toString();
      final s =
          'Success ($timestamp) Direct Proportion Device: $proportion Fade: $fade';
      out = s;
      print(s);
      return command;
    } on FormatException catch (e) {
      print('Failed to parse proportion parameters "$proportionParams": $e');
      out = 'Failed to parse proportion parameters';
    } on RangeError catch (e) {
      print(e.toString());
      out = e.toString();
    }
    return null;
  }

  void modifyProportion(String proportionParams) {
    try {
      List<String> temp = proportionParams.split(',');
      String timestamp = DateTime.now().toString();
      String s = "Success ($timestamp) Direct Proportion Device: ${temp[0]}";
      print(s);
      out = s;
    } catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  @override
  void started() {
    generateOutputPoints();
  }

  String getName() {
    return description.isNotEmpty ? description : "Device_$deviceId";
  }

  @override
  void stopped() {}

  @override
  String? performAction(DeviceAction action, dynamic value) {
    switch (action) {
      case DeviceAction.clearResult:
        clearResult();
        break;
      case DeviceAction.recallScene:
        if (value is int) {
          recallScene("1,$value");
        }
        break;
      case DeviceAction.directLevel:
        if (value is String) {
          return directLevel(value);
        } else if (value is num) {
          return directLevel('$value');
        }
        break;
      case DeviceAction.directProportion:
        if (value is String) {
          return directProportion(value);
        } else if (value is num) {
          return directProportion('$value');
        }
        break;
      case DeviceAction.modifyProportion:
        if (value is int) {
          modifyProportion("$value");
        }
        break;
      default:
        print("Action $action not supported for output device");
    }
    return null;
  }

  void generateOutputPoints() {
    if (outputPoints.isNotEmpty) return;

    final deviceName = description.isEmpty ? "Device_$deviceId" : description;

    outputPoints.addAll(
      OutputPointName.values.map(
        (type) => OutputPoint(
          id: generateId(type.nameForDevice(deviceName)),
          name: type.nameForDevice(deviceName),
          function: type.functionName,
          pointId: type.id,
          pointType: type.pointType,
          value: type.defaultValue,
        ),
      ),
    );
  }

  Future<void> updatePointValue(int pointId, dynamic value) async {
    final point = outputPoints.firstWhere(
      (p) => p.pointId == pointId,
      orElse: () => throw ArgumentError('Point with ID $pointId not found'),
    );

    point.value = value;
    //print('Updated point ${point.name} to value: $value');
  }

  OutputPoint? getPointById(int pointId) {
    try {
      return outputPoints.firstWhere((p) => p.pointId == pointId);
    } catch (e) {
      return null;
    }
  }

  OutputPoint? getPointByName(String name) {
    try {
      return outputPoints.firstWhere((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['missing'] = missing;
    json['faulty'] = faulty;
    json['level'] = level;
    json['proportion'] = proportion;
    json['outputPoints'] = outputPoints.map((point) => point.toJson()).toList();
    return json;
  }
}
