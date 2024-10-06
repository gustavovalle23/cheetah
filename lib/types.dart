import 'dart:io';

typedef Middleware = Future<void> Function(HttpRequest req, HttpResponse res);
