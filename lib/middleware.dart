import 'dart:async';
import 'dart:io';

import 'package:cheetah/types.dart';

class MiddlewareManager {
  final _middlewares = <Middleware>[];

  void use(Middleware middleware) {
    _middlewares.add(middleware);
  }

  Future<void> execute(HttpRequest request, HttpResponse response) async {
    for (var middleware in _middlewares) {
      await middleware(request, response);
    }
  }
}
