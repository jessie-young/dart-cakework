import 'dart:io';
import 'package:shelf/shelf_io.dart';

import 'mooncake.dart';
import 'mooncake-fancy.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final _router = Router()
  ..get('/hello', _hello)
  ..get('/mooncake', _mooncakeHandler)
  ..get('/chookity', _chookityHandler);

Response _hello(Request req) {
  return Response.ok("hello");
}

Response _mooncakeHandler(Request req) {
  return Response.ok(mooncake);
}

Response _chookityHandler(Request req) {
  return Response.ok(chookity);
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  Handler handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
