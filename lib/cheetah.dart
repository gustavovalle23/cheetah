import 'dart:io';
import 'dart:async';

import 'package:cheetah/types.dart';
import 'package:cheetah/handler.dart';

class Cheetah {
  final RequestHandler _requestHandler = RequestHandler();

  void use(Middleware middleware) {
    _requestHandler.use(middleware);
  }

  void get(String path, Middleware handler) {
    _requestHandler.addRoute('GET', path, handler);
  }

  void post(String path, Middleware handler) {
    _requestHandler.addRoute('POST', path, handler);
  }

  void setErrorHandler(Middleware handler) {
    _requestHandler.setErrorHandler(handler);
  }

  Future<void> listen({String host = 'localhost', int port = 8080}) async {
    final server = await HttpServer.bind(host, port);
    print('Cheetah server running at http://$host:$port');
    await for (var request in server) {
      await _requestHandler.handleRequest(request);
    }
  }
}
