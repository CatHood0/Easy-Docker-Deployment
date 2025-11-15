import 'pipeline.dart';

abstract class PipelineRunner<T, R extends Object?> {
  PipelineStagesRunner? parent;
  int index = -1;

  PipelineJson? get previous => index == -1 || parent == null
      ? parent?.stages.elementAtOrNull(index - 1)
      : null;

  PipelineJson? get next => index == -1 || parent == null
      ? parent?.stages.elementAtOrNull(index + 1)
      : null;

  String get identifier;

  /// Revert all the changes as possible
  bool revert(R param);

  /// Runs the runner
  Future<PipelineResponse<T>> run(
    R param, {
    void Function([String])? onTryLog,
    Future<void> Function()? onCancel,
  });
}

class PipelineResponse<T> {
  final T? data;
  final Object? error;

  PipelineResponse({
    required this.data,
    required this.error,
  });

  PipelineResponse.error({
    required this.error,
  }) : data = null;

  PipelineResponse.sucess({
    required this.data,
  })  : assert(
          data != null,
          'data should '
          'not be null if the '
          'pipeline was '
          'executed sucessfully',
        ),
        error = null;

  bool get hasError => error != null;

  bool get hasData => data != null;

  T get castData => data!;
}
