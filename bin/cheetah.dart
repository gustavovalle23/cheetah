import 'dart:io';

import 'package:cheetah/cheetah.dart';
import 'package:cheetah/decorators/controller.dart';
import 'package:cheetah/decorators/http_methods.dart';

@Controller(version: "v1", path: "custom")
class CustomController {
  @Get('/hello-controller')
  Future<void> sayHello(HttpRequest req, HttpResponse res,
      [Map<String, String>? queryParams]) async {
    res.write('Hello from controller!');
    await res.close();
  }

  @Post('/submit')
  Future<void> submitData(HttpRequest req, HttpResponse res,
      [Map<String, String>? queryParams]) async {
    res.write('Data submitted successfully!');
    await res.close();
  }
}

void main() async {
  final app = Cheetah();

  app.use((req, res, next, [queryParams]) async {
    print('Request: ${req.method} ${req.uri.path}');
    await next();
  });

  app.addController(CustomController());

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

  await app.listen(enableHotReload: true);
}
