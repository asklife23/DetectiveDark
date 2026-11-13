import 'package:equatable/equatable.dart';

/// Who a message in the chat log comes from.
enum ChatSender {
  /// The inner voice of the detective.
  detective,

  /// The game itself (e.g. a hint header).
  system,
}

/// One line of the message history, as stored in the save: a text key,
/// never the text itself.
class ChatLogEntry extends Equatable {
  const ChatLogEntry({
    required this.textKey,
    required this.sentAtUtcMs,
    this.sender = ChatSender.detective,
    this.params = const {},
  });

  final ChatSender sender;
  final String textKey;

  /// Values for placeholders in the text. Empty for most messages.
  final Map<String, String> params;

  /// UTC milliseconds since the Unix epoch.
  final int sentAtUtcMs;

  @override
  List<Object?> get props => [sender, textKey, params, sentAtUtcMs];
}
