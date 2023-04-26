import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/src/_internal.dart';
import 'package:dart_frog/dart_frog.dart' as dart_frog;
import 'dart:async';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'dart:mirrors';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart' as shelf;
import './world.dart' as world;

class FileRoute {
  String filePath;
  String route;
  String handlerName;
  String alias;

  FileRoute(this.filePath, this.route, this.handlerName, this.alias);

  @override
  String toString() {
    return 'FileRoute{filePath: $filePath, route: $route, handlerName: $handlerName, alias: $alias}';
  }
}

shelf.Response _hello(shelf.Request req) {
  return shelf.Response.ok("hello");
}

Future<void> main(List<String> args) async {
  // issue: router needs to be defined outside of the main funcion so that
  // it can be exported
  // however, we need to do some steps before defining the router such as getting
  // all of the routes in the directory
  // issue: need to parse the http method from inside the body of
  // onRequest in order to add it to the router below
  // q: is it possible to add routes to a router without adding a method?
  // does it make sense that this code is generated using dart? ok that the
  // adapters are written in various languages, as long as they follow some sort of
  // convention
  // want: http method routing
  // need to auto-detct all the methods in each handler and
  // add separate routes to the router?

  final _router = shelf_router.Router()
    ..all("/world", toShelfHandler(world.onRequest));
  shelf.Handler handler =
      shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_router);

  //only care about the above
  // should create a separate build directory or dist directory
  // or rather - copy the runner file into the user's code, and also install the user
  // code dependencies
  // Q: how to deal with installing user's code, building user's code structure,
  // as well as installing the custom code?
  // what if things are not compatible?

  // TODO handle middleware

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final ip = InternetAddress.anyIPv4;

  final server =
      await shelf_io.serve(toShelfHandler(world.onRequest), ip, port);

  // let's say the dart frog  imports additional dependencies; need
  // to be able to support that
  // so instead of running the cli and pointing to the directory, we
  // should be adding code the existing project, installing all the existing
  // project's dependencies?
  // q: how do users refer to the dependent packages in the structure?
  //
  /**
   * detect the routes in the routes directory
   * all all the routes to a router
   * q: is it possible to just import the routes 
   * and then add all of them to a shelf router
   * add shelf router to a shelf handler
   * start the handler
   * and then share the code to conver the shelf handler or router
   * or whatever to the lambda handler? 
   * how did i do this for shelf? 
   * for shelf, simply exported the handler outside of main
   * then have my lambda handler import it
   */
  // shelf.Handler handler = toShelfHandler(onRequest);
  // var server = await shelf_io.serve(handler, 'localhost', 8080);

  if (args.length < 1) {
    print('Usage: dart dart_frog_to_lambda.dart <directory>');
    return;
  }

  String projectDirectory = args[0];
  Directory routesDirectory = Directory(projectDirectory + "/routes");

  List<FileRoute> handlerImports = [];
  // for now, assume each handler in each file is named onRequest

  List<FileSystemEntity> dartFiles = await listFiles(routesDirectory);

  // the projectDirectory is the root directory
  // there should be a directory called routes in it
  // the filepath should assume that we're current in the projectDirectory

  // TODO handle special /routes/index.dart
  for (final dartFile in dartFiles) {
    String directory = path.dirname(dartFile.path);
    late String route;
    String routePrefix = directory.split('/routes').last;
    String filenameWithoutExtension =
        path.basenameWithoutExtension(dartFile.path);
    if (routePrefix.isEmpty) {
      route = "/" + filenameWithoutExtension;
    } else {
      route = routePrefix + "/" + filenameWithoutExtension;
    }
    String alias = route.replaceAll("/", "_");
    // from ../myproject/routes/a/b/c.dart, get everything starting with routes
    String relativePath = "./routes/" + dartFile.path.split("/routes/").last;
    // otherwise, make the route whatever comes after the routes
    FileRoute fileRoute = FileRoute(relativePath, route, "onRequest", alias);
    handlerImports.add(fileRoute);
  }

  // Q: how to specify the exact path to the lambda_handler_template.dart file?
  // generate lambda handler file
  final sourceFile = File("bin/dart_frog/lambda_handler_template.dart");
  final handlerFile = File(args[0]);
  String handlerPath = path.join(projectDirectory, "lambda_handler.dart");

  final destFile = File(handlerPath);

  // Read the contents of the source file.
  final sourceContents = sourceFile.readAsLinesSync();
  // insert the code after the line Future<void> main() async {
  // create import lines
  // should look something like:
  // import 'filepath' as alias;
  List<String> routes = [];
  for (int i = 0; i < handlerImports.length; i++) {
    final importLine = "import '" +
        handlerImports[i].filePath +
        "' as " +
        handlerImports[i].alias +
        ";";
    sourceContents.insert(0, importLine);
    String route = handlerImports[i].route;
    String alias = handlerImports[i].alias;
    String newRoute = '''
      ..all('$route', toShelfHandler($alias.onRequest))
''';
    routes.add(newRoute);
  }

  routes.add(';');
  int index = sourceContents.indexWhere(
      (str) => str.contains("final router = shelf_router.Router()"));
  sourceContents.insertAll(index + 1, routes);
  // generate lines to insert inside main

  // Add an import statement for the source file to the new file.
  // final importLine = "import '${handlerFile.path}' as my_server;\n";
  // final destContents = sourceContents;
  final destString = sourceContents.join("\n");
  destFile.writeAsStringSync(destString);
  // should write the file to the user's project directory, where bin is located?

  // insert into the lambda_handler_template
  // generate the file now
  // write the imports into the beginning of the file
  // the rest is just boilerplate (refer to the lambda template)
  // after generate
}

Future<List<FileSystemEntity>> listFiles(Directory directory) async {
  List<FileSystemEntity> files = [];
  List<FileSystemEntity> contents = directory.listSync();
  for (FileSystemEntity content in contents) {
    if (content is Directory) {
      List<FileSystemEntity> subFiles = await listFiles(content);
      files.addAll(subFiles);
    } else if (content is File) {
      files.add(content);
    }
  }
  return files;
}
