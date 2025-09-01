class ProtocolParser {
  static String? extractResponseValue(String response) {
    if ((response.startsWith('?') || response.startsWith('!')) &&
        response.contains('=')) {
      final parts = response.split('=');
      if (parts.length > 1) {
        return parts[1].replaceAll('#', '');
      }
    }
    return null;
  }

  static int _parseDeviceType(String value) {
    try {
      if (value.startsWith('0x') || RegExp(r'[A-Fa-f]').hasMatch(value)) {
        return int.parse(value.replaceFirst('0x', ''), radix: 16);
      }
      return int.parse(value);
    } catch (e) {
      print('Failed to parse device type "$value": $e');
      rethrow;
    }
  }

  static Map<int, int> parseDeviceAddressesAndTypes(String response) {
    final deviceMap = <int, int>{};
    final pairs = response.split(',');

    for (final pair in pairs) {
      if (pair.contains('@')) {
        final parts = pair.split('@');
        if (parts.length == 2) {
          try {
            final typeStr = parts[0];
            final deviceType = _parseDeviceType(typeStr);
            final deviceId = int.parse(parts[1]);
            deviceMap[deviceId] = deviceType;
          } catch (e) {
            print('Error parsing device pair: $pair - $e');
          }
        }
      }
    }

    return deviceMap;
  }

  static bool isSuccessResponse(String response) {
    return response.startsWith('?');
  }

  static bool isErrorResponse(String response) {
    return response.startsWith('!');
  }

  static int? getCommandCode(String response) {
    if (!response.startsWith('?') && !response.startsWith('!')) {
      return null;
    }

    final commandMatch = RegExp(r'C:(\d+)').firstMatch(response);
    if (commandMatch != null) {
      return int.tryParse(commandMatch.group(1)!);
    }
    return null;
  }

  static int? getCommandCodeFromCommand(String cmd) {
    final match = RegExp(r'C:(\d+)').firstMatch(cmd);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  static int? getVersion(String response) {
    if (!response.startsWith('?') && !response.startsWith('!')) {
      return null;
    }

    final versionMatch = RegExp(r'V:(\d+)').firstMatch(response);
    if (versionMatch != null) {
      return int.tryParse(versionMatch.group(1)!);
    }
    return null;
  }

  static String? getDeviceAddress(String response) {
    if (!response.startsWith('?') && !response.startsWith('!')) {
      return null;
    }

    final addressMatch = RegExp(r'@([\d.]+)').firstMatch(response);
    if (addressMatch != null) {
      return addressMatch.group(1);
    }
    return null;
  }

  static Map<String, dynamic> parseFullResponse(String response) {
    return {
      'isSuccess': isSuccessResponse(response),
      'isError': isErrorResponse(response),
      'version': getVersion(response),
      'commandCode': getCommandCode(response),
      'deviceAddress': getDeviceAddress(response),
      'value': extractResponseValue(response),
      'rawResponse': response,
    };
  }
}
