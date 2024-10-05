# **Cheetah** 🐆

**Cheetah** is a minimal, fast, and flexible **micro-framework** for building backend applications, inspired by **Express.js** and **Koa.js**. Written in **Dart**, Cheetah is designed for developers who want a simple, powerful tool for creating web servers and APIs with minimal overhead.

## **Features**
- 🏗️ **Middleware Support**: Add reusable logic like logging, authentication, or data parsing.
- 🚏 **Routing**: Simple, intuitive routing for handling HTTP GET, POST, and other methods.
- 🔄 **Error Handling**: Customizable error handling for robust applications.
- ⚡ **Asynchronous**: Fully asynchronous for scalable applications.
- 📝 **Lightweight**: Minimal and fast, with only the essentials for a micro-framework.

---

## **Inspiration**

Cheetah draws inspiration from popular micro-frameworks like:

- **[Express.js](https://expressjs.com/)** (Node.js) for its simple middleware and routing system.
- **[Koa.js](https://koajs.com/)** for its minimalist design and focus on extensibility.

The goal of Cheetah is to bring similar concepts to the Dart ecosystem, enabling developers to build backend services quickly and efficiently with a focus on simplicity and performance.

---

## **Quick Start**

### **1. Install Dart**

Make sure Dart is installed on your machine. You can download it from [Dart's official website](https://dart.dev/get-dart).

### **2. Create a Dart Project**

Create a new Dart project for your application:

```bash
dart create -t package-simple my_app
cd my_app
```

### **3. Add Cheetah to Your Project**

In your `pubspec.yaml` file, add the following dependencies:

```yaml
dependencies:
  cheetah: ^0.0.1
```

Then run:
```bash
dart pub get
```

### **4. Create Your Server**

Create a new Dart file in the `bin/` directory, e.g., `bin/main.dart`. Use the following code to get started with **Cheetah**:

```dart
import 'package:cheetah/cheetah.dart';

void main() async {
  final app = Cheetah();

  // Middleware: Log all requests
  app.use((req, res) async {
    print('Request: ${req.method} ${req.uri.path}');
  });

  // Simple GET route for root
  app.get('/', (req, res) async {
    res
      ..write('Welcome to Cheetah!')
      ..close();
  });

  // GET route for /hello
  app.get('/hello', (req, res) async {
    res
      ..write('Hello from Cheetah!')
      ..close();
  });

  // POST route for /data
  app.post('/data', (req, res) async {
    res
      ..write('Data received via POST!')
      ..close();
  });

  // Error handling
  app.setErrorHandler((req, res) async {
    res
      ..statusCode = 500
      ..write('Oops! Something went wrong.')
      ..close();
  });

  // Start the server
  await app.listen();
}
```

### **5. Run the Server**

Run your server using the Dart command:

```bash
dart run bin/main.dart
```

You should see output like:

```bash
Cheetah server running at http://localhost:8080
```

Now, visit `http://localhost:8080/` in your browser, and you should see the message "Welcome to Cheetah!".

---

## **Features and API Reference**

### **1. Middleware**

Cheetah provides middleware support to allow you to handle tasks like logging, request transformations, authentication, and more. Middleware functions in Cheetah are asynchronous and follow the signature:

```dart
Future<void> Middleware(HttpRequest req, HttpResponse res);
```

#### **Usage Example**:

```dart
app.use((req, res) async {
  print('Request: ${req.method} ${req.uri.path}');
});
```

---

### **2. Routing**

You can define routes in Cheetah using the `get`, `post`, and `addRoute` methods. Routes are matched based on the HTTP method (GET, POST, etc.) and the URL path.

#### **GET Route**:

```dart
app.get('/hello', (req, res) async {
  res
    ..write('Hello from Cheetah!')
    ..close();
});
```

#### **POST Route**:

```dart
app.post('/data', (req, res) async {
  res
    ..write('Data received!')
    ..close();
});
```

#### **General Route (For Other HTTP Methods)**:

You can use `addRoute` for more control if needed.

```dart
app.addRoute('PUT', '/update', (req, res) async {
  res
    ..write('Data updated!')
    ..close();
});
```

---

### **3. Error Handling**

You can define custom error handling middleware with `setErrorHandler`. This handler will be invoked whenever an uncaught error occurs in any middleware or route.

#### **Example**:

```dart
app.setErrorHandler((req, res) async {
  res
    ..statusCode = 500
    ..write('Oops! Something went wrong.')
    ..close();
});
```

---

### **4. Listening to Requests**

To start the server, use the `listen` method:

```dart
app.listen({String host = 'localhost', int port = 8080});
```

This method binds the server to the specified host and port, and begins handling incoming requests.

---

### **5. Request/Response Object**

Cheetah uses Dart's built-in `HttpRequest` and `HttpResponse` objects. You can access them in your route handlers and middleware to handle requests and send responses.

- **HttpRequest**: Provides access to request data (method, path, headers, body).
- **HttpResponse**: Used to send data back to the client (write data, set status code, close connection).

---

## **Complete Example**

Here’s a more complete example that demonstrates middleware, multiple routes, and error handling:

```dart
import 'package:cheetah/cheetah.dart';

void main() async {
  final app = Cheetah();

  // Middleware for logging
  app.use((req, res) async {
    print('Request: ${req.method} ${req.uri.path}');
  });

  // Middleware for authentication
  app.use((req, res) async {
    if (req.headers.value('Authorization') == null) {
      res
        ..statusCode = 401
        ..write('Unauthorized')
        ..close();
    }
  });

  // GET Route
  app.get('/hello', (req, res) async {
    res
      ..write('Hello from Cheetah!')
      ..close();
  });

  // POST Route
  app.post('/data', (req, res) async {
    res
      ..write('Data received via POST')
      ..close();
  });

  // Error handler
  app.setErrorHandler((req, res) async {
    res
      ..statusCode = 500
      ..write('An error occurred.')
      ..close();
  });

  // Start the server
  await app.listen();
}
```

---

## **Advanced Features (Coming Soon)**

While **Cheetah** is a minimal framework, future versions may include optional features such as:

- **Route Parameters**: Dynamic route matching with URL parameters.
- **Body Parsing**: Built-in JSON and form-data body parsing for incoming requests.
- **WebSocket Support**: Adding real-time WebSocket support.
- **Static File Serving**: Serving static files like CSS, JS, and images.

---

## **Contributing**

Contributions are welcome! If you'd like to contribute, feel free to submit pull requests or report issues on the GitHub repository.

### **Development Setup**

1. Fork and clone the repository.
2. Make your changes in a feature branch.
3. Submit a pull request with a detailed description of your changes.

---

## **License**

**Cheetah** is open-source software licensed under the **MIT License**.

---

## **Feedback & Support**

Feel free to open issues on GitHub if you encounter any problems or have suggestions for improvements. You can also reach out to the maintainer via email or GitHub discussions.

---

## **Thank You!**

Thank you for using **Cheetah**! We hope this framework helps you build fast, scalable, and simple web services in Dart.

---
