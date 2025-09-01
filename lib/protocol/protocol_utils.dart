import 'protocol_constants.dart';

class ProtocolUtils {
  static bool isErrorResponse(String response) {
    return response.startsWith(MessageType.error);
  }

  static int? getErrorCode(String errorResponse) {
    if (!isErrorResponse(errorResponse)) {
      return null;
    }

    final parts = errorResponse.split(MessageType.answer);
    if (parts.length != 2) {
      return null;
    }

    var errorCodeStr = parts[1];
    if (errorCodeStr.endsWith(MessageType.terminator)) {
      errorCodeStr = errorCodeStr.substring(0, errorCodeStr.length - 1);
    }

    return int.tryParse(errorCodeStr);
  }

  /// Validates that [cluster] is within the allowed range (1-255).
  static void validateCluster(int cluster) {
    if (!isValidCluster(cluster)) {
      throw FormatException('Cluster must be between 1 and 255: $cluster');
    }
  }

  /// Validates that [router] is within the allowed range (1-255).
  static void validateRouter(int router) {
    if (!isValidRouter(router)) {
      throw FormatException('Router must be between 1 and 255: $router');
    }
  }

  /// Validates that [subnet] is within the allowed range (1-255).
  static void validateSubnet(int subnet) {
    if (!isValidSubnet(subnet)) {
      throw FormatException('Subnet must be between 1 and 255: $subnet');
    }
  }

  /// Validates that [device] is within the allowed range (1-65499).
  static void validateDevice(int device) {
    if (!isValidDevice(device)) {
      throw FormatException('Device must be between 1 and 65499: $device');
    }
  }

  /// Validates that [subDevice] is within the allowed range (0-255).
  static void validateSubDevice(int subDevice) {
    if (!isValidSubDevice(subDevice)) {
      throw FormatException('Sub device must be between 0 and 255: $subDevice');
    }
  }

  /// Returns true if [cluster] falls within the valid range.
  static bool isValidCluster(int cluster) => cluster >= 1 && cluster <= 255;

  /// Returns true if [router] falls within the valid range.
  static bool isValidRouter(int router) => router >= 1 && router <= 255;

  /// Returns true if [subnet] falls within the valid range.
  static bool isValidSubnet(int subnet) => subnet >= 1 && subnet <= 255;

  /// Returns true if [device] falls within the valid range.
  static bool isValidDevice(int device) => device >= 1 && device < 65500;

  /// Returns true if [subDevice] falls within the valid range.
  static bool isValidSubDevice(int subDevice) =>
      subDevice >= 0 && subDevice <= 255;
}
