const int maxMessageLength = 1500;
const int defaultTcpPort = 50000;
const int defaultUdpPort = 50001;

String getStateFlagsDescription(int flags) {
  final descriptions = <String>[];

  if (flags == 0) return 'Normal';

  if ((flags & 0x00000001) != 0) descriptions.add('Disabled');
  if ((flags & 0x00000002) != 0) descriptions.add('Lamp Failure');
  if ((flags & 0x00000004) != 0) descriptions.add('Missing');
  if ((flags & 0x00000008) != 0) descriptions.add('Faulty');
  if ((flags & 0x00000010) != 0) descriptions.add('Refreshing');
  if ((flags & 0x00000100) != 0) descriptions.add('Emergency Resting');
  if ((flags & 0x00000400) != 0) descriptions.add('In Emergency');
  if ((flags & 0x00000800) != 0) descriptions.add('In Prolong');
  if ((flags & 0x00001000) != 0) descriptions.add('Function Test In Progress');
  if ((flags & 0x00002000) != 0) descriptions.add('Duration Test In Progress');
  if ((flags & 0x00010000) != 0) descriptions.add('Duration Test Pending');
  if ((flags & 0x00020000) != 0) descriptions.add('Function Test Pending');
  if ((flags & 0x00040000) != 0) descriptions.add('Battery Failure');
  if ((flags & 0x00200000) != 0) descriptions.add('Emergency Inhibit');
  if ((flags & 0x00400000) != 0) descriptions.add('Function Test Requested');
  if ((flags & 0x00800000) != 0) descriptions.add('Duration Test Requested');
  if ((flags & 0x01000000) != 0) descriptions.add('Unknown State');
  if ((flags & 0x02000000) != 0) descriptions.add('Over Temperature');
  if ((flags & 0x04000000) != 0) descriptions.add('Over Current');
  if ((flags & 0x08000000) != 0) descriptions.add('Communications Error');
  if ((flags & 0x10000000) != 0) descriptions.add('Severe Error');
  if ((flags & 0x20000000) != 0) descriptions.add('Bad Reply');
  if ((flags & 0x80000000) != 0) descriptions.add('Device Mismatch');

  return descriptions.join(', ');
}

class MessageType {
  static const String command = '>'; // Command message
  static const String internalCommand = '<'; // Internal command
  static const String reply = '?'; // Reply message
  static const String error = '!'; // Error or diagnostic message
  static const String terminator = '#'; // End of message
  static const String partialTerminator = '\$'; // End of partial message
  static const String answer = '='; // Separates query from response
  static const String delimiter = ','; // Separates parameters
  static const String paramDelimiter = ':'; // Separates parameter ID from value
  static const String addressDelimiter = '.'; // Separates address components
}

class ProtocolType {
  static const int dali = 0x01;
  static const int digidim = 0x02;
  static const int imagine = 0x04;
  static const int dmx = 0x08;
}

class SceneStatus {
  static const Map<int, String> descriptions = {
    128: 'Off', // 0x0080
    129: 'Min level', // 0x0081
    130: 'Max level', // 0x0082
    137: 'Last Scene Percentage (0%)', // 0x0089
    138: 'Last Scene Percentage (1%)', // 0x008A
    237: 'Last Scene Percentage (100%)', // 0x00ED
  };
}

class ErrorCode {
  static const int success = 0;
  static const int invalidGroupIndex = 1;
  static const int invalidCluster = 2;
  static const int invalidRouter = 3;
  static const int invalidSubnet = 4;
  static const int invalidDevice = 5;
  static const int invalidSubDevice = 6;
  static const int invalidBlock = 7;
  static const int invalidScene = 8;
  static const int clusterNotExist = 9;
  static const int routerNotExist = 10;
  static const int deviceNotExist = 11;
  static const int propertyNotExist = 12;
  static const int invalidRawMessageSize = 13;
  static const int invalidMessageType = 14;
  static const int invalidMessageCommand = 15;
  static const int missingAsciiTerminator = 16;
  static const int missingAsciiParameter = 17;
  static const int incompatibleVersion = 18;
  static String getMessage(int code) {
    switch (code) {
      case success:
        return 'Success';
      case invalidGroupIndex:
        return 'Error - Invalid group index parameter';
      case invalidCluster:
        return 'Error - Invalid cluster parameter';
      case invalidRouter:
        return 'Error - Invalid router parameter';
      case invalidSubnet:
        return 'Error - Invalid subnet parameter';
      case invalidDevice:
        return 'Error - Invalid device parameter';
      case invalidSubDevice:
        return 'Error - Invalid sub device parameter';
      case invalidBlock:
        return 'Error - Invalid block parameter';
      case invalidScene:
        return 'Error - Invalid scene parameter';
      case clusterNotExist:
        return 'Error - Cluster does not exist';
      case routerNotExist:
        return 'Error - Router does not exist';
      case deviceNotExist:
        return 'Error - Device does not exist';
      case propertyNotExist:
        return 'Error - Property does not exist';
      case invalidRawMessageSize:
        return 'Error - Invalid RAW message size';
      case invalidMessageType:
        return 'Error - Invalid messages type';
      case invalidMessageCommand:
        return 'Error - Invalid message command';
      case missingAsciiTerminator:
        return 'Error - Missing ASCII terminator';
      case missingAsciiParameter:
        return 'Error - Missing ASCII parameter';
      case incompatibleVersion:
        return 'Error - Incompatible version';
      default:
        return 'Unknown error: $code';
    }
  }
}

class EmergencyTestState {
  static const int pass = 0;
  static const int lampFailure = 1;
  static const int batteryFailure = 2;
  static const int faulty = 4;
  static const int failure = 8;
  static const int testPending = 16;
  static const int unknown = 32;
}
