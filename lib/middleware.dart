import 'dart:io';

import 'package:cheetah/types.dart';

class MiddlewareManager {
  final _middlewares = <Middleware>[];

  void use(Middleware middleware) {
    _middlewares.add(middleware);
  }

  Future<void> execute(HttpRequest req, HttpResponse res) async {
    int index = 0;

    Future<void> next() async {
      if (index < _middlewares.length) {
        final middleware = _middlewares[index];
        index++;
        await middleware(req, res, next);
      }
    }

    await next();
  }
}
