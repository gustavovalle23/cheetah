import 'dart:async';
import 'dart:io';

import 'package:cheetah/middleware.dart';
import 'package:cheetah/router.dart';
import 'package:cheetah/types.dart';

class RequestHandler {
  final List<Route?> _routes = [];
  final MiddlewareManager _middlewareManager = MiddlewareManager();

  Middleware? _errorHandler;

  void use(Middleware middleware) {
    _middlewareManager.use(middleware);
  }

  void addRoute(String method, String path, Middleware handler) {
    _routes.add(Route(path, method, handler));
  }

  Future<void> handleRequest(HttpRequest request) async {
    try {
      final path = request.uri.path;
      final method = request.method;

      final route = _routes.firstWhere(
        (r) => r?.matches(path) == true && r?.method == method,
        orElse: () => null,
      );

      if (route != null) {
        await _middlewareManager.execute(request, request.response);

        final params = route.extractParams(path);
        request.response.headers.add('X-Params', params.toString());

        await route.handler(request, request.response);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('404 Not Found')
          ..close();
      }
    } catch (e) {
      if (_errorHandler != null) {
        await _errorHandler!(request, request.response);
      } else {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('500 Internal Server Error: $e')
          ..close();
      }
    }
  }

  void setErrorHandler(Middleware handler) {
    _errorHandler = handler;
  }
}
