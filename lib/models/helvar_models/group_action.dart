enum GroupAction {
  recallScene,
  storeScene,
  directLevel,
  directProportion,
  modifyProportion,
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
      case GroupAction.refreshGroupProperties:
        return 'Refresh Group Properties';
    }
  }
}
