import 'package:eadeploy_cli/src/core/pipelines/pipeline_runner.dart';
import '../commands/runner/command_runner.dart';

// make this more readable
typedef PipelineJson
    = PipelineRunner<Map<String, dynamic>, Map<String, dynamic>>;

class PipelineStagesRunner {
  final List<PipelineJson> stages = <PipelineJson>[];

  final CommandExecuter executer = CommandExecuter();

  /// Adds new runner at the end of the pipeline
  void register(PipelineJson stage) {
    stages.add(
      stage
        ..parent = this
        ..index = stages.length,
    );
  }

  Future<Map<String, dynamic>> run(
    Map<String, dynamic> param, {
    void Function([String])? onTryLog,
  }) async {
    if (stages.isEmpty) {
      return <String, dynamic>{
        'error': 'There\'s no stages to execute',
      };
    }
    //TODO: we need to listen for interruptions during execution
    // to revert changes directly
    PipelineJson? stage = stages.firstOrNull;
    Map<String, dynamic> data = param;
    while (stage != null) {
      // use the last info, and transform it to the required info for the next one
      final PipelineResponse<Map<String, dynamic>> response = await stage.run(
        <String, dynamic>{
          ...data,
          'command_runner': executer,
        },
        onTryLog: onTryLog,
      );
      if (response.hasError) {
        return <String, dynamic>{
          'error': response.error,
          // used normally to pass to the revert operations
          // to know what was used to make the change at first
          // place
          'data': data,
          'stages': <String, Object>{
            'require_revert': true,
            'list': stages.take(stage.index),
          },
        };
      }
      stage = stage.next;
    }

    return <String, dynamic>{};
  }
}
