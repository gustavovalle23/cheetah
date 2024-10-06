import 'dart:io';

import 'package:test/test.dart';
import 'package:cheetah/handler.dart';
import 'package:mockito/mockito.dart';

class MockHttpRequest extends Mock implements HttpRequest {}

class MockHttpResponse extends Mock implements HttpResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

void main() {
  group('RequestHandler', () {
    late RequestHandler requestHandler;
    late MockHttpRequest mockRequest;
    late MockHttpResponse mockResponse;
    late MockHttpHeaders mockHeaders;

    setUp(() {
      requestHandler = RequestHandler();
      mockRequest = MockHttpRequest();
      mockResponse = MockHttpResponse();
      mockHeaders = MockHttpHeaders();

      // Ensure proper mocking of the response and headers
      when(mockRequest.response).thenReturn(mockResponse);
      when(mockResponse.headers).thenReturn(mockHeaders);
    });

    test('should execute middleware and route handler on matching route',
        () async {
      const path = '/test';
      const method = 'GET';

      when(mockRequest.uri).thenReturn(Uri.parse(path));
      when(mockRequest.method).thenReturn(method);

      requestHandler.addRoute(method, path, (req, res, next,
          [Map<String, String>? queryParams]) async {
        res.write('Route matched');
        await next();
      });

      await requestHandler.handleRequest(mockRequest);

      verify(mockResponse.write('Route matched')).called(1);
      verify(mockResponse.close()).called(1);
    });

    test('should return 404 for unmatched route', () async {
      const path = '/unmatched';
      const method = 'GET';

      when(mockRequest.uri).thenReturn(Uri.parse(path));
      when(mockRequest.method).thenReturn(method);

      await requestHandler.handleRequest(mockRequest);

      verify(mockResponse.statusCode = HttpStatus.notFound).called(1);
      verify(mockResponse.write('404 Not Found')).called(1);
      verify(mockResponse.close()).called(1);
    });

    test('should execute error handler on exception', () async {
      const path = '/error';
      const method = 'GET';

      when(mockRequest.uri).thenReturn(Uri.parse(path));
      when(mockRequest.method).thenReturn(method);

      requestHandler.setErrorHandler((req, res, next,
          [Map<String, String>? queryParams]) async {
        res.write('Error handled');
        await next();
      });

      requestHandler.addRoute(method, path, (req, res, next,
          [Map<String, String>? queryParams]) async {
        throw Exception('Test Exception');
      });

      await requestHandler.handleRequest(mockRequest);

      verify(mockResponse.write('Error handled')).called(1);
      verify(mockResponse.close()).called(1);
    });

    test('should execute middleware before route handler', () async {
      const path = '/middleware';
      const method = 'GET';

      when(mockRequest.uri).thenReturn(Uri.parse(path));
      when(mockRequest.method).thenReturn(method);

      // Middleware that should run before the route handler
      requestHandler
          .use((req, res, next, [Map<String, String>? queryParams]) async {
        res.write('Middleware executed');
        await next();
      });

      requestHandler.addRoute(method, path, (req, res, next,
          [Map<String, String>? queryParams]) async {
        res.write('Route handler executed');
        await next();
      });

      await requestHandler.handleRequest(mockRequest);

      verify(mockResponse.write('Middleware executed')).called(1);
      verify(mockResponse.write('Route handler executed')).called(1);
      verify(mockResponse.close()).called(1);
    });

    test('should return 500 if no error handler is set and an error occurs',
        () async {
      const path = '/error';
      const method = 'GET';

      when(mockRequest.uri).thenReturn(Uri.parse(path));
      when(mockRequest.method).thenReturn(method);

      requestHandler.addRoute(method, path, (req, res, next,
          [Map<String, String>? queryParams]) async {
        throw Exception('Test Exception');
      });

      await requestHandler.handleRequest(mockRequest);

      verify(mockResponse.statusCode = HttpStatus.internalServerError)
          .called(1);
      verify(mockResponse.write(contains('500 Internal Server Error')))
          .called(1);
      verify(mockResponse.close()).called(1);
    });

    test('should add params to headers when route params exist', () async {
      const path = '/user/123';
      const method = 'GET';

      when(mockRequest.uri).thenReturn(Uri.parse(path));
      when(mockRequest.method).thenReturn(method);

      requestHandler.addRoute(method, path, (req, res, next,
          [Map<String, String>? queryParams]) async {
        await next();
      });

      await requestHandler.handleRequest(mockRequest);

      verify(mockHeaders.add('X-Params', "{'id': '123'}")).called(1);
      verify(mockResponse.close()).called(1);
    });
  });
}
