import 'package:cheetah/middleware.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';

import 'package:test/test.dart';

class MockHttpRequest extends Mock implements HttpRequest {}

class MockHttpResponse extends Mock implements HttpResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

void main() {
  group('MiddlewareManager', () {
    test('executes with no middlewares', () async {
      final middlewareManager = MiddlewareManager();
      final req = MockHttpRequest();
      final res = MockHttpResponse();

      await middlewareManager.execute(req, res);
    });

    test('executes with a single middleware', () async {
      final middlewareManager = MiddlewareManager();
      final req = MockHttpRequest();
      final res = MockHttpResponse();

      bool middlewareCalled = false;
      middlewareManager.use((req, res, next) async {
        middlewareCalled = true;
        await next();
      });

      await middlewareManager.execute(req, res);
      expect(middlewareCalled, isTrue);
    });

    test('executes with multiple middlewares', () async {
      final middlewareManager = MiddlewareManager();
      final req = MockHttpRequest();
      final res = MockHttpResponse();

      List<String> executedMiddlewares = [];

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware1');
        await next();
      });

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware2');
        await next();
      });

      await middlewareManager.execute(req, res);
      expect(executedMiddlewares, equals(['middleware1', 'middleware2']));
    });

    test('middleware does not call next(), stops chain', () async {
      final middlewareManager = MiddlewareManager();
      final req = MockHttpRequest();
      final res = MockHttpResponse();

      List<String> executedMiddlewares = [];

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware1');
      });

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware2');
        await next();
      });

      await middlewareManager.execute(req, res);
      expect(executedMiddlewares, equals(['middleware1']));
    });

    test('next() called multiple times in middleware', () async {
      final middlewareManager = MiddlewareManager();
      final req = MockHttpRequest();
      final res = MockHttpResponse();

      List<String> executedMiddlewares = [];

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware1');
        await next();
        await next();
      });

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware2');
        await next();
      });

      await middlewareManager.execute(req, res);
      expect(executedMiddlewares, equals(['middleware1', 'middleware2']));
    });

    test('middleware throws error and chain stops', () async {
      final middlewareManager = MiddlewareManager();
      final req = MockHttpRequest();
      final res = MockHttpResponse();

      List<String> executedMiddlewares = [];

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware1');
        throw Exception('Error in middleware');
      });

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware2');
        await next();
      });

      expect(
        () async => await middlewareManager.execute(req, res),
        throwsA(isA<Exception>()),
      );

      expect(executedMiddlewares, equals(['middleware1']));
    });

    test('executes with asynchronous middleware', () async {
      final middlewareManager = MiddlewareManager();
      final req = MockHttpRequest();
      final res = MockHttpResponse();

      List<String> executedMiddlewares = [];

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware1');
        await Future.delayed(Duration(milliseconds: 100));
        await next();
      });

      middlewareManager.use((req, res, next) async {
        executedMiddlewares.add('middleware2');
        await next();
      });

      await middlewareManager.execute(req, res);
      expect(executedMiddlewares, equals(['middleware1', 'middleware2']));
    });
  });
}
