import 'dart:io';
// import 'package:package_config/package_config.dart';
import 'package:yaml/yaml.dart';

void detectServerFramework(String projectDirectory) async {
  // convert projectDirectory which can be relative to a Directory object
  Directory directory = Directory(projectDirectory);

  print("got directory.path");
  print(directory.path);
  // Read in the pubspec.yaml file
  File pubspecFile = File('${directory.path}/pubspec.yaml');
  String pubspecContent = pubspecFile.readAsStringSync();
  Map yaml = loadYaml(pubspecContent);

  if (yaml['dependencies'].containsKey('shelf')) {
    print('Detected Shelf framework');
    return;
  }
  if (yaml['dependencies'].containsKey('dart_frog')) {
    print('Detected Dart Frog framework');
    return;
  }
  if (yaml['dependencies'].containsKey('serverpod')) {
    print('Detected Serverpod framework');
    return;
  }
  // TODO add other frameworks
}

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart detect_dart_framework.dart <directory>');
    return;
  }

  detectServerFramework(args[0]);
}
