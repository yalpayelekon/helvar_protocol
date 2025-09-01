import '../../protocol/protocol_utils.dart';
import '../../utils/core/path_utils.dart';

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
  String blockId;
  String sceneId;
  String out;
  String helvarType;

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
    this.blockId = "1",
    this.sceneId = "",
    this.out = "",
    this.helvarType = "output",
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
}
