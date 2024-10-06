import 'dart:async';
import 'dart:io';

typedef Middleware = Future<void> Function(
    HttpRequest req, HttpResponse res, Future<void> Function() next);
