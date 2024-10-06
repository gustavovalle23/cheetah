import 'package:cheetah/cheetah.dart';

void main() async {
  final app = Cheetah();

  app.use((req, res, next, [queryParams]) async {
    print('Request: ${req.method} ${req.uri.path}');
    await next();
  });

  app.get('/', (req, res, next, [queryParams]) async {
    res
      ..write('Welcome to Cheetah!')
      ..close();
  });

  app.get('/hello', (req, res, next, [queryParams]) async {
    res
      ..write('Hello from Cheetah!')
      ..close();
  });

  app.post('/data', (req, res, next, [queryParams]) async {
    res
      ..write('Data received via POST!')
      ..close();
  });

  app.get('/users/:id', (req, res, next, [queryParams]) async {
    final params = req.response.headers.value('X-Params');
    res
      ..write('User ID: $params')
      ..close();
  });

  app.get('/search', (req, res, next, [queryParams]) async {
    final searchTerm = queryParams?['q'] ?? 'No query provided';
    res
      ..write('Search term: $searchTerm')
      ..close();
  });

  app.setErrorHandler((req, res, next, [queryParams]) async {
    res
      ..statusCode = 500
      ..write('Oops! Something went wrong.')
      ..close();
  });

  await app.listen();
}
