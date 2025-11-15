import 'package:eadeploy_cli/src/core/pipelines/pipeline_event.dart';
import 'package:eadeploy_cli/src/core/pipelines/pipeline_runner.dart';

/// This pipeline always is executed by safe docker commands execution
///
/// Since we can move or renamed some files, and something can fail at
/// any point, we don't want to do changes directly in cloned repo
class BackupProjectPipeline extends PipelineEvent {
  BackupProjectPipeline({
    required super.preCommands,
    required super.postCommands,
  });

  @override
  bool revert(Map<String, dynamic> param) {
    throw UnimplementedError();
  }

  @override
  Future<PipelineResponse<Map<String, dynamic>>> run(
    Map<String, dynamic> param, {
    void Function([
      String p1,
    ])? onTryLog,
    Future<void> Function()? onCancel,
  }) async {
    //TODO:
    // if something occurs successfully, we add the value
    // 'backup_path': <path>,
    // since will be another pipeline to destroy the backup
    // when mounted the docker image
    return PipelineResponse<Map<String, dynamic>>.error(
      error: '',
    );
  }
}
