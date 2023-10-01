import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart'
    show NimbusApi, GET, POST, DELETE, PUT, PATCH, HEAD, OPTIONS;

const _analyzerIgnores =
    '// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers';

class NimbusSupporterGenerator extends GeneratorForAnnotation<NimbusApi> {
  static const String _baseUrlVar = 'baseUrl';
  static const String _requestBuilderType = 'ApiServerHttpRequestBuilder';
  static const String _requestBuilder = 'requestBuilder';
  static const String _responseParserType = 'ApiServerHttpResponseParser';
  static const String _responseParser = 'responseParser';

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final name = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$name`.',
        todo: 'Remove the [NimbusApi] annotation from `$name`.',
      );
    }
    return _implementClass(element, annotation);
  }

  String _implementClass(ClassElement element, ConstantReader? annotation) {
    final className = element.name;

    final annotClassConsts = element.constructors
        .where((c) => !c.isFactory && !c.isDefaultConstructor);

    final library = Library(
      (l) => l.body.addAll(
        [
          Field((f) => f
            ..name = '_kServerName'
            ..modifier = FieldModifier.constant
            ..assignment = Code("'$className'")),
        ],
      ),
    );

    final classBuilder = Class((c) {
      c
        ..name = '_$className'
        ..implements.add(refer(className))
        ..constructors.addAll(
          annotClassConsts.map(
            (e) => _generateConstructor(_baseUrlVar, superClassConst: e),
          ),
        )
        ..methods.addAll(_parseMethods(element));

      if (annotClassConsts.isEmpty) {
        c.constructors
            .add(_generateConstructor(_baseUrlVar, methods: element.methods));
      }
    });

    final emitter = DartEmitter(useNullSafetySyntax: true);

    return DartFormatter().format([
      _analyzerIgnores,
      library.accept(emitter),
      classBuilder.accept(emitter)
    ].join('\n\n'));
  }

  Constructor _generateConstructor(baseUrl,
      {ConstructorElement? superClassConst, Iterable<MethodElement>? methods}) {
    return Constructor((c) {
      c.optionalParameters.addAll([
        Parameter(
          (p) => p
            ..name = 'baseUrl'
            ..type = refer('String')
            ..required = true,
        ),
        Parameter(
          (p) => p
            ..name = _requestBuilder
            ..type = refer('$_requestBuilderType?')
            ..named = true,
        ),
        Parameter(
          (p) => p
            ..name = _responseParser
            ..type = refer('$_responseParserType?')
            ..named = true,
        ),
      ]);

      final blocks = <Code>[];
      blocks.add(declareFinal('urlSplit')
          .assign(CodeExpression(Code("$_baseUrlVar.split(':')")))
          .statement);
      blocks.add(declareFinal('host')
          .assign(CodeExpression(Code("urlSplit.first")))
          .statement);
      blocks.add(declareFinal('port')
          .assign(
              CodeExpression(Code("int.tryParse(urlSplit.lastOrNull ?? '')")))
          .statement);
      blocks.add(
        Code(
          '''
ApiRegistory.registApiServer(
      ApiServerHttp(
        name: _kServerName,
        host: host,
        port: port,
        requestBuilder: requestBuilder,
        responseParser: responseParser,
      ),
    );
''',
        ),
      );
      methods?.forEach((m) {
        final methodAnnotation = _getMethodAnnotation(m);
        final httpMethod = methodAnnotation?.peek('method')?.stringValue;
        final path = literal(methodAnnotation?.peek('path')?.stringValue);

        blocks.add(Code('''
 ApiRegistory.registApi(
      ApiHttp<Map<String, dynamic>, Map<String, dynamic>, Request, Response>(
        name: '${m.name}',
        serverName: _kServerName,
        method: HttpMethod.$httpMethod,
        path: $path,
        inputCreator: (_) => {},
        outputCreator: (_) => {},
      ),
    );
'''));
      });

      c.body = Block.of(blocks);
    });
  }

  final _methodsAnnotations = const [
    GET,
    POST,
    DELETE,
    PUT,
    PATCH,
    HEAD,
    OPTIONS,
    Method,
  ];

  TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  Iterable<Method> _parseMethods(ClassElement element) => <MethodElement>[
        ...element.methods,
        ...element.mixins.expand((i) => i.methods)
      ].where((m) {
        final methodAnnot = _getMethodAnnotation(m);
        return methodAnnot != null &&
            m.isAbstract &&
            (m.returnType.isDartAsyncFuture || m.returnType.isDartAsyncStream);
      }).map((m) => _generateMethod(m)!);

  ConstantReader? _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final annot = _getMethodAnnotationByType(method, type);
      if (annot != null) {
        return annot;
      }
    }
    return null;
  }

  ConstantReader? _getMethodAnnotationByType(MethodElement method, Type type) {
    final annot =
        _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false);
    if (annot != null) {
      return ConstantReader(annot);
    }
    return null;
  }

  String _displayString(DartType? e, {bool withNullability = false}) {
    try {
      return e!.getDisplayString(withNullability: withNullability);
    } on TypeError {
      return e!.getDisplayString(withNullability: withNullability);
    } on Object {
      rethrow;
    }
  }

  DartType? _genericOf(DartType type) =>
      type is InterfaceType && type.typeArguments.isNotEmpty
          ? type.typeArguments.first
          : null;

  DartType? _getResponseType(DartType type) => _genericOf(type);

  Method? _generateMethod(MethodElement m) {
    final httpMethod = _getMethodAnnotation(m);
    if (httpMethod == null) {
      return null;
    }

    return Method((mm) {
      mm
        ..returns =
            refer(_displayString(m.type.returnType, withNullability: true))
        ..name = m.displayName
        ..types.addAll(m.typeParameters.map((e) => refer(e.name)))
        ..modifier = m.returnType.isDartAsyncFuture
            ? MethodModifier.async
            : MethodModifier.asyncStar
        ..annotations.add(const CodeExpression(Code('override')));

      /// required parameters
      mm.requiredParameters.addAll(
        m.parameters.where((it) => it.isRequiredPositional).map(
              (it) => Parameter(
                (p) => p
                  ..name = it.name
                  ..named = it.isNamed
                  ..type =
                      refer(it.type.getDisplayString(withNullability: true)),
              ),
            ),
      );

      /// optional positional or named parameters
      mm.optionalParameters.addAll(
        m.parameters.where((i) => i.isOptional || i.isRequiredNamed).map(
              (it) => Parameter(
                (p) => p
                  ..required = (it.isNamed &&
                      it.type.nullabilitySuffix == NullabilitySuffix.none &&
                      !it.hasDefaultValue)
                  ..name = it.name
                  ..named = it.isNamed
                  ..type =
                      refer(it.type.getDisplayString(withNullability: true))
                  ..defaultTo = it.defaultValueCode == null
                      ? null
                      : Code(it.defaultValueCode!),
              ),
            ),
      );
      mm.body = _generateRequest(m, httpMethod);
    });
  }

  Code _generateRequest(MethodElement m, ConstantReader httpMethod) {
    final returnType = _displayString(_getResponseType(m.type.returnType),
        withNullability: true);

    final blocks = <Code>[];
    blocks.add(declareFinal('api')
        .assign(CodeExpression(Code("ApiRegistory.getApi('${m.name}')")))
        .statement);
    blocks.add(declareFinal('context')
        .assign(CodeExpression(Code("RequestContext()")))
        .statement);
    blocks.add(declareFinal('response')
        .assign(CodeExpression(
            Code("await api?.request(request.toJson(), context)")))
        .statement);
    blocks.add(Code('return $returnType.fromJson(response);'));
    return Block.of(blocks);
  }
}
