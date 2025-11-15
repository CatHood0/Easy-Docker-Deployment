import 'package:eadeploy_cli/src/core/pipelines/pipeline.dart';
import '../commands/command_base.dart';

abstract class PipelineEvent extends PipelineJson {
  final List<CommandBase> preCommands;
  final List<CommandBase> postCommands;

  PipelineEvent({
    required this.preCommands,
    required this.postCommands,
  });

  @override
  String get identifier => 'Event';
}
