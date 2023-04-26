import './routes/a/b/world.dart' as _a_b_world;
import './routes/hello.dart' as _hello;
import './routes/world.dart' as _world;
import './routes/index.dart' as _index;
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'dart:async';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:dart_frog/src/_internal.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;

Handler<AwsALBEvent> createLambdaFunction(shelf.Handler handler) {
  return (Context context, AwsALBEvent request) async {
    Map<String, String> headersMap = convertMap(request.headers);

    Uri uri =
        Uri(scheme: 'https', host: headersMap["Host"], path: request.path);

    var shelfRequest = shelf.Request(
      request.httpMethod!,
      uri,
      headers: headersMap,
      body: request.body == null ? null : request.body,
    );

    var shelfResponse = await handler(shelfRequest);

    var body = await shelfResponse.readAsString();

    return InvocationResult(
        context.requestId!,
        AwsApiGatewayResponse(
            body: body,
            isBase64Encoded: false,
            headers: shelfResponse.headers,
            statusCode: shelfResponse.statusCode));
  };
}

Response onRequest(RequestContext context) {
  return Response(body: 'world!');
}

Future<void> main() async {
  final router = shelf_router.Router()
      ..all('/index', toShelfHandler(_index.onRequest))

      ..all('/world', toShelfHandler(_world.onRequest))

      ..all('/hello', toShelfHandler(_hello.onRequest))

      ..all('/a/b/world', toShelfHandler(_a_b_world.onRequest))

;
  // code generation process will add routes here

  shelf.Handler handler =
      shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(router);

  // TODO handle middleware
  var lambda = createLambdaFunction(handler);

  Runtime()
    ..registerHandler<AwsALBEvent>("hello.ALB", lambda)
    ..invoke();
}

Map<String, String> convertMap(Map<String, dynamic>? originalMap) {
  Map<String, String> newMap = {};
  if (originalMap != null) {
    for (String key in originalMap.keys) {
      dynamic value = originalMap[key];
      newMap[key] = value.toString();
    }
  }
  return newMap;
}