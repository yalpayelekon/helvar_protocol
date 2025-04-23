import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

void main() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 8080);
  print('Server running on ${server.address.address}:${server.port}');

  int clientId = 0;
  server.listen((Socket client) {
    clientId++;
    handleClient(client, clientId);
  });
}

// Simulated system state
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
  DateTime lastFunctionTestTime = DateTime.now().subtract(Duration(days: 7));
  DateTime lastDurationTestTime = DateTime.now().subtract(Duration(days: 30));

  SystemState() {
    // Initialize with some default values
    for (int i = 1; i <= 16; i++) {
      groupDescriptions[i] = "Group $i";
      groupLevels[i] = Random().nextInt(101);
      groupScenes[i] = Random().nextInt(16) + 1;
    }

    // Create some sample devices
    for (int c = 1; c <= 2; c++) {
      for (int r = 1; r <= 3; r++) {
        for (int s = 1; s <= 4; s++) {
          for (int d = 1; d <= 10; d++) {
            final address = "$c.$r.$s.$d";
            deviceLevels[address] = Random().nextInt(101);
            deviceDescriptions[address] = "Device $address";
            deviceTypes[address] =
                Random().nextInt(8) + 1; // Random device type
          }
        }
      }
    }

    // Initialize block scenes
    for (int b = 1; b <= 8; b++) {
      blockScenes[b] = Random().nextInt(16) + 1;
    }
  }
}

void handleClient(Socket client, int id) {
  print(
    'Client $id connected: ${client.remoteAddress.address}:${client.remotePort}',
  );

  final SystemState state = SystemState();

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
      client.write('$response\n');
    }
  });

  // Periodically send event messages to simulate system events
  final timer = Timer.periodic(Duration(seconds: 10 + Random().nextInt(10)), (
    _,
  ) {
    // Randomly change a group level
    final groupId = Random().nextInt(16) + 1;
    state.groupLevels[groupId] = Random().nextInt(101);

    final event =
        '!V:1,C:152,G:$groupId=Level changed to ${state.groupLevels[groupId]}#\n';
    try {
      client.write(event);
    } catch (e) {
      // Handle potential write to closed socket
    }
  });

  client.done.then((_) {
    print('Client $id disconnected.');
    subscription.cancel();
    timer.cancel();
    client.destroy();
  });
}

// Parse command parameters from a HelvarNet ASCII message
Map<String, String> parseParameters(String message) {
  final params = <String, String>{};

  // Remove start and end characters
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
    return '!Error - Invalid message format#';
  }

  final params = parseParameters(message);

  // Get the command number
  final commandStr = params['C'];
  if (commandStr == null) {
    return '!Error - Missing command parameter#';
  }

  final command = int.tryParse(commandStr);
  if (command == null) {
    return '!Error - Invalid command parameter#';
  }

  // Process based on command number
  switch (command) {
    // Recall Scene (Group)
    case 11:
      return handleRecallSceneGroup(params, state);

    // Recall Scene (Device)
    case 12:
      return handleRecallSceneDevice(params, state);

    // Direct Level (Group)
    case 13:
      return handleDirectLevelGroup(params, state);

    // Direct Level (Device)
    case 14:
      return handleDirectLevelDevice(params, state);

    // Direct Proportion (Group)
    case 15:
      return handleDirectProportionGroup(params, state);

    // Query Clusters
    case 101:
      return handleQueryClusters(params, state);

    // Query Routers
    case 102:
      return handleQueryRouters(params, state);

    // Query Last Scene In Block
    case 103:
      return handleQueryLSIB(params, state);

    // Query Device Type
    case 104:
      return handleQueryDeviceType(params, state);

    // Query Description Group
    case 105:
      return handleQueryDescriptionGroup(params, state);

    // Query Description Device
    case 106:
      return handleQueryDescriptionDevice(params, state);

    // Query Last Scene In Group
    case 109:
      return handleQueryLSIG(params, state);

    // Query Load Level
    case 152:
      return handleQueryLoadLevel(params, state);

    // Query Emergency Function Test Time
    case 170:
      return handleQueryEmergencyFunctionTestTime(params, state);

    // Query Emergency Duration Test Time
    case 172:
      return handleQueryEmergencyDurationTestTime(params, state);

    // Query Time
    case 185:
      return handleQueryTime(params, state);

    // Query Software Version
    case 190:
      return handleQuerySoftwareVersion(params, state);

    default:
      return '!Error - Unsupported command: $command#';
  }
}

// Command handlers

String handleRecallSceneGroup(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final blockStr = params['B'];
  final sceneStr = params['S'];

  if (groupStr == null || blockStr == null || sceneStr == null) {
    return '!Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final block = int.tryParse(blockStr);
  final scene = int.tryParse(sceneStr);

  if (group == null || block == null || scene == null) {
    return '!Error - Invalid parameters#';
  }

  // Update system state
  state.groupScenes[group] = scene;
  state.blockScenes[block] = scene;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:1,C:11,G:$group,B:$block,S:$scene=0#';
  }

  return '';
}

String handleRecallSceneDevice(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  final blockStr = params['B'];
  final sceneStr = params['S'];

  if (addressStr == null || blockStr == null || sceneStr == null) {
    return '!Error - Missing required parameters#';
  }

  final block = int.tryParse(blockStr);
  final scene = int.tryParse(sceneStr);

  if (block == null || scene == null) {
    return '!Error - Invalid parameters#';
  }

  // Update system state
  state.deviceLevels[addressStr] = 75; // Assume scene recall sets level to 75%
  state.blockScenes[block] = scene;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:1,C:12,@:$addressStr,B:$block,S:$scene=0#';
  }

  return '';
}

String handleDirectLevelGroup(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final levelStr = params['L'];

  if (groupStr == null || levelStr == null) {
    return '!Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final level = int.tryParse(levelStr);

  if (group == null || level == null) {
    return '!Error - Invalid parameters#';
  }

  // Update system state
  state.groupLevels[group] = level;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:1,C:13,G:$group,L:$level=0#';
  }

  return '';
}

String handleDirectLevelDevice(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];
  final levelStr = params['L'];

  if (addressStr == null || levelStr == null) {
    return '!Error - Missing required parameters#';
  }

  final level = int.tryParse(levelStr);

  if (level == null) {
    return '!Error - Invalid parameters#';
  }

  // Update system state
  state.deviceLevels[addressStr] = level;

  // Check if acknowledgment is requested
  if (params['A'] == '1') {
    return '?V:1,C:14,@:$addressStr,L:$level=0#';
  }

  return '';
}

String handleDirectProportionGroup(
  Map<String, String> params,
  SystemState state,
) {
  final groupStr = params['G'];
  final proportionStr = params['P'];

  if (groupStr == null || proportionStr == null) {
    return '!Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final proportion = int.tryParse(proportionStr);

  if (group == null || proportion == null) {
    return '!Error - Invalid parameters#';
  }

  // Update system state based on proportion calculation
  final currentLevel = state.groupLevels[group] ?? 0;
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
    return '?V:1,C:15,G:$group,P:$proportion=0#';
  }

  return '';
}

String handleQueryClusters(Map<String, String> params, SystemState state) {
  final clusters = state.clusters.join(',');
  return '?V:1,C:101=$clusters#';
}

String handleQueryRouters(Map<String, String> params, SystemState state) {
  final clusterStr = params['@'];

  if (clusterStr == null) {
    return '!Error - Missing cluster parameter#';
  }

  final cluster = int.tryParse(clusterStr);

  if (cluster == null) {
    return '!Error - Invalid cluster parameter#';
  }

  final routers = state.clusterRouters[cluster];
  if (routers == null) {
    return '?V:1,C:102,@$cluster=#';
  }

  return '?V:1,C:102,@$cluster=${routers.join(',')}#';
}

String handleQueryLSIB(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];
  final blockStr = params['B'];

  if (groupStr == null || blockStr == null) {
    return '!Error - Missing required parameters#';
  }

  final group = int.tryParse(groupStr);
  final block = int.tryParse(blockStr);

  if (group == null || block == null) {
    return '!Error - Invalid parameters#';
  }

  final scene = state.blockScenes[block] ?? 1;
  return '?V:1,C:103,G:$group,B:$block=$scene#';
}

String handleQueryDeviceType(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!Error - Missing address parameter#';
  }

  final deviceType = state.deviceTypes[addressStr] ?? 0;
  return '?V:1,C:104,@$addressStr=00${deviceType.toString().padLeft(2, '0')}0802#';
}

String handleQueryDescriptionGroup(
  Map<String, String> params,
  SystemState state,
) {
  final groupStr = params['G'];

  if (groupStr == null) {
    return '!Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);

  if (group == null) {
    return '!Error - Invalid group parameter#';
  }

  final description = state.groupDescriptions[group] ?? "Group $group";
  return '?V:1,C:105,G:$group=$description#';
}

String handleQueryDescriptionDevice(
  Map<String, String> params,
  SystemState state,
) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!Error - Missing address parameter#';
  }

  final description =
      state.deviceDescriptions[addressStr] ?? "Device $addressStr";
  return '?V:1,C:106,@$addressStr=$description#';
}

String handleQueryLSIG(Map<String, String> params, SystemState state) {
  final groupStr = params['G'];

  if (groupStr == null) {
    return '!Error - Missing group parameter#';
  }

  final group = int.tryParse(groupStr);

  if (group == null) {
    return '!Error - Invalid group parameter#';
  }

  final scene = state.groupScenes[group] ?? 1;
  return '?V:1,C:109,G:$group=$scene#';
}

String handleQueryLoadLevel(Map<String, String> params, SystemState state) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!Error - Missing address parameter#';
  }

  final level = state.deviceLevels[addressStr] ?? 0;
  return '?V:1,C:152,@$addressStr=$level#';
}

String handleQueryEmergencyFunctionTestTime(
  Map<String, String> params,
  SystemState state,
) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!Error - Missing address parameter#';
  }

  final formatter = DateFormat('HH:mm:ss dd-MMM-yyyy');
  return '?V:1,C:170,@$addressStr=${formatter.format(state.lastFunctionTestTime)}#';
}

String handleQueryEmergencyDurationTestTime(
  Map<String, String> params,
  SystemState state,
) {
  final addressStr = params['@'];

  if (addressStr == null) {
    return '!Error - Missing address parameter#';
  }

  final formatter = DateFormat('HH:mm:ss dd-MMM-yyyy');
  return '?V:1,C:172,@$addressStr=${formatter.format(state.lastDurationTestTime)}#';
}

String handleQueryTime(Map<String, String> params, SystemState state) {
  return '?V:1,C:185=${DateTime.now().millisecondsSinceEpoch ~/ 1000}#';
}

String handleQuerySoftwareVersion(
  Map<String, String> params,
  SystemState state,
) {
  return '?V:1,C:190=67240448#'; // Represents version 4.2.2
}

// Helper for date formatting
class DateFormat {
  final String lastformat;

  DateFormat(this.lastformat);

  String format(DateTime dateTime) {
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

    String result = lastformat;
    result = result.replaceAll('HH', dateTime.hour.toString().padLeft(2, '0'));
    result = result.replaceAll(
      'mm',
      dateTime.minute.toString().padLeft(2, '0'),
    );
    result = result.replaceAll(
      'ss',
      dateTime.second.toString().padLeft(2, '0'),
    );
    result = result.replaceAll('dd', dateTime.day.toString().padLeft(2, '0'));
    result = result.replaceAll('MMM', month);
    result = result.replaceAll('yyyy', dateTime.year.toString());

    return result;
  }
}
