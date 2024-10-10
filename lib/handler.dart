import 'dart:io';
import 'dart:async';
import 'dart:mirrors';
import 'package:cheetah/decorators/controller.dart';
import 'package:collection/collection.dart';

import 'package:cheetah/types.dart';
import 'package:cheetah/router.dart';
import 'package:cheetah/middleware.dart';
import 'package:cheetah/decorators/http_methods.dart';

class RequestHandler {
  final List<Route> _routes = [];
  final MiddlewareManager _middlewareManager = MiddlewareManager();

  Middleware? _errorHandler;

  void use(Middleware middleware) {
    _middlewareManager.use(middleware);
  }

  void addRoute(String method, String path, Middleware handler) {
    _routes.add(Route(path, method, handler));
  }

  void addController(Object controller) {
    ClassMirror classMirror = reflectClass(controller.runtimeType);

    InstanceMirror? controllerAnnotation =
        classMirror.metadata.firstWhereOrNull(
      (meta) => meta.reflectee is Controller,
    );

    String basePath = '';
    if (controllerAnnotation != null) {
      Controller controllerMetadata =
          controllerAnnotation.reflectee as Controller;
      basePath = controllerMetadata.path;
      if (controllerMetadata.version != null) {
        basePath = '/${controllerMetadata.version}$basePath';
      }
    }

    classMirror.declarations.forEach((symbol, declaration) {
      if (declaration is MethodMirror && declaration.isRegularMethod) {
        InstanceMirror? getAnnotation = declaration.metadata.firstWhereOrNull(
          (meta) => meta.reflectee is Get,
        );
        InstanceMirror? postAnnotation = declaration.metadata.firstWhereOrNull(
          (meta) => meta.reflectee is Post,
        );

        if (getAnnotation != null) {
          String path = (getAnnotation.reflectee as Get).path;
          _registerRoute('GET', '$basePath$path', controller, declaration);
        } else if (postAnnotation != null) {
          String path = (postAnnotation.reflectee as Post).path;
          _registerRoute('POST', '$basePath$path', controller, declaration);
        }
      }
    });
  }

  void _registerRoute(String method, String path, Object controller,
      MethodMirror methodMirror) {
    addRoute(method, path,
        (HttpRequest req, HttpResponse res, Future<void> Function() next,
            [Map<String, String>? queryParams]) async {
      InstanceMirror instanceMirror = reflect(controller);

      try {
        instanceMirror.invoke(methodMirror.simpleName, [req, res, queryParams]);

        await next();
      } catch (e) {
        res.statusCode = HttpStatus.internalServerError;
        res.write('Internal Server Error: $e');
        await res.close();
      }
    });
  }

  Future<void> handleRequest(HttpRequest request) async {
    try {
      final path = request.uri.path;
      final method = request.method;

      final queryParams = request.uri.queryParameters;

      Route? route = _routes.firstWhereOrNull(
        (r) => r.matches(path) && r.method == method,
      );

      if (route != null) {
        await _middlewareManager.execute(request, request.response);

        final params = route.extractParams(path);
        request.response.headers.add('X-Params', params.toString());

        await route.handler(
            request, request.response, () async {}, queryParams);
      } else {
        print('Request: ${request.method} ${request.uri.path} - $_routes');
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('404 Not Found')
          ..close();
      }
    } catch (e) {
      if (_errorHandler != null) {
        await _errorHandler!(request, request.response, () async {});
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
