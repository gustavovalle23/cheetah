import 'types.dart';

class Route {
  final RegExp pathRegex;
  final String method;
  final Middleware handler;
  final List<String> pathParams;

  Route(String path, this.method, this.handler)
      : pathRegex = _pathToRegExp(path),
        pathParams = _extractParams(path);

  static RegExp _pathToRegExp(String path) {
    final pattern = path.replaceAllMapped(
      RegExp(r':(\w+)'),
      (match) => r'([^/]+)',
    );
    return RegExp('^$pattern\$');
  }

  static List<String> _extractParams(String path) {
    final paramPattern = RegExp(r':(\w+)');
    return paramPattern.allMatches(path).map((m) => m[1]!).toList();
  }

  bool matches(String path) {
    return pathRegex.hasMatch(path);
  }

  Map<String, String> extractParams(String path) {
    final match = pathRegex.firstMatch(path);
    if (match == null) return {};
    return pathParams.asMap().map((i, param) => MapEntry(param, match[i + 1]!));
  }
}
