import 'package:eadeploy_cli/src/core/commands/command_base.dart';
import 'package:eadeploy_cli/src/core/pipelines/pipeline_event.dart';
import '../../pipelines/pipeline.dart';

class CommandExecuter {
  /// Returns a map of commands that we're not executed as expected 
  /// with the error message
  Map<int, Map<CommandBase, String?>> execute(
    Pipeline owner,
    PipelineEvent event,
  ) {
    return <int, Map<CommandBase, String?>>{};
  }
}
