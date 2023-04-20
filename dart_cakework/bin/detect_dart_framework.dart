import 'dart:io';
// import 'package:package_config/package_config.dart';
import 'package:yaml/yaml.dart';

Future<String?> detectServerFramework(String projectDirectory) async {
  // convert projectDirectory which can be relative to a Directory object
  Directory directory = Directory(projectDirectory);

  // Read in the pubspec.yaml file
  File pubspecFile = File('${directory.path}/pubspec.yaml');
  String pubspecContent = pubspecFile.readAsStringSync();
  Map yaml = loadYaml(pubspecContent);

  if (yaml['dependencies'].containsKey('shelf')) {
    return "shelf";
  }
  if (yaml['dependencies'].containsKey('dart_frog')) {
    return "dart_frog";
  }
  if (yaml['dependencies'].containsKey('serverpod')) {
    return "serverpod";
  }

  return null;
  // TODO add other frameworks
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart detect_dart_framework.dart <directory>');
    return;
  }

  String? framework = await detectServerFramework(args[0]);
  if (framework != null) {
    print('Detected server framework: $framework');
  } else {
    print('No server framework detected');
  }
}
