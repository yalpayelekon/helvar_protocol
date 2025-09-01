import '../protocol_constants.dart';

Map<String, bool> decodeEmergencyTestState(int stateValue) {
  return {
    'pass': (stateValue & EmergencyTestState.pass) == EmergencyTestState.pass,
    'lampFailure': (stateValue & EmergencyTestState.lampFailure) != 0,
    'batteryFailure': (stateValue & EmergencyTestState.batteryFailure) != 0,
    'faulty': (stateValue & EmergencyTestState.faulty) != 0,
    'failure': (stateValue & EmergencyTestState.failure) != 0,
    'testPending': (stateValue & EmergencyTestState.testPending) != 0,
    'unknown': (stateValue & EmergencyTestState.unknown) != 0,
  };
}
