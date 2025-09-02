import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

void main() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 8080);
  print(
      'HelvarNet Simulator running on ${server.address.address}:${server.port}');
  print('Protocol version: 2.0');
  print(
      'Supported commands: 11-18, 19-24, 100-114, 129, 150-176, 185-191, 201-206');

  int clientId = 0;
  server.listen((Socket client) {
    clientId++;
    handleClient(client, clientId);
  });
}

// Enhanced system state with more realistic simulation
class SystemState {
  Map<int, int> groupScenes = {}; // Group ID -> Current Scene
  Map<int, int> groupLevels = {}; // Group ID -> Current Level (0-100%)
  Map<String, int> deviceLevels =
      {}; // Device address -> Current Level (0-100%)
  Map<int, int> blockScenes = {}; // Block ID -> Last Scene
  List<int> clusters = [1, 2]; // Available clusters
  Map<int, List<int>> clusterRouters = {
    1: [1, 2, 3],
    2: [1, 2],
  }; // Cluster ID -> Router IDs
  Map<int, String> groupDescriptions = {}; // Group ID -> Description
  Map<String, String> deviceDescriptions = {}; // Device address -> Description
  Map<String, int> deviceTypes = {}; // Device address -> Type
  Map<String, int> deviceStates = {}; // Device address -> State flags
  Map<String, bool> deviceDisabled = {}; // Device address -> Disabled state
  Map<String, bool> deviceMissing = {}; // Device address -> Missing state
  Map<String, bool> deviceFaulty = {}; // Device address -> Faulty state
  Map<String, bool> lampFailure = {}; // Device address -> Lamp failure
  Map<String, double> powerConsumption =
      {}; // Device address -> Power consumption
  Map<String, List<int>> deviceInputs = {}; // Device address -> Input values
  Map<String, String> sceneNames = {}; // Scene ID -> Scene name

  // Emergency lighting
  Map<String, DateTime> lastFunctionTestTime = {};
  Map<String, DateTime> lastDurationTestTime = {};
  Map<String, int> emergencyTestState =
      {}; // Device address -> Test state flags
  Map<String, double> batteryCharge = {}; // Device address -> Battery charge %
  Map<String, int> batteryTime = {}; // Device address -> Battery time remaining
  Map<String, int> totalLampTime = {}; // Device address -> Total lamp time

  // System info
  String workgroupName = "Test Workgroup";
  List<int> workgroupMembers = [1, 2];
  int softwareVersion = 67240448; // Represents version 4.2.2
  int helvarNetVersion = 20;
  String timeZone = "UTC+00:00";
  bool daylightSavingActive = false;

  SystemState() {
    _initializeDefaultData();
  }

  void _initializeDefaultData() {
    final random = Random();

    // Initialize groups
    for (int i = 1; i <= 16; i++) {
      groupDescriptions[i] = "Group $i";
      groupLevels[i] = random.nextInt(101);
      groupScenes[i] = random.nextInt(16) + 1;
    }

    // Initialize blocks
    for (int b = 1; b <= 8; b++) {
      blockScenes[b] = random.nextInt(16) + 1;
    }

    // Initialize scene names
    for (int s = 1; s <= 16; s++) {
      sceneNames[s.toString()] = "Scene $s";
    }

    // Create sample devices with various types
    final deviceTypeOptions = [
      0x0001, // Fluorescent Lamps
      0x0401, // Incandescent lamps
      0x0601, // LED modules
      0x0701, // Switching function
      0x100802, // Rotary controller
      0x121302, // 2 Button On/Off + IR
      0x125102, // 7 Button + IR
      0x311802, // PIR detector
      0x416002, // 16A Dimmer
    ];

    for (int c = 1; c <= 2; c++) {
      for (int r = 1; r <= (c == 1 ? 3 : 2); r++) {
        for (int s = 1; s <= 4; s++) {
          for (int d = 1; d <= 10; d++) {
            final address = "$c.$r.$s.$d";

            // Device properties
            deviceLevels[address] = random.nextInt(101);
            deviceDescriptions[address] = "Device $address";
            deviceTypes[address] =
                deviceTypeOptions[random.nextInt(deviceTypeOptions.length)];

            // Device states (realistic flags)
            deviceStates[address] = _generateRealisticDeviceState(random);
            deviceDisabled[address] = random.nextDouble() < 0.05; // 5% disabled
            deviceMissing[address] = random.nextDouble() < 0.02; // 2% missing
            deviceFaulty[address] = random.nextDouble() < 0.03; // 3% faulty
            lampFailure[address] =
                random.nextDouble() < 0.01; // 1% lamp failure

            // Power consumption (0-100W typically)
            powerConsumption[address] = random.nextDouble() * 100;

            // Input devices have input states
            if (_isInputDevice(deviceTypes[address]!)) {
              deviceInputs[address] =
                  List.generate(8, (i) => random.nextInt(256));
            }

            // Emergency lighting devices
            if (_isEmergencyDevice(deviceTypes[address]!)) {
              lastFunctionTestTime[address] = DateTime.now()
                  .subtract(Duration(days: random.nextInt(30) + 1));
              lastDurationTestTime[address] = DateTime.now()
                  .subtract(Duration(days: random.nextInt(90) + 1));
              emergencyTestState[address] = random.nextInt(64);
              batteryCharge[address] = random.nextDouble() * 100;
              batteryTime[address] = random.nextInt(180) + 60; // 60-240 minutes
              totalLampTime[address] = random.nextInt(10000); // 0-10000 hours
            }
          }
        }
      }
    }
  }

  int _generateRealisticDeviceState(Random random) {
    int state = 0;

    // Normal operation most of the time
    if (random.nextDouble() < 0.8) return 0;

    // Occasional states
    if (random.nextDouble() < 0.05) state |= 0x00000001; // Disabled
    if (random.nextDouble() < 0.02) state |= 0x00000002; // Lamp Failure
    if (random.nextDouble() < 0.01) state |= 0x00000004; // Missing
    if (random.nextDouble() < 0.02) state |= 0x00000008; // Faulty
    if (random.nextDouble() < 0.10) state |= 0x00000010; // Refreshing

    return state;
  }

  bool _isInputDevice(int typeCode) {
    final inputTypes = [0x100802, 0x121302, 0x125102, 0x311802];
    return inputTypes.contains(typeCode);
  }

  bool _isEmergencyDevice(int typeCode) {
    final emergencyTypes = [0x0101]; // Self-contained emergency lighting
    return emergencyTypes.contains(typeCode) || Random().nextDouble() < 0.1;
  }
}

void handleClient(Socket client, int id) {
  print(
      'Client $id connected: ${client.remoteAddress.address}:${client.remotePort}');

  final SystemState state = SystemState();
  Timer? eventTimer;

  final subscription = client.listen((data) {
    final message = utf8.decode(data).trim();
    print('[$id] Received: $message');

    if (message == 'get_status') {
      client.write('status: OK\n');
      return;
    }

    // HelvarNet protocol message handling
    if (message.startsWith('>')) {
      final response = processHelvarNetCommand(message, state);
      if (response.isNotEmpty) {
        print('[$id] Sending: $response');
        client.write('$response\n');
      }
    }
  }, onError: (error) {
    print('Client $id error: $error');
  });

  // Enhanced event simulation
  eventTimer = Timer.periodic(Duration(seconds: 5 + Random().nextInt(10)), (_) {
    try {
      _simulateRandomEvent(client, state, id);
    } catch (e) {
      // Handle potential write to closed socket
      print('Error sending event to client $id: $e');
    }
  });

  client.done.then((_) {
    print('Client $id disconnected.');
    subscription.cancel();
    eventTimer?.cancel();
    client.destroy();
  });
}

void _simulateRandomEvent(Socket client, SystemState state, int clientId) {
  final random = Random();
  final eventType = random.nextInt(4);

  switch (eventType) {
    case 0: // Group level change
      final groupId = random.nextInt(16) + 1;
      final newLevel = random.nextInt(101);
      state.groupLevels[groupId] = newLevel;
      final event = '!V:2,C:152,G:$groupId=Level changed to $newLevel#';
      client.write('$event\n');
      print('[$clientId] Event: Group $groupId level changed to $newLevel%');
      break;

    case 1: // Device state change
      final devices = state.deviceLevels.keys.toList();
      if (devices.isNotEmpty) {
        final address = devices[random.nextInt(devices.length)];
        final newLevel = random.nextInt(101);
        state.deviceLevels[address] = newLevel;
        final event = '!V:2,C:152,@$address=Device level changed to $newLevel#';
        client.write('$event\n');
        print('[$clientId] Event: Device $address level changed to $newLevel%');
      }
      break;

    case 2: // Scene recall event
      final groupId = random.nextInt(16) + 1;
      final block = random.nextInt(8) + 1;
      final scene = random.nextInt(16) + 1;
      state.groupScenes[groupId] = scene;
      state.blockScenes[block] = scene;
      final event = '!V:2,C:11,G:$groupId,B:$block,S:$scene=Scene recalled#';
      client.write('$event\n');
      print('[$clientId] Event: Scene $scene recalled for group $groupId');
      break;

    case 3: // Input device event
      final inputDevices = state.deviceInputs.keys.toList();
      if (inputDevices.isNotEmpty) {
        final address = inputDevices[random.nextInt(inputDevices.length)];
        final point = random.nextInt(8) + 1;
        final value = random.nextInt(256);
        final event = '!V:2,C:151,@$address,P:$point=Input changed to $value#';
        client.write('$event\n');
        print(
            '[$clientId] Event: Input device $address point $point changed to $value');
      }
      break;
  }
}

// Parse command parameters from a HelvarNet ASCII message
Map<String, String> parseParameters(String message) {
  final params = <String, String>{};

  // Remove start and end characters
  if (message.length < 3) return params;
  message = message.substring(1, message.length - 1);

  final parts = message.split(',');
  for (final part in parts) {
    final keyValue = part.split(':');
    if (keyValue.length == 2) {
      params[keyValue[0]] = keyValue[1];
    }
  }

  return params;
}

String processHelvarNetCommand(String message, SystemState state) {
  if (!message.startsWith('>') || !message.endsWith('#')) {
    return '!V:2,Error - Invalid message format#';
  }

  final params = parseParameters(message);

  // Get the command number
  final commandStr = params['C'];
  if (commandStr == null) {
    return '!V:2,Error - Missing command parameter#';
  }

  final command = int.tryParse(commandStr);
  if (command == null) {
    return '!V:2,Error - Invalid command parameter#';
  }

  // Process based on command number
  switch (command) {
    // Control Commands (11-18)
    case 11:
      return handleRecallSceneGroup(params, state);
    case 12:
      return handleRecallSceneDevice(params, state);
    case 13:
      return handleDirectLevelGroup(params, state);
    case 14:
      return handleDirectLevelDevice(params, state);
    case 15:
      return handleDirectProportionGroup(params, state);
    case 16:
      return handleDirectProportionDevice(params, state);
    case 17:
      return handleModifyProportionGroup(params, state);
    case 18:
      return handleModifyProportionDevice(params, state);

    // Emergency Commands (19-24)
    case 19:
      return handleEmergencyFunctionTestGroup(params, state);
    case 20:
      return handleEmergencyFunctionTestDevice(params, state);
    case 21:
      return handleEmergencyDurationTestGroup(params, state);
    case 22:
      return handleEmergencyDurationTestDevice(params, state);
    case 23:
      return handleStopEmergencyTestsGroup(params, state);
    case 24:
      return handleStopEmergencyTestsDevice(params, state);

    // Query Commands (100-114)
    case 100:
      return handleQueryDeviceTypesAndAddresses(params, state);
    case 101:
      return handleQueryClusters(params, state);
    case 102:
      return handleQueryRouters(params, state);
    case 103:
      return handleQueryLSIB(params, state);
    case 104:
      return handleQueryDeviceType(params, state);
    case 105:
      return handleQueryDescriptionGroup(params, state);
    case 106:
      return handleQueryDescriptionDevice(params, state);
    case 107:
      return handleQueryWorkgroupName(params, state);
    case 108:
      return handleQueryWorkgroupMembership(params, state);
    case 109:
      return handleQueryLSIG(params, state);
    case 110:
      return handleQueryDeviceState(params, state);
    case 111:
      return handleQueryDeviceIsDisabled(params, state);
    case 112:
      return handleQueryLampFailure(params, state);
    case 113:
      return handleQueryDeviceIsMissing(params, state);
    case 114:
      return handleQueryDeviceIsFaulty(params, state);

    // Additional Query Commands
    case 129:
      return handleQueryEmergencyBatteryFailure(params, state);
    case 150:
      return handleQueryMeasurement(params, state);
    case 151:
      return handleQueryInputs(params, state);
    case 152:
      return handleQueryLoadLevel(params, state);
    case 160:
      return handleQueryPowerConsumption(params, state);
    case 161:
      return handleQueryGroupPowerConsumption(params, state);
    case 164:
      return handleQueryGroup(params, state);
    case 165:
      return handleQueryGroups(params, state);
    case 166:
      return handleQuerySceneNames(params, state);
    case 167:
      return handleQuerySceneInfo(params, state);

    // Emergency Query Commands (170-176)
    case 170:
      return handleQueryEmergencyFunctionTestTime(params, state);
    case 171:
      return handleQueryEmergencyFunctionTestState(params, state);
    case 172:
      return handleQueryEmergencyDurationTestTime(params, state);
    case 173:
      return handleQueryEmergencyDurationTestState(params, state);
    case 174:
      return handleQueryEmergencyBatteryCharge(params, state);
    case 175:
      return handleQueryEmergencyBatteryTime(params, state);
    case 176:
      return handleQueryEmergencyTotalLampTime(params, state);

    // System Query Commands (185-191)
    case 185:
      return handleQueryTime(params, state);
    case 188:
      return handleQueryTimeZone(params, state);
    case 189:
      return handleQueryDaylightSavingTime(params, state);
    case 190:
      return handleQuerySoftwareVersion(params, state);
    case 191:
      return handleQueryHelvarNetVersion(params, state);

    // Store Commands (201-206)
    case 201:
      return handleStoreSceneGroup(params, state);
    case 202:
      return handleStoreSceneDevice(params, state);
    case 203:
      return handleStoreAsSceneGroup(params, state);
    case 204:
      return handleStoreAsSceneDevice(params, state);
    case 205:
      return handleResetEmergencyGroup(params, state);
    case 206:
      return handleResetEmergencyDevice(params, state);

    default:
      return '!V:2,Error - Unsupported command: $command#';
  }
}

// Control Command Handlers
String handleRecallSceneGroup(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final blockStr = params['B'];
  final sceneStr = params['S'];

  if (groupStr == null || blockStr == null || sceneStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final block = int.tryParse(blockStr);
  final scene = int.tryParse(sceneStr);

  if (group == null || block == null || scene == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (group < 1 ||
      group > 16383 ||
      block < 1 ||
      block > 8 ||
      scene < 1 ||
      scene > 16) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Update system state
  state.groupScenes[group] = scene;
  state.blockScenes[block] = scene;

  // Simulate level changes based on scene
  final sceneLevel = (scene - 1) * 6 + Random().nextInt(20); // 0-100 range
  state.groupLevels[group] = sceneLevel.clamp(0, 100);

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:2,C:11,G:$group,B:$block,S:$scene=0#';
  }

  return '';
}

String handleRecallSceneDevice(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  final blockStr = params['B'];
  final sceneStr = params['S'];

  if (addressStr == null || blockStr == null || sceneStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final block = int.tryParse(blockStr);
  final scene = int.tryParse(sceneStr);

  if (block == null || scene == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (block < 1 || block > 8 || scene < 1 || scene > 16) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Update system state
  final sceneLevel = (scene - 1) * 6 + Random().nextInt(20);
  state.deviceLevels[addressStr] = sceneLevel.clamp(0, 100);
  state.blockScenes[block] = scene;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:2,C:12,@:$addressStr,B:$block,S:$scene=0#';
  }

  return '';
}

String handleDirectLevelGroup(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final levelStr = params['L'];

  if (groupStr == null || levelStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final level = int.tryParse(levelStr);

  if (group == null || level == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (group < 1 || group > 16383 || level < 0 || level > 100) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Update system state
  state.groupLevels[group] = level;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:2,C:13,G:$group,L:$level=0#';
  }

  return '';
}

String handleDirectLevelDevice(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  final levelStr = params['L'];

  if (addressStr == null || levelStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final level = int.tryParse(levelStr);

  if (level == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (level < 0 || level > 100) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Update system state
  state.deviceLevels[addressStr] = level;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:2,C:14,@:$addressStr,L:$level=0#';
  }

  return '';
}

String handleDirectProportionGroup(
    Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final proportionStr = params['P'];

  if (groupStr == null || proportionStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final proportion = int.tryParse(proportionStr);

  if (group == null || proportion == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (group < 1 || group > 16383 || proportion < -100 || proportion > 100) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Update system state based on proportion calculation
  final currentLevel = state.groupLevels[group] ?? 50;
  int newLevel;

  if (proportion >= 0) {
    // Positive proportion - increase toward 100%
    final difference = 100 - currentLevel;
    final increase = (difference * proportion / 100).round();
    newLevel = currentLevel + increase;
  } else {
    // Negative proportion - decrease toward 0%
    final decrease = (currentLevel * proportion.abs() / 100).round();
    newLevel = currentLevel - decrease;
  }

  state.groupLevels[group] = newLevel.clamp(0, 100);

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:2,C:15,G:$group,P:$proportion=0#';
  }

  return '';
}

String handleDirectProportionDevice(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  final proportionStr = params['P'];

  if (addressStr == null || proportionStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final proportion = int.tryParse(proportionStr);

  if (proportion == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (proportion < -100 || proportion > 100) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Update system state based on proportion calculation
  final currentLevel = state.deviceLevels[addressStr] ?? 50;
  int newLevel;

  if (proportion >= 0) {
    final difference = 100 - currentLevel;
    final increase = (difference * proportion / 100).round();
    newLevel = currentLevel + increase;
  } else {
    final decrease = (currentLevel * proportion.abs() / 100).round();
    newLevel = currentLevel - decrease;
  }

  state.deviceLevels[addressStr] = newLevel.clamp(0, 100);

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:2,C:16,@:$addressStr,P:$proportion=0#';
  }

  return '';
}

String handleModifyProportionGroup(
    Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final proportionStr = params['P'];

  if (groupStr == null || proportionStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final proportion = int.tryParse(proportionStr);

  if (group == null || proportion == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (group < 1 || group > 16383 || proportion < -100 || proportion > 100) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Modify current level by the proportion
  final currentLevel = state.groupLevels[group] ?? 50;
  final change = (currentLevel * proportion / 100).round();
  final newLevel = (currentLevel + change).clamp(0, 100);

  state.groupLevels[group] = newLevel;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:2,C:17,G:$group,P:$proportion=0#';
  }

  return '';
}

String handleModifyProportionDevice(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  final proportionStr = params['P'];

  if (addressStr == null || proportionStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final proportion = int.tryParse(proportionStr);

  if (proportion == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (proportion < -100 || proportion > 100) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Modify current level by the proportion
  final currentLevel = state.deviceLevels[addressStr] ?? 50;
  final change = (currentLevel * proportion / 100).round();
  final newLevel = (currentLevel + change).clamp(0, 100);

  state.deviceLevels[addressStr] = newLevel;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:2,C:18,@:$addressStr,P:$proportion=0#';
  }

  return '';
}

// Emergency Command Handlers
String handleEmergencyFunctionTestGroup(
    Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  if (groupStr == null) {
    return '!V:2,Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);
  if (group == null || group < 1 || group > 16383) {
    return '!V:2,Error - Invalid group parameter#';
  }

  // Simulate starting emergency function test for all devices in group
  // In real implementation, this would start tests on all devices in the group

  if (params['A'] == '1') {
    return '?V:2,C:19,G:$group=0#';
  }
  return '';
}

String handleEmergencyFunctionTestDevice(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  // Update test time
  state.lastFunctionTestTime[addressStr] = DateTime.now();

  if (params['A'] == '1') {
    return '?V:2,C:20,@:$addressStr=0#';
  }
  return '';
}

String handleEmergencyDurationTestGroup(
    Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  if (groupStr == null) {
    return '!V:2,Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);
  if (group == null || group < 1 || group > 16383) {
    return '!V:2,Error - Invalid group parameter#';
  }

  if (params['A'] == '1') {
    return '?V:2,C:21,G:$group=0#';
  }
  return '';
}

String handleEmergencyDurationTestDevice(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  // Update test time
  state.lastDurationTestTime[addressStr] = DateTime.now();

  if (params['A'] == '1') {
    return '?V:2,C:22,@:$addressStr=0#';
  }
  return '';
}

String handleStopEmergencyTestsGroup(
    Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  if (groupStr == null) {
    return '!V:2,Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);
  if (group == null || group < 1 || group > 16383) {
    return '!V:2,Error - Invalid group parameter#';
  }

  if (params['A'] == '1') {
    return '?V:2,C:23,G:$group=0#';
  }
  return '';
}

String handleStopEmergencyTestsDevice(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  if (params['A'] == '1') {
    return '?V:2,C:24,@:$addressStr=0#';
  }
  return '';
}

// Query Command Handlers
String handleQueryDeviceTypesAndAddresses(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  // Parse the router address (e.g., "1.2" for cluster 1, router 2)
  final parts = addressStr.split('.');
  if (parts.length != 2) {
    return '!V:2,Error - Invalid address format#';
  }

  final cluster = int.tryParse(parts[0]);
  final router = int.tryParse(parts[1]);

  if (cluster == null || router == null) {
    return '!V:2,Error - Invalid address parameters#';
  }

  // Return device types and addresses for this router
  final deviceList = <String>[];
  for (int s = 1; s <= 4; s++) {
    for (int d = 1; d <= 10; d++) {
      final deviceAddress = "$cluster.$router.$s.$d";
      final deviceType = state.deviceTypes[deviceAddress];
      if (deviceType != null) {
        deviceList.add("${deviceType.toRadixString(16)}@$s.$d");
      }
    }
  }

  return '?V:2,C:100,@$addressStr=${deviceList.join(',')}#';
}

String handleQueryClusters(Map<String, String> params, SystemState state) {
  final clusters = state.clusters.join(',');
  return '?V:2,C:101=$clusters#';
}

String handleQueryRouters(Map<String, String> params, SystemState state) {
  final clusterStr = params['@'];

  if (clusterStr == null) {
    return '!V:2,Error - Missing cluster parameter#';
  }

  final cluster = int.tryParse(clusterStr);

  if (cluster == null) {
    return '!V:2,Error - Invalid cluster parameter#';
  }

  final routers = state.clusterRouters[cluster];
  if (routers == null) {
    return '?V:2,C:102,@$cluster=#';
  }

  return '?V:2,C:102,@$cluster=${routers.join(',')}#';
}

String handleQueryLSIB(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final blockStr = params['B'];

  if (groupStr == null || blockStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final block = int.tryParse(blockStr);

  if (group == null || block == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  final scene = state.blockScenes[block] ?? 1;
  return '?V:2,C:103,G:$group,B:$block=$scene#';
}

String handleQueryDeviceType(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final deviceType = state.deviceTypes[addressStr] ?? 0x0001;
  final hexType = deviceType.toRadixString(16).padLeft(8, '0');
  return '?V:2,C:104,@$addressStr=${hexType}0802#';
}

String handleQueryDescriptionGroup(
    Map<String, String> params, SystemState state) {
  final groupStr = params['G'];

  if (groupStr == null) {
    return '!V:2,Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);

  if (group == null) {
    return '!V:2,Error - Invalid group parameter#';
  }

  final description = state.groupDescriptions[group] ?? "Group $group";
  return '?V:2,C:105,G:$group=$description#';
}

String handleQueryDescriptionDevice(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final description =
      state.deviceDescriptions[addressStr] ?? "Device $addressStr";
  return '?V:2,C:106,@$addressStr=$description#';
}

String handleQueryWorkgroupName(Map<String, String> params, SystemState state) {
  return '?V:2,C:107=${state.workgroupName}#';
}

String handleQueryWorkgroupMembership(
    Map<String, String> params, SystemState state) {
  final members = state.workgroupMembers.join(',');
  return '?V:2,C:108=$members#';
}

String handleQueryLSIG(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];

  if (groupStr == null) {
    return '!V:2,Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);

  if (group == null) {
    return '!V:2,Error - Invalid group parameter#';
  }

  final scene = state.groupScenes[group] ?? 1;
  return '?V:2,C:109,G:$group=$scene#';
}

String handleQueryDeviceState(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final stateFlags = state.deviceStates[addressStr] ?? 0;
  return '?V:2,C:110,@$addressStr=$stateFlags#';
}

String handleQueryDeviceIsDisabled(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final disabled = state.deviceDisabled[addressStr] ?? false;
  return '?V:2,C:111,@$addressStr=${disabled ? 1 : 0}#';
}

String handleQueryLampFailure(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final failure = state.lampFailure[addressStr] ?? false;
  return '?V:2,C:112,@$addressStr=${failure ? 1 : 0}#';
}

String handleQueryDeviceIsMissing(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final missing = state.deviceMissing[addressStr] ?? false;
  return '?V:2,C:113,@$addressStr=${missing ? 1 : 0}#';
}

String handleQueryDeviceIsFaulty(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final faulty = state.deviceFaulty[addressStr] ?? false;
  return '?V:2,C:114,@$addressStr=${faulty ? 1 : 0}#';
}

String handleQueryEmergencyBatteryFailure(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  // Simulate battery failure check
  final batteryFailure = Random().nextDouble() < 0.05; // 5% chance
  return '?V:2,C:129,@$addressStr=${batteryFailure ? 1 : 0}#';
}

String handleQueryMeasurement(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  // Return simulated measurement data (temperature, humidity, etc.)
  final temp = (20 + Random().nextDouble() * 10).toStringAsFixed(1);
  final humidity = (40 + Random().nextDouble() * 20).toStringAsFixed(1);
  return '?V:2,C:150,@$addressStr=T:$temp,H:$humidity#';
}

String handleQueryInputs(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    // Return all input devices
    final inputDevices = state.deviceInputs.keys.toList();
    return '?V:2,C:151=${inputDevices.join(',')}#';
  }

  // Return input values for specific device
  final inputs = state.deviceInputs[addressStr];
  if (inputs == null) {
    return '?V:2,C:151,@$addressStr=#';
  }

  final inputStr =
      inputs.asMap().entries.map((e) => '${e.key + 1}:${e.value}').join(',');
  return '?V:2,C:151,@$addressStr=$inputStr#';
}

String handleQueryLoadLevel(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final level = state.deviceLevels[addressStr] ?? 0;
  return '?V:2,C:152,@$addressStr=$level#';
}

String handleQueryPowerConsumption(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final power = state.powerConsumption[addressStr] ?? 0.0;
  return '?V:2,C:160,@$addressStr=${power.toStringAsFixed(2)}#';
}

String handleQueryGroupPowerConsumption(
    Map<String, String> params, SystemState state) {
  final groupStr = params['G'];

  if (groupStr == null) {
    return '!V:2,Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);
  if (group == null) {
    return '!V:2,Error - Invalid group parameter#';
  }

  // Calculate total power consumption for group (simplified)
  final totalPower = (10.0 + Random().nextDouble() * 90.0);
  return '?V:2,C:161,G:$group=${totalPower.toStringAsFixed(2)}#';
}

String handleQueryGroup(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];

  if (groupStr == null) {
    return '!V:2,Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);
  if (group == null) {
    return '!V:2,Error - Invalid group parameter#';
  }

  final level = state.groupLevels[group] ?? 0;
  final scene = state.groupScenes[group] ?? 1;
  return '?V:2,C:164,G:$group=L:$level,S:$scene#';
}

String handleQueryGroups(Map<String, String> params, SystemState state) {
  final groups = state.groupDescriptions.keys.toList()..sort();
  return '?V:2,C:165=${groups.join(',')}#';
}

String handleQuerySceneNames(Map<String, String> params, SystemState state) {
  final sceneList =
      state.sceneNames.entries.map((e) => '${e.key}:${e.value}').join(',');
  return '?V:2,C:166=$sceneList#';
}

String handleQuerySceneInfo(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  // Return scene information for device
  final scenes = List.generate(16, (i) => '${i + 1}:${(i + 1) * 6}').join(',');
  return '?V:2,C:167,@$addressStr=$scenes#';
}

// Emergency Query Handlers
String handleQueryEmergencyFunctionTestTime(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final testTime = state.lastFunctionTestTime[addressStr] ??
      DateTime.now().subtract(Duration(days: 7));

  final formatter = DateFormat('HH:mm:ss dd-MMM-yyyy');
  return '?V:2,C:170,@$addressStr=${formatter.formatDateTime(testTime)}#';
}

String handleQueryEmergencyFunctionTestState(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final testState = state.emergencyTestState[addressStr] ?? 0;
  return '?V:2,C:171,@$addressStr=$testState#';
}

String handleQueryEmergencyDurationTestTime(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final testTime = state.lastDurationTestTime[addressStr] ??
      DateTime.now().subtract(Duration(days: 30));

  final formatter = DateFormat('HH:mm:ss dd-MMM-yyyy');
  return '?V:2,C:172,@$addressStr=${formatter.formatDateTime(testTime)}#';
}

String handleQueryEmergencyDurationTestState(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final testState = state.emergencyTestState[addressStr] ?? 0;
  return '?V:2,C:173,@$addressStr=$testState#';
}

String handleQueryEmergencyBatteryCharge(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final charge = state.batteryCharge[addressStr] ?? 100.0;
  return '?V:2,C:174,@$addressStr=${charge.toStringAsFixed(1)}#';
}

String handleQueryEmergencyBatteryTime(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final time = state.batteryTime[addressStr] ?? 180;
  return '?V:2,C:175,@$addressStr=$time#';
}

String handleQueryEmergencyTotalLampTime(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  final time = state.totalLampTime[addressStr] ?? 0;
  return '?V:2,C:176,@$addressStr=$time#';
}

// System Query Handlers
String handleQueryTime(Map<String, String> params, SystemState state) {
  return '?V:2,C:185=${DateTime.now().millisecondsSinceEpoch ~/ 1000}#';
}

String handleQueryTimeZone(Map<String, String> params, SystemState state) {
  return '?V:2,C:188=${state.timeZone}#';
}

String handleQueryDaylightSavingTime(
    Map<String, String> params, SystemState state) {
  return '?V:2,C:189=${state.daylightSavingActive ? 1 : 0}#';
}

String handleQuerySoftwareVersion(
    Map<String, String> params, SystemState state) {
  return '?V:2,C:190=${state.softwareVersion}#';
}

String handleQueryHelvarNetVersion(
    Map<String, String> params, SystemState state) {
  return '?V:2,C:191=${state.helvarNetVersion}#';
}

// Store Command Handlers
String handleStoreSceneGroup(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final blockStr = params['B'];
  final sceneStr = params['S'];
  final levelStr = params['L'];

  if (groupStr == null ||
      blockStr == null ||
      sceneStr == null ||
      levelStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final block = int.tryParse(blockStr);
  final scene = int.tryParse(sceneStr);
  final level = int.tryParse(levelStr);

  if (group == null || block == null || scene == null || level == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (group < 1 ||
      group > 16383 ||
      block < 1 ||
      block > 8 ||
      scene < 1 ||
      scene > 16 ||
      level < 0 ||
      level > 100) {
    return '!V:2,Error - Parameter out of range#';
  }

  // Store scene (in real system this would persist)
  print('Storing scene $scene for group $group at level $level%');

  if (params['A'] == '1') {
    return '?V:2,C:201,G:$group,B:$block,S:$scene,L:$level=0#';
  }
  return '';
}

String handleStoreSceneDevice(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  final blockStr = params['B'];
  final sceneStr = params['S'];
  final levelStr = params['L'];

  if (addressStr == null ||
      blockStr == null ||
      sceneStr == null ||
      levelStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final block = int.tryParse(blockStr);
  final scene = int.tryParse(sceneStr);
  final level = int.tryParse(levelStr);

  if (block == null || scene == null || level == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (block < 1 ||
      block > 8 ||
      scene < 1 ||
      scene > 16 ||
      level < 0 ||
      level > 100) {
    return '!V:2,Error - Parameter out of range#';
  }

  print('Storing scene $scene for device $addressStr at level $level%');

  if (params['A'] == '1') {
    return '?V:2,C:202,@:$addressStr,B:$block,S:$scene,L:$level=0#';
  }
  return '';
}

String handleStoreAsSceneGroup(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final blockStr = params['B'];
  final sceneStr = params['S'];

  if (groupStr == null || blockStr == null || sceneStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final block = int.tryParse(blockStr);
  final scene = int.tryParse(sceneStr);

  if (group == null || block == null || scene == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (group < 1 ||
      group > 16383 ||
      block < 1 ||
      block > 8 ||
      scene < 1 ||
      scene > 16) {
    return '!V:2,Error - Parameter out of range#';
  }

  final currentLevel = state.groupLevels[group] ?? 0;
  print(
      'Storing current state (level $currentLevel%) as scene $scene for group $group');

  if (params['A'] == '1') {
    return '?V:2,C:203,G:$group,B:$block,S:$scene=0#';
  }
  return '';
}

String handleStoreAsSceneDevice(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  final blockStr = params['B'];
  final sceneStr = params['S'];

  if (addressStr == null || blockStr == null || sceneStr == null) {
    return '!V:2,Error - Missing required parameters#';
  }

  final block = int.tryParse(blockStr);
  final scene = int.tryParse(sceneStr);

  if (block == null || scene == null) {
    return '!V:2,Error - Invalid parameters#';
  }

  if (block < 1 || block > 8 || scene < 1 || scene > 16) {
    return '!V:2,Error - Parameter out of range#';
  }

  final currentLevel = state.deviceLevels[addressStr] ?? 0;
  print(
      'Storing current state (level $currentLevel%) as scene $scene for device $addressStr');

  if (params['A'] == '1') {
    return '?V:2,C:204,@:$addressStr,B:$block,S:$scene=0#';
  }
  return '';
}

String handleResetEmergencyGroup(
    Map<String, String> params, SystemState state) {
  final groupStr = params['G'];

  if (groupStr == null) {
    return '!V:2,Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);
  if (group == null || group < 1 || group > 16383) {
    return '!V:2,Error - Invalid group parameter#';
  }

  print('Resetting emergency battery and total lamp time for group $group');

  if (params['A'] == '1') {
    return '?V:2,C:205,G:$group=0#';
  }
  return '';
}

String handleResetEmergencyDevice(
    Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!V:2,Error - Missing address parameter#';
  }

  // Reset emergency data for device
  state.batteryCharge[addressStr] = 100.0;
  state.totalLampTime[addressStr] = 0;

  print(
      'Resetting emergency battery and total lamp time for device $addressStr');

  if (params['A'] == '1') {
    return '?V:2,C:206,@:$addressStr=0#';
  }
  return '';
}

// Helper for date formatting
class DateFormat {
  final String format;

  DateFormat(this.format);

  String formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dateTime.month - 1];

    String result = format;
    result = result.replaceAll('HH', dateTime.hour.toString().padLeft(2, '0'));
    result =
        result.replaceAll('mm', dateTime.minute.toString().padLeft(2, '0'));
    result =
        result.replaceAll('ss', dateTime.second.toString().padLeft(2, '0'));
    result = result.replaceAll('dd', dateTime.day.toString().padLeft(2, '0'));
    result = result.replaceAll('MMM', month);
    result = result.replaceAll('yyyy', dateTime.year.toString());

    return result;
  }
}
