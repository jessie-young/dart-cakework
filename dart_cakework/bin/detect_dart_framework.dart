import 'dart:io';
import 'package:package_config/package_config.dart';

void detectServerFramework(String projectDirectory) async {
  // convert projectDirectory which can be relative to a Directory object
  Directory directory = Directory(projectDirectory);
  var packageConfig = await findPackageConfig(directory);
  if (packageConfig == null) {
    print('Failed to locate or read package config.');
  } else {
    print('This package depends on ${packageConfig.packages.length} packages:');
    for (var package in packageConfig.packages) {
      print('- ${package.name}');
    }
  }

  // Look for common dependencies of server frameworks
  final shelfPackage = packageConfig.packages
      .firstWhere((pkg) => pkg.name == 'shelf', orElse: () => null);
  final aqueductPackage = packageConfig.packages
      .firstWhere((pkg) => pkg.name == 'aqueduct', orElse: () => null);
  final serverpodPackage = packageConfig.packages
      .firstWhere((pkg) => pkg.name == 'serverpod', orElse: () => null);

  // Print the detected server framework, if any
  if (shelfPackage != null) {
    print('Detected Shelf framework');
  } else if (aqueductPackage != null) {
    print('Detected Aqueduct framework');
  } else if (serverpodPackage != null) {
    print('Detected Serverpod framework');
  } else {
    print('No server framework detected');
  }
  // }
}

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart detect_dart_framework.dart <directory>');
    return;
  }

  detectServerFramework(args[0]);
}
