import 'package:cheetah/types.dart';

class Route {
  final String path;
  final String method;
  final Middleware handler;

  Route(this.path, this.method, this.handler);
}
