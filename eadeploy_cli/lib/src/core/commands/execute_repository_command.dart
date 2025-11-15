import 'command_base.dart';

class ExecuteRepositoryCommand extends CommandBase {
  /// The repository that will be executed
  final String repoId;

  /// The [PipelineEvent] where this will be executed
  final String eventId;

  ExecuteRepositoryCommand({
    required this.repoId,
    required this.eventId,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'execute_repo',
      'repoId': repoId,
      'eventId': eventId,
    };
  }

  factory ExecuteRepositoryCommand.fromJson(Map<String, dynamic> map) {
    return ExecuteRepositoryCommand(
      eventId: map['eventId'] as String,
      repoId: map['repoId'] as String,
    );
  }

  ExecuteRepositoryCommand copyWith({
    String? eventId,
    String? repoId,
  }) {
    return ExecuteRepositoryCommand(
      repoId: repoId ?? this.repoId,
      eventId: eventId ?? this.eventId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecuteRepositoryCommand &&
          runtimeType == other.runtimeType &&
          repoId == other.repoId &&
          eventId == other.eventId;

  @override
  int get hashCode => repoId.hashCode ^ eventId.hashCode;
}
