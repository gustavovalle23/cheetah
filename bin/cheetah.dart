import 'package:cheetah/cheetah.dart';

void main() async {
  final app = Cheetah();

  app.use((req, res) async {
    print('Request: ${req.method} ${req.uri.path}');
  });

  app.get('/', (req, res) async {
    res
      ..write('Welcome to Cheetah!')
      ..close();
  });

  app.get('/hello', (req, res) async {
    res
      ..write('Hello from Cheetah!')
      ..close();
  });

  app.post('/data', (req, res) async {
    res
      ..write('Data received via POST!')
      ..close();
  });

  app.get('/users/:id', (req, res) async {
    final params = req.response.headers.value('X-Params');
    res
      ..write('User ID: $params')
      ..close();
  });

  app.setErrorHandler((req, res) async {
    res
      ..statusCode = 500
      ..write('Oops! Something went wrong.')
      ..close();
  });

  await app.listen();
}
