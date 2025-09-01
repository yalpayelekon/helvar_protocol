import '../../protocol/device_types.dart';
import '../../protocol/input_points_catalog.dart' as points_catalog;
import '../../utils/core/path_utils.dart';
import '../../utils/device_utils.dart';
import 'helvar_device.dart';
import 'input_point.dart';
import 'device_point_status.dart';

class HelvarDriverInputDevice extends HelvarDevice {
  List<InputPoint> inputPoints;

  HelvarDriverInputDevice({
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
    super.blockId,
    super.sceneId,
    super.out,
    super.helvarType = "input",
    super.deviceTypeCode,
    super.deviceStateCode,
    super.isButtonDevice,
    super.isMultisensor,
    super.sensorInfo,
    super.subDeviceIndex,
    List<InputPoint>? inputPoints,
  }) : inputPoints = inputPoints ?? [];

  /// Resets transient state when a router disconnects.
  void resetOnDisconnect() {
    deviceStateCode = null;
    state = DevicePointStatus.notAvailable.displayString;
    for (final point in inputPoints) {
      point.status = DevicePointStatus.notAvailable;
      point.value = null;
    }
  }

  void createInputPoints(
    String deviceAddress,
    String pointProps,
    String subAddress,
  ) {
    inputPoints.clear();

    final deviceName = description.isEmpty ? 'Device_$deviceId' : description;

    final catalogSpecs = points_catalog.pointSpecsForTypeCode(
      deviceTypeCode ?? 0,
    );
    if (catalogSpecs != null && catalogSpecs.isNotEmpty) {
      inputPoints.add(
        InputPoint(
          id: generateId('${deviceName}_Missing'),
          name: '${deviceName}_Missing',
          pointId: 0,
          pointType: InputPointType.missing,
        ),
      );
      for (final spec in catalogSpecs) {
        final type = points_catalog.pointTypeFromLabel(spec.label);
        inputPoints.add(
          InputPoint(
            id: generateId('${deviceName}_${spec.label.replaceAll(' ', '')}'),
            name: '${deviceName}_${spec.label.replaceAll(' ', '')}',
            pointId: spec.id,
            pointType: type,
          ),
        );
      }
      return;
    }

    final lowerProps = pointProps.toLowerCase();
    final descLower = description.toLowerCase();

    final buttonMatch =
        RegExp(r'(\d+)\s*button').firstMatch(lowerProps) ??
        RegExp(r'(\d+)\s*button').firstMatch(descLower);
    if (buttonMatch != null) {
      final count = int.tryParse(buttonMatch.group(1)!) ?? 1;
      final includeIr = lowerProps.contains('ir');
      inputPoints.addAll(
        generateStandardButtonPoints(
          deviceName,
          buttonCount: count,
          includeIr: includeIr,
        ),
      );
      return;
    }

    if (isButtonDevice(deviceTypeCode!) && deviceTypeCode != null) {
      final count = getButtonCountForTypeCode(deviceTypeCode!);
      if (count != null) {
        final includeIr = lowerProps.contains('ir');
        inputPoints.addAll(
          generateStandardButtonPoints(
            deviceName,
            buttonCount: count,
            includeIr: includeIr,
          ),
        );
        return;
      }
    }

    if (lowerProps.contains('slider')) {
      inputPoints.add(
        InputPoint(
          id: generateId('${deviceName}_Slider'),
          name: '${deviceName}_Slider',
          pointId: 1,
          pointType: InputPointType.slider,
        ),
      );
    }

    if (lowerProps.contains('pir')) {
      inputPoints.add(
        InputPoint(
          id: generateId('${deviceName}_PIR'),
          name: '${deviceName}_PIR',
          pointId: 2,
          pointType: InputPointType.pir,
        ),
      );
    }

    if (lowerProps.contains('light')) {
      inputPoints.add(
        InputPoint(
          id: generateId('${deviceName}_LightSensor'),
          name: '${deviceName}_LightSensor',
          pointId: 3,
          pointType: InputPointType.lightSensor,
        ),
      );
    }

    if (lowerProps.contains('push')) {
      inputPoints.add(
        InputPoint(
          id: generateId('${deviceName}_Push'),
          name: '${deviceName}_Push',
          pointId: 4,
          pointType: InputPointType.pushOnOff,
        ),
      );
    }

    if (inputPoints.isEmpty) {
      inputPoints.add(
        InputPoint(
          id: generateId('${deviceName}_Missing'),
          name: '${deviceName}_Missing',
          pointId: 0,
          pointType: InputPointType.missing,
        ),
      );
    }
  }

  void generateButtonPoints() {
    if (!isButtonDevice(deviceTypeCode!)) return;
    inputPoints
      ..clear()
      ..addAll(
        generateStandardButtonPoints(
          description.isEmpty ? "Device_$deviceId" : description,
        ),
      );
  }
}
