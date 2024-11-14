AWS Documentation => https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html

Handler naming conventions

For Lambda functions in Go, you can use any name for the handler. In this example, the handler method name is handleRequest. To reference the handler value in your code, you can use the \_HANDLER environment variable.

For Go functions deployed using a .zip deployment package, the executable file that contains your function code must be named bootstrap. In addition, the bootstrap file must be at the root of the .zip file. For Go functions deployed using a container image, you can use any name for the executable file.
