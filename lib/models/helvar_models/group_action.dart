enum GroupAction {
  recallScene,
  storeScene,
  directLevel,
  directProportion,
  modifyProportion,
  emergencyFunctionTest,
  emergencyDurationTest,
  stopEmergencyTest,
  resetEmergencyBatteryTotalLampTime,
  refreshGroupProperties,
}

extension GroupActionExtension on GroupAction {
  String get displayName {
    switch (this) {
      case GroupAction.recallScene:
        return 'Recall Scene';
      case GroupAction.storeScene:
        return 'Store Scene';
      case GroupAction.directLevel:
        return 'Direct Level';
      case GroupAction.directProportion:
        return 'Direct Proportion';
      case GroupAction.modifyProportion:
        return 'Modify Proportion';
      case GroupAction.emergencyFunctionTest:
        return 'Emergency Function Test';
      case GroupAction.emergencyDurationTest:
        return 'Emergency Duration Test';
      case GroupAction.stopEmergencyTest:
        return 'Stop Emergency Test';
      case GroupAction.resetEmergencyBatteryTotalLampTime:
        return 'Reset Emergency Battery Total Lamp Time';
      case GroupAction.refreshGroupProperties:
        return 'Refresh Group Properties';
    }
  }
}
