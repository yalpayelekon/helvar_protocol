import 'client.dart';

void main(List<String> args) async {
  final routerIP = args.isNotEmpty ? args[0] : '10.11.10.150';
  final client = HelvarNetClient(routerIP);

  print('HelvarNet Device Query Test');
  print('==========================');
  print('Router IP: $routerIP\n');

  try {
    print('Discovering router information...');
    final router = await client.discoverRouterInfo();

    if (router != null) {
      print('\nRouter found:');
      print('- Address: @${router.routerAddress}');
      print('- Cluster ID: ${router.clusterId}');
      print('- Cluster Member ID: ${router.clusterMemberId}');
      print('- Type: ${router.deviceType}');
      print('- Description: ${router.description}');
      print(
          '- State: ${router.deviceState} [Code: ${router.deviceStateCode ?? "Unknown"}]');

      print('\nDiscovering devices on all subnets...');
      await client.discoverAllDevices(router);

      int totalDevices = 0;
      router.devicesBySubnet.forEach((subnet, devices) {
        totalDevices += devices.length;
      });

      print(
          '\nSummary: Found $totalDevices devices across ${router.devicesBySubnet.length} subnets');

      router.devicesBySubnet.forEach((subnet, devices) {
        print('\nSubnet $subnet (${devices.length} devices):');
        for (final device in devices) {
          print(
              '  @${device.address}: ${device.description ?? "No description"}');
          print(
              '    Type: ${device.deviceType} [Code: ${device.deviceTypeCode}]');
          print(
              '    State: ${device.deviceState} [Code: ${device.deviceStateCode}]');

          if (device.isButtonDevice && device.buttonPoints.isNotEmpty) {
            print('    Button Points (${device.buttonPoints.length}):');
            for (final point in device.buttonPoints) {
              print('      - ${point.name} (${point.function})');
            }
          }

          if (device.isMultisensor) {
            print('    Sensor Capabilities:');
            device.sensorInfo.forEach((key, value) {
              print('      - $key: $value');
            });
          }
        }
      });
    } else {
      print('Router not found or not responding');
    }
  } catch (e) {
    print('Error: $e');
    print(e.toString());
  }

  print('\nTest completed.');
}
