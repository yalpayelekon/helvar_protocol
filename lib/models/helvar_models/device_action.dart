enum DeviceAction {
  clearResult,
  recallScene,
  directLevel,
  directProportion,
  modifyProportion,
}

extension DeviceActionExtension on DeviceAction {
  String get displayName {
    switch (this) {
      case DeviceAction.clearResult:
        return 'Clear Result';
      case DeviceAction.recallScene:
        return 'Recall Scene';
      case DeviceAction.directLevel:
        return 'Direct Level';
      case DeviceAction.directProportion:
        return 'Direct Proportion';
      case DeviceAction.modifyProportion:
        return 'Modify Proportion';
    }
  }
}
