import 'dart:io';

// this is hidden from the user
void main(List<String> arguments) {
  // modify the entry point so that it exports the handler so that it can be imported
  if (arguments.isEmpty) {
    print('Please provide a file path as an argument');
    exit(1);
  }

  final filePath = arguments[0];

  final file = File(filePath);
  if (!file.existsSync()) {
    print('File does not exist: $filePath');
    exit(1);
  }

  final lines = file.readAsLinesSync();

  int handlerLineIndex;
  String handlerLine;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (line.trim().startsWith('Handler ')) {
      handlerLineIndex = i;
      handlerLine = line.trim();
      print("found handler line");
      print(handlerLine);
      break;
    }
  }

  if (handlerLineIndex == null) {
    print('Handler definition not found in file: $filePath');
    exit(1);
  }

  final modifiedLines = <String>[];

  // Add all lines before the main function
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    modifiedLines.add(line);
    if (line.trim().contains('void main')) {
      // Duplicate handler definition line right before main function
      modifiedLines.insert(i, handlerLine);
    }
  }

  final modifiedContent = modifiedLines.join('\n');

  file.writeAsStringSync(modifiedContent);

  print('Handler definition added to file: $filePath');
}
