import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'dart:async';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:shelf/shelf.dart' as shelf;

Handler<AwsALBEvent> createLambdaFunction(shelf.Handler handler) {
  return (Context context, AwsALBEvent request) async {
    Map<String, String> headersMap = Map<String, String>.from(request.headers);

    Uri uri =
        Uri(scheme: 'https', host: headersMap["Host"], path: request.path);

    var shelfRequest = shelf.Request(
      request.httpMethod,
      uri,
      headers: headersMap,
      body: request.body == null
          ? null
          : Stream.fromIterable([request.body.codeUnits]),
    );

    var shelfResponse = await handler(shelfRequest);

    var body = await shelfResponse.readAsString();

    return InvocationResult(
        context.requestId,
        AwsApiGatewayResponse(
            body: body,
            isBase64Encoded: false,
            headers: shelfResponse.headers,
            statusCode: shelfResponse.statusCode));
  };
}

Future<void> main() async {
  var handler = my_server.handler;

  var lambda = createLambdaFunction(handler);

  Runtime()
    ..registerHandler<AwsALBEvent>("hello.ALB", lambda)
    ..invoke();
}
