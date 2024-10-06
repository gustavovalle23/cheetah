import 'dart:io';
import 'dart:async';

typedef Middleware = Future<void> Function(
  HttpRequest req,
  HttpResponse res,
  Future<void> Function() next, [
  Map<String, String>? queryParams,
]);
