import 'dart:async';

import 'package:eadeploy_cli/src/core/pipelines/pipeline_runner.dart';
import '../commands/runner/command_runner.dart';

class Pipeline extends PipelineRunner<void, Map<String, dynamic>> {
  final List<PipelineRunner<void, dynamic>> _runners =
      <PipelineRunner<void, dynamic>>[];

  final CommandExecuter runner = CommandExecuter();
  int _currentRunner = -1;

  @override
  String get identifier => 'Pipeline-Root-Executer';

  /// Adds new runner at the end of the pipeline
  void register(PipelineRunner operation) {
    _runners.add(operation..parent = this);
  }

  @override
  void run(Map<String, dynamic> param) async {
    // help us to allow stopping processes at any point
    final Completer<void> complete = Completer<void>();

    void endRunning(bool forced) {
      complete.complete();
      //NOTE: add the rest of the revert at this point
    }

    _currentRunner++;
    for (PipelineRunner<void, dynamic> s in _runners) {
      s
        ..registerListener(endRunning)
        ..run(param);
      _currentRunner++;
    }

    await complete.future;
  }

  @override
  int get phase => -1;

  @override
  bool revert(Map<String, dynamic> param) {
    //TODO: probably we will prefer just ignoring
    // non reverted changes
    for (var s in _runners) {
      final bool reverted = s.revert(param);
      return reverted;
    }
    return true;
  }
}
