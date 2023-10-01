import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'annotation_helper.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart'
    show FieldRename, RecordSerializable;
import 'package:nimbus_generator/src/dart_type_helper.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

class RecordSupporterGenerator
    extends GeneratorForAnnotation<RecordSerializable> {
  FieldRename fieldRename = FieldRename.none;

  String _getFieldFormatted(String fieldName) {
    return switch (fieldRename) {
      FieldRename.snake => fieldName.snakeCase,
      FieldRename.pascal => fieldName.pascalCase,
      _ => fieldName,
    };
  }

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final className = element.displayName;
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `$className`.',
        todo: 'Remove the [NimbusApi] annotation from `$className`.',
      );
    }

    final emitter = DartEmitter(useNullSafetySyntax: true);

    final fieldsFomatted = element.fields.where((e) => !e.isStatic);

    return DartFormatter().format([
      _implementRecord(element, annotation, fieldsFomatted).accept(emitter),
      _implementFromJsonFunc(className, fields: fieldsFomatted).accept(emitter),
      _implementSchema(className).accept(emitter),
      _implementToJsonFunc(className, fields: fieldsFomatted).accept(emitter),
    ].join('\n\n'));
  }

  Class _implementRecord(ClassElement element, ConstantReader? annotation, Iterable<FieldElement>? fields) {
    fieldRename = annotation?.toRecord().fieldRename ?? FieldRename.none;

    return Class((c) {
      final recordName = element.displayName;

      c
        ..name = '_$recordName'
        ..extend = refer('Record')
        ..constructors.add(
          _generateConstructor(recordName, fields: fields),
        );
    });
  }

  Constructor _generateConstructor(datasetName,
      {Iterable<FieldElement>? fields}) {
    return Constructor((c) {
      var superConstName = 'super';
      StringBuffer headerSchema = StringBuffer();
      headerSchema.write("RecordSchema([");
      fields?.forEach((element) {
        final isPrimitive = element.type.isPrimitive();
        final name = _getFieldFormatted(element.displayName);

        if (isPrimitive || element.type.isIterable()) {
          headerSchema.write("FieldSchema('$name'),");
        } else {
          headerSchema.write("FieldSchema.record('$name', '$name'),");
        }
      });

      headerSchema.write("]),");

      final body = <Code>[];
      fields
          ?.where((element) =>
              !element.type.isPrimitive() && !element.type.isIterable())
          .forEach((element) {
        final name = _getFieldFormatted(element.displayName);
        final type = element.type.getDisplayString(withNullability: false);

        body.add(Code("setByName('$name', _$type());"));
      });

      c.initializers.add(Code("$superConstName(${headerSchema.toString()})"));
      if (body.isNotEmpty) {
        c.body = Block.of(body);
      }
    });
  }

  Spec _implementFromJsonFunc(String className,
      {Iterable<FieldElement>? fields}) {
    final blocks = <Code>[];
    blocks.add(
        declareFinal('ds').assign(refer('_$className').call([])).statement);
    blocks.add(Code('ds.fromMap(json);'));
    final fi = fields?.map((e) {
      final isPrimitive = e.type.isPrimitive();
      final name = _getFieldFormatted(e.displayName);
      if (isPrimitive || e.type.isIterable()) {
        return "${e.displayName}: json['$name']";
      } else {
        final type = e.type.getDisplayString(withNullability: false);
        return "${e.displayName}: $type.fromJson(json['$name'])";
      }
    });

    blocks.add(Code('return $className(${fi?.join(',')},);'));
    return Method(
      (b) => b
        ..name = '_\$${className}FromJson'
        ..requiredParameters.add(Parameter((p) => p
          ..name = 'json'
          ..type = refer('Map<String, dynamic>')))
        ..returns = refer(className)
        ..body = Block.of(blocks),
    );
  }

  Spec _implementToJsonFunc(String className,
      {Iterable<FieldElement>? fields}) {
    final blocks = <Code>[];
    blocks.add(
        declareFinal('ds').assign(refer('_$className').call([])).statement);

    fields?.forEach((element) {
      final name = element.displayName;
      if (element.type.isIterable()) {
        final isPrimitive =
            element.type.coreIterableGenericType().isPrimitive();

        blocks.add(Code(
            "ds.setByName('${_getFieldFormatted(name)}', ${isPrimitive ? 'instance.$name' : "instance.$name?.map((e) => e?.toJson()"});"));
      } else {
        final isPrimitive = element.type.isPrimitive();

        if (isPrimitive) {
          blocks.add(Code(
              "ds.setByName('${_getFieldFormatted(name)}', instance.$name);"));
        } else {
          final type = element.type.getDisplayString(withNullability: false);

          blocks.add(declareFinal(type.camelCase)
              .assign(refer('_$type().fromMap').call(
                  [CodeExpression(Code("instance.$name?.toJson() ?? {}"))]))
              .statement);
          blocks.add(Code(
              "ds.setByName('${_getFieldFormatted(name)}', ${type.camelCase});"));
        }
      }
    });

    blocks.add(Code('return ds.toMap();'));
    return Method(
      (b) => b
        ..name = '_\$${className}ToJson'
        ..requiredParameters.add(Parameter((p) => p
          ..name = 'instance'
          ..type = refer(className)))
        ..returns = refer('Map<String, dynamic>')
        ..body = Block.of(blocks),
    );
  }

  Spec _implementSchema(String className) {
    return Method((b) => b
      ..name = '_\$${className}Schema'
      ..returns = refer('RecordSchema?')
      ..body = Code('return _$className().schema;'));
  }
}
