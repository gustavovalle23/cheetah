import 'dart:async';
import 'dart:io';

typedef Middleware = Future<void> Function(HttpRequest req, HttpResponse res);

class Route {
  final String path;
  final String method;
  final Middleware handler;

  Route(this.path, this.method, this.handler);
}

class Cheetah {
  final _middlewares = <Middleware>[];
  final _routes = <Route?>[];

  Middleware? _errorHandler;

  void use(Middleware middleware) {
    _middlewares.add(middleware);
  }

  void addRoute(String method, String path, Middleware handler) {
    _routes.add(Route(path, method, handler));
  }

  void get(String path, Middleware handler) {
    addRoute('GET', path, handler);
  }

  void post(String path, Middleware handler) {
    addRoute('POST', path, handler);
  }

  void setErrorHandler(Middleware handler) {
    _errorHandler = handler;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final path = request.uri.path;
      final method = request.method;

      final route = _routes.firstWhere(
        (r) => r?.path == path && r?.method == method,
        orElse: () => null,
      );

      if (route != null) {
        for (var middleware in _middlewares) {
          await middleware(request, request.response);
        }

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

  Future<void> listen({String host = 'localhost', int port = 8080}) async {
    final server = await HttpServer.bind(host, port);
    print('Cheetah server running at http://$host:$port');
    await for (var request in server) {
      await _handleRequest(request);
    }
  }
}
