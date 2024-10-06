import 'dart:io';
import 'dart:async';
import 'package:cheetah/types.dart';
import 'package:cheetah/handler.dart';

class Cheetah {
  final RequestHandler _requestHandler = RequestHandler();
  HttpServer? _server;
  Timer? _reloadDebounce;

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

  Future<void> _startServer(
      {String host = 'localhost', int port = 8080}) async {
    if (_server != null) {
      await _server!.close();
    }

    _server = await HttpServer.bind(host, port);
    print('Cheetah server running at http://$host:$port');

    await for (HttpRequest request in _server!) {
      await _requestHandler.handleRequest(request);
    }
  }

  void _watchForChanges(void Function() onFileChange) {
    final Directory dir = Directory.current;

    dir.watch(recursive: true).listen((event) {
      if (event is FileSystemModifyEvent) {
        if (_reloadDebounce?.isActive ?? false) _reloadDebounce!.cancel();
        _reloadDebounce = Timer(Duration(milliseconds: 500), onFileChange);
      }
    });
  }

  Future<void> listen({
    String host = 'localhost',
    int port = 8080,
    bool enableHotReload = false,
  }) async {
    print("Starting the server...");
    _startServer(host: host, port: port);

    if (enableHotReload) {
      print('Hot reload enabled. Watching for file changes...');
      _watchForChanges(() async {
        print('File change detected. Reloading server...');
        await _startServer(host: host, port: port);
      });
    }

    print("Server is running.");
  }
}
