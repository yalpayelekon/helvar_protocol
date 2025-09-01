enum PointValueType { boolean, numeric, string }

extension PointValueTypeExtension on PointValueType {
  String get string => name;

  static PointValueType fromString(String value) {
    switch (value) {
      case 'numeric':
        return PointValueType.numeric;
      case 'string':
        return PointValueType.string;
      case 'boolean':
      default:
        return PointValueType.boolean;
    }
  }

  dynamic get defaultValue {
    switch (this) {
      case PointValueType.boolean:
        return false;
      case PointValueType.string:
        return '';
      case PointValueType.numeric:
        return 0.0;
    }
  }
}
