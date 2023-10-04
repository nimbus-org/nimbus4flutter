# Nimbus Generator

nimbus_generator is a type conversion [Nimbus](https://github.com/nimbus-org/nimbus4flutter) client generator using [source_gen](https://github.com/dart-lang/source_gen) and inspired by [Chopper](https://github.com/lejard-h/chopper) and [Retrofit](https://github.com/square/retrofit).

## Usage

### Generator

Add the generator to your dev dependencies

```yaml
dependencies:
  nimbus4flutter: any
  nimbus_annotation: any

dev_dependencies:
  nimbus_generator: any
  build_runner: any
```

### Define and Generate your API

```dart
import 'package:http/http.dart';
import 'package:nimbus4flutter/nimbus4flutter.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart';

part 'example.g.dart';

@NimbusApi()
abstract class ApiService {
  factory ApiService({
    required String baseUrl,
    ApiServerHttpRequestBuilder? requestBuilder,
    ApiServerHttpResponseParser? responseParser,
  }) = _ApiService;

  @GET('/tasks')
  Future<List<Task>> getTasks();
}

@DatasetSerializable()
class Task {
  const Task({this.common});

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  @DatasetHeader()
  final CommonSchema? common;

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@SchemaSerializable()
class CommonSchema {
  CommonSchema({this.resultCode, this.resultMessage});

  factory CommonSchema.fromJson(Map<String, dynamic> json) =>
      _$CommonSchemaFromJson(json);

  static RecordSchema? get schema => _$CommonSchema();

  Map<String, dynamic> toJson() => _$CommonSchemaToJson(this);

  final String? resultCode;
  final String? resultMessage;
}
```

then run the generator

```sh
# dart
dart pub run build_runner build

# flutter	
flutter pub run build_runner build
```

### Use it

```dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:retrofit_example/example.dart';

final logger = Logger();

void main(List<String> args) {
  final client = ApiService(
    baseUrl: 'localhost:8080', 
    requestBuilder:  (request, method, input) async {
        request.headers['Content-Type'] = 'application/json; charset=utf-8';
        request.as<http.Request>()?.body = jsonEncode(input);
    },
    responseParser: (response, method, output) async {
        if (response.statusCode != HttpStatus.ok) {
          throw Exception('error status = ${response.statusCode}');
        }
        if (response is http.Response) {
          final json = const JsonDecoder().convert(response.body);

          (output as Map<String, dynamic>).addAll(json);
        }
    }
  );

  client.getTasks().then((it) => logger.i(it));
}
```