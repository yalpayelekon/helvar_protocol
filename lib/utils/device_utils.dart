import 'package:simulator/utils/core/path_utils.dart';
import '../../models/helvar_models/device_point_status.dart';
import '../../models/helvar_models/input_point.dart';

/// Generate standard input points for a button device.
///
/// [buttonCount] controls the number of button points created. When
/// [includeIr] is true, seven IR points (ids 101–107) are added
/// regardless of the button count.
List<InputPoint> generateStandardButtonPoints(
  String deviceName, {
  int buttonCount = 7,
  bool includeIr = true,
}) {
  final points = <InputPoint>[];
  points.add(
    InputPoint(
      id: generateId('${deviceName}_Missing'),
      name: '${deviceName}_Missing',
      pointId: 0,
      pointType: InputPointType.missing,
    ),
  );
  for (int i = 1; i <= buttonCount; i++) {
    points.add(
      InputPoint(
        id: generateId('${deviceName}_Button$i'),
        name: '${deviceName}_Button$i',
        pointId: i,
        pointType: InputPointType.button,
      ),
    );
  }
  if (includeIr) {
    for (int i = 1; i <= 7; i++) {
      points.add(
        InputPoint(
          id: generateId('${deviceName}_IR$i'),
          name: '${deviceName}_IR$i',
          pointId: i + 100,
          pointType: InputPointType.ir,
        ),
      );
    }
  }
  return points;
}

String handleRecallScene(String sceneParams, {bool logInfoOutput = false}) {
  if (sceneParams.isNotEmpty) {
    List<String> temp = sceneParams.split(',');
    String timestamp = DateTime.now().toString();
    String s =
        "Success ($timestamp) Recalled Scene: ${temp.length > 1 ? temp[1] : temp[0]}";
    if (logInfoOutput) {
      print(s);
    }
    return s;
  } else {
    print("Please pass a valid scene number!");
    return "Please pass a valid scene number!";
  }
}

DevicePointStatus decodeDeviceStatus(String value) {
  if (value == '4294967295') {
    return DevicePointStatus.faultStale;
  }
  return DevicePointStatus.available;
}
