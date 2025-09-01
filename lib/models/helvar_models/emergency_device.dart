import 'package:simulator/utils/core/path_utils.dart';

import 'device_action.dart';
import 'helvar_device.dart';
import 'output_point.dart';

class HelvarDriverEmergencyDevice extends HelvarDevice {
  bool missing;
  bool faulty;
  List<OutputPoint> outputPoints;

  HelvarDriverEmergencyDevice({
    required super.id,
    super.deviceId,
    super.address,
    super.state,
    super.description,
    super.props,
    super.name,
    super.iconPath,
    super.hexId,
    super.addressingScheme,
    super.emergency = true,
    super.blockId,
    super.sceneId,
    super.out,
    super.helvarType = "emergency",
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
    List<OutputPoint>? outputPoints,
  }) : outputPoints = outputPoints ?? [];

  @override
  void recallScene(String sceneParams) {
    throw UnimplementedError("Emergency devices do not support scene recall");
  }

  @override
  String? performAction(DeviceAction action, dynamic value) {
    switch (action) {
      case DeviceAction.clearResult:
        clearResult();
        break;
      case DeviceAction.emergencyFunctionTest:
        emergencyFunctionTest();
        break;
      case DeviceAction.emergencyDurationTest:
        emergencyDurationTest();
        break;
      case DeviceAction.stopEmergencyTest:
        stopEmergencyTest();
        break;
      case DeviceAction.resetEmergencyBattery:
        resetEmergencyBatteryTotalLampTime();
        break;
      default:
        print("Action $action not supported for emergency device");
    }
    return null;
  }

  void emergencyFunctionTest() {
    try {
      String timestamp = DateTime.now().toString();
      String s = "Success ($timestamp) Emergency Test for device $address";
      out = s;
    } catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void emergencyDurationTest() {
    try {
      String timestamp = DateTime.now().toString();
      String s = "Success ($timestamp) Emergency Test for device $address";
      out = s;
    } catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void stopEmergencyTest() {
    try {
      String timestamp = DateTime.now().toString();
      String s = "Success ($timestamp) Emergency Test for device $address";
      out = s;
    } catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmergencyFunctionTestTime() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmergencyFunctionTestState() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmergencyDurationTestTime() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmergencyDurationTestState() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmergencyBatteryCharge() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmergencyBatteryTime() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmergencyTotalLampTime() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmergencyBatteryEndurance() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void queryEmdtActualTestDuration() {
    try {} catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  void resetEmergencyBatteryTotalLampTime() {
    try {
      String timestamp = DateTime.now().toString();
      String s =
          "Success ($timestamp) Reset Emergency Battery and Total Lamp Time for device $address";
      out = s;
    } catch (e) {
      print(e.toString());
      out = e.toString();
    }
  }

  @override
  void started() {
    createOutputEmergencyPoints(
      address,
      description.isEmpty ? 'Device_\$deviceId' : description,
    );
  }

  @override
  void stopped() {}

  void createOutputEmergencyPoints(String deviceAddress, String name) {
    if (outputPoints.isNotEmpty) return;

    outputPoints.addAll(
      EmergencyOutputPointName.values.map(
        (type) => OutputPoint(
          id: generateId(type.nameForDevice(name)),
          name: type.nameForDevice(name),
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
      orElse: () => throw ArgumentError('Point with ID \$pointId not found'),
    );

    point.value = value;
    print('Updated emergency point \${point.name} to value: \$value');
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

  HelvarDriverEmergencyDevice copyWith({
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
    List<OutputPoint>? outputPoints,
  }) {
    return HelvarDriverEmergencyDevice(
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
      deviceTypeCode: deviceTypeCode ?? this.deviceTypeCode,
      deviceStateCode: deviceStateCode ?? this.deviceStateCode,
      isButtonDevice: isButtonDevice ?? this.isButtonDevice,
      isMultisensor: isMultisensor ?? this.isMultisensor,
      alarmGroupIds: alarmGroupIds ?? List<String>.from(this.alarmGroupIds),
      sensorInfo: sensorInfo ?? Map<String, dynamic>.from(this.sensorInfo),
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      missing: missing ?? this.missing,
      faulty: faulty ?? this.faulty,
      outputPoints: outputPoints ?? List<OutputPoint>.from(this.outputPoints),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['missing'] = missing;
    json['faulty'] = faulty;
    json['outputPoints'] = outputPoints.map((p) => p.toJson()).toList();
    return json;
  }
}
