import 'dart:io';
import 'package:test/test.dart';
import 'package:cheetah/router.dart';

void main() {
  Future<void> dummyHandler(
      HttpRequest req, HttpResponse res, Future<void> Function() next,
      [Map<String, String>? queryParams]) async {
    await next();
  }

  group('Route', () {
    test('matches exact static route', () {
      final route = Route('/home', 'GET', dummyHandler);
      expect(route.matches('/home'), isTrue);
      expect(route.matches('/about'), isFalse);
    });

    test('matches dynamic route with parameters', () {
      final route = Route('/users/:id', 'GET', dummyHandler);
      expect(route.matches('/users/123'), isTrue);
      expect(route.matches('/users/abc'), isTrue);
      expect(route.matches('/users/'), isFalse);
      expect(route.matches('/users/123/details'), isFalse);
    });

    test('extracts parameters from dynamic route', () {
      final route = Route('/users/:id', 'GET', dummyHandler);
      final params = route.extractParams('/users/123');
      expect(params, equals({'id': '123'}));
    });

    test('extracts multiple parameters from route', () {
      final route = Route('/users/:id/orders/:orderId', 'GET', dummyHandler);
      final params = route.extractParams('/users/123/orders/456');
      expect(params, equals({'id': '123', 'orderId': '456'}));
    });

    test('returns empty params when no match', () {
      final route = Route('/users/:id', 'GET', dummyHandler);
      final params = route.extractParams('/orders/123');
      expect(params, isEmpty);
    });

    test('handles complex paths', () {
      final route = Route('/files/:type/:fileId/edit', 'GET', dummyHandler);
      expect(route.matches('/files/pdf/12345/edit'), isTrue);
      final params = route.extractParams('/files/pdf/12345/edit');
      expect(params, equals({'type': 'pdf', 'fileId': '12345'}));
    });

    test('does not match if method is different', () {
      final route = Route('/home', 'POST', dummyHandler);
      expect(route.method == 'GET', isFalse);
    });

    test('matches route with special characters in path params', () {
      final route = Route('/users/:id', 'GET', dummyHandler);
      expect(route.matches('/users/abc-123_def'), isTrue);
      final params = route.extractParams('/users/abc-123_def');
      expect(params, equals({'id': 'abc-123_def'}));
    });

    test('route without parameters does not extract any params', () {
      final route = Route('/about', 'GET', dummyHandler);
      final params = route.extractParams('/about');
      expect(params, isEmpty);
    });

    test('does not match route if there is trailing slash', () {
      final route = Route('/users/:id', 'GET', dummyHandler);
      expect(route.matches('/users/123/'), isFalse);
    });

    test('matches route with query parameters but does not extract them', () {
      final route = Route('/users/:id', 'GET', dummyHandler);
      expect(route.matches('/users/123?active=true'), isTrue);
      final params = route.extractParams('/users/123');
      expect(params, equals({'id': '123'}));
    });
  });
}
