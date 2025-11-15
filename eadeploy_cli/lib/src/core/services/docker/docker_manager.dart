import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../../services/git/git_installation_checker.dart';
import '../../services/git/network_error.dart';
import 'package:path/path.dart' as path_package;

import '../git/git_clone_resolver.dart';
import '../services.dart';

class DockerService {
  DockerService(this._logger);
  final LoggerService _logger;

  Stream<List<String>> get logs => _logger.logs;

  void reload() => _logger.clamp(0, _logger.length);

  void log(String message) => _logger.log(message);
  void logClamp(int start, int end) => _logger.clamp(start, end);

  int logLength() => _logger.length;

  String? lastMessage() => _logger.last;

  Future<List<PermissionIssue>> checkPotentialIssues(
      {void Function(String)? log}) async {
    final List<PermissionIssue> issues = [];

    log?.call('🔍 Realizando verificación...');

    // Verificar problemas de red
    final bool networkStatus =
        await services[NetworkIssueResolver.instance.serviceKey]!.check(
      null,
      log: log,
    );
    if (!networkStatus) {
      issues.add(
        await getPermissionIssue(
          DockerPermissionStatus.notServiceInstalled,
          NetworkIssueResolver.instance.serviceKey,
        ),
      );
    }

    // Verificar problemas de clonación Git
    final bool gitCloneStatus =
        await services[GitCloneIssueResolver.instance.serviceKey]!.check(
      null,
      log: log,
    );

    if (!gitCloneStatus) {
      issues.add(
        await getPermissionIssue(
          DockerPermissionStatus.notServiceInstalled,
          GitCloneIssueResolver.instance.serviceKey,
        ),
      );
    }

    if (issues.isEmpty) {
      log?.call('✅ No se detectaron problemas potenciales');
    } else {
      log?.call('⚠️ Se detectaron ${issues.length} problemas potenciales');
    }

    return issues;
  }

  // Clonar el repositorio
  Future<bool> cloneRepository(
    String repoUrl, {
    String branch = 'main',
    required String imageName,
    required String username,
    required String token,
    (String, String, bool) Function()? onRequestSudoPermissions,
    void Function(Process pr)? onLoadProcess,
    void Function()? onEndProcess,
  }) async {
    try {
      // check if git exist first
      if (!(await services[GitInstallationChecker.instance.serviceKey]!.check(
        null,
        log: (String value) {
          _logger.log(value);
        },
      )).$1) {
        isRunning.value = false;
        return false;
      }

      _logger.log('📥 Clonando repositorio: $repoUrl');
      isRunning.value = true;
      final Uri uri = Uri.parse(repoUrl);
      final String authUrl = 'https://'
          '${username.isEmpty && token.isEmpty ? '' : '$username:$token@'}'
          '${uri.host}'
          '${uri.path}';

      final Directory dir = Directory(await appDirectory(imageName));

      // since we cannot force cloning in the same dir, we need
      // to remove that directory directly
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      final Process process = await Process.start('git', [
        // disable ssh and certificates checking
        '-c',
        'http.sslVerify=false',
        'clone',
        '--progress', // Show progress
        '--depth',
        '1',
        '-b',
        branch,
        authUrl,
        dir.path,
      ]);
      // Escuchar la salida estándar y de errores para logging en tiempo real

      onLoadProcess?.call(process);

      final int exitCode = await process.exitCode;

      if (exitCode == 0) {
        isRunning.value = false;
        onEndProcess?.call();
        _logger.log(
          'Clone [INFO]: ✅ '
          'Repositorio clonado exitosamente',
        );
        return true;
      } else {
        isRunning.value = false;
        onEndProcess?.call();
        _logger.log(
          'Clone [Error]: ❌ No se pudo clonar el '
          'repositorio. El proceso terminó con código de salida: $exitCode',
        );
        return false;
      }
    } catch (e) {
      isRunning.value = false;
      onEndProcess?.call();
      _logger.log('❌ Error clonando: $e');
      return false;
    }
  }

  // Ejecutar docker-compose up
  Future<bool> startDockerCompose(
    bool fullBuild, {
    required String imageName,
    required void Function(Directory) onFail,
    required Future<String?> Function()? onRequestSudo,
    List<String> launchOptions = const <String>[],
  }) async {
    isRunning.value = true;
    _logger.log('🚀 Iniciando docker-compose...');
    final String path = await appDirectory(imageName);

    try {
      final bool hasPermissions = await checkPermissions();
      if (!hasPermissions) {
        _logger.log('🚫 No se puede continuar debido a problemas de permisos');
        return false;
      }

      final ProcessResult containerCheck =
          await Process.run('docker', ['run', '--rm', 'hello-world']);
      String? sudoToken;

      // we require sudo
      if (containerCheck.exitCode != 0 ||
          containerCheck.stderr != null &&
              containerCheck.stderr.isNotEmpty &&
              containerCheck.stderr.contains('permission denied')) {
        sudoToken = await onRequestSudo?.call();
        if (sudoToken == null || sudoToken.isEmpty) {
          _logger.log('🚫 Credenciales inválidas, no se podrá ejecutar '
              'la imagen sin permisos de superusuario');
          return false;
        }
      }

      final bool exist =
          await DockerImageVerifier.instance.checkDockerComposeFileExistence(
        path,
        log: (value) {
          _logger.log(value);
        },
        onFail: () {
          isRunning.value = false;
        },
      );
      if (exist) {
        return false;
      }

      // Ejecutar docker-compose up en segundo plano
      final Process process = await Process.start(
        'docker-compose',
        [
          'up',
          if (fullBuild) '--build',
          if (fullBuild) '--no-cache',
          ...launchOptions,
        ],
        workingDirectory: path,
        runInShell: true,
      );

      process.stdout
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((line) {
        _logger.log('📦 $line');
      });

      process.stderr
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((line) {
        _logger.log('⚠️ $line');
      });

      process.exitCode.then((code) {
        isRunning.value = false;
        if (code == 0) {
          _logger.log('✅ docker-compose terminó exitosamente');
        } else {
          _logger.log('❌ docker-compose terminó con código de error: $code');
        }
      });

      return true;
    } catch (e) {
      _logger.log('❌ Error iniciando docker-compose: $e');
      return false;
    } finally {
      isRunning.value = false;
      onFail(Directory(path));
    }
  }

  // Detener los contenedores
  Future<bool> stopDockerCompose({
    required String imageName,
  }) async {
    try {
      _logger.log('🛑 Deteniendo contenedores...');

      final String path = await appDirectory(imageName);
      final ProcessResult result = await Process.run(
        'docker-compose',
        ['down'],
        workingDirectory: path,
      );

      if (result.exitCode == 0) {
        _logger.log('✅ Contenedores detenidos');
        return true;
      } else {
        _logger.log('❌ Error deteniendo contenedores: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.log('❌ Error deteniendo docker-compose: $e');
      return false;
    } finally {
      isRunning.value = false;
    }
  }

  // Verificar estado de los contenedores
  Future<Map<String, String>> getContainerStatus(String imageName) async {
    try {
      // docker images <repo:tag>
      final ProcessResult result = await Process.run(
        'docker',
        ['images', imageName],
      );

      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        final Map<String, String> services = <String, String>{};
        final List<String> lines = result.stdout.toString().trim().split('\n');

        for (int i = 0; i < lines.length; i++) {
          final String line = lines[i];
          try {
            final service = json.decode(line);
            services[service['Service']] = service['State'];
          } catch (e) {
            // Ignorar líneas que no son JSON válido
          }
        }

        return services;
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<String> appDirectory(String name, {String? path}) async {
    final Directory dir =
        path != null ? Directory('') : await getApplicationCacheDirectory();
    return path_package.join(
      path ?? dir.path,
      name,
    );
  }
}
