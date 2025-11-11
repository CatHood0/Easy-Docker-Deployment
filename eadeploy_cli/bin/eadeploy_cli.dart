#! /usr/bin/env dart
// Tells your system to use the Dart interpreter

import 'package:args/args.dart' show ArgParser;

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Displays this help message.')
    ..addOption('name', abbr: 'n', help: 'Greets the provided name.');

  try {
    final argResults = parser.parse(arguments);

    if (argResults['help'] == true) {
      print('Usage: eadeploy [options]');
      print('Options:');
      print(parser.usage);
      return;
    }

    final name = argResults['name'] ?? 'World';
    print('Hello, $name! from eadeploy');
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    print('Run `eadeploy --help` for usage.');
  }
}
