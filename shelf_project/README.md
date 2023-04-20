## Files
- `bin/server.dart`: The Shelf server entrypoint which contains the Shelf handler. This is defined by the user.
- `bin/handler_exporter.dart`: Running this will modify the user's Shelf server entrypoint so that it exports the Shelf handler, making it so that the lambda runner can import the handler and break it down into AWS Lambda routes.
- `bin/generate_lambda_main.dart`: Running this generates the AWS Lambda function handler which we will then compile, zip, and deploy.

## Creating AWS Lambda deployment package
```
cd bin
dart run handler_exporter.dart server.dart
dart run generate_lambda_main.dart server.dart
dart compile exe bin/main_old.dart -o bootstrap && zip -j lambda.zip bootstrap
```

## Deploying to AWS Lambda
Create an AWS Lambda function using the lambda.zip. Create and deploy an API Gateway REST API and create a path using the `{proxy+}` notation to match all sub-routes. 

## Sample endpoint
Here's an endpoint you can invoke to test the API.

https://vz2xim1m05.execute-api.us-west-2.amazonaws.com/prod

Test it out!

`curl --location --request GET 'https://vz2xim1m05.execute-api.us-west-2.amazonaws.com/prod/mooncake'`

`curl --location --request GET 'https://vz2xim1m05.execute-api.us-west-2.amazonaws.com/prod/chookity'`