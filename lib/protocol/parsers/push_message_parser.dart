import '../protocol_constants.dart';

class PushMessageParser {
  static bool isReply(String message) {
    return message.startsWith(MessageType.reply) ||
        message.startsWith(MessageType.error);
  }

  static bool isPushMessage(String message) => !isReply(message);
}

class ParsedPushMessage {
  final String groupId;
  final int? scene;

  ParsedPushMessage({required this.groupId, this.scene});
}

extension PushMessageParserExt on PushMessageParser {
  static ParsedPushMessage? parsePushMessage(String message) {
    final groupMatch = RegExp(r'G:(\d+)').firstMatch(message);
    if (groupMatch == null) return null;
    final groupId = groupMatch.group(1)!;
    final sceneMatch = RegExp(r'S:(\d+)').firstMatch(message);
    final scene = sceneMatch != null
        ? int.tryParse(sceneMatch.group(1)!)
        : null;
    return ParsedPushMessage(groupId: groupId, scene: scene);
  }
}
