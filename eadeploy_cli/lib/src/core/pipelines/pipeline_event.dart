// ignore_for_file: unused_element, constant_identifier_names

import 'package:eadeploy_cli/src/core/commands/command_base.dart';
import 'package:eadeploy_cli/src/core/pipelines/pipeline_runner.dart';

const int _NO_INIT_PHASE = -1;
const int _START_PHASE = 1;
const int _PRE_PHASE = 2;
const int _POS_PHASE = 3;

class PipelineEvent extends PipelineRunner<void, Map<String, dynamic>> {
  int _phase = _NO_INIT_PHASE;

  /// The commands that will be runned before this event
  final List<CommandBase> preCommands;

  /// The commands that will be runned after this event
  final List<CommandBase> postCommands;

  PipelineEvent({
    required this.preCommands,
    required this.postCommands,
  });

  @override
  String get identifier => 'Event';

  @override
  void run(Map<String, dynamic> param) async {
    _phase = _START_PHASE;
  }

  @override
  int get phase => _phase;

  @override
  bool revert(Map<String, dynamic> param) {
    throw UnimplementedError();
  }
}
