import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'annotation_helper.dart';
import 'package:dart_style/dart_style.dart';
import 'package:nimbus_annotation/nimbus_annotation.dart'
    show DatasetSerializable;
import 'package:nimbus_generator/src/dart_type_helper.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

class DatasetSupporterGenerator
    extends GeneratorForAnnotation<DatasetSerializable> {
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
      _implementDataset(element, annotation).accept(emitter),
      _implementFromJsonFunc(className, fields: fieldsFomatted).accept(emitter),
      _implementToJsonFunc(className, fields: fieldsFomatted).accept(emitter),
    ].join('\n\n'));
  }

  Class _implementDataset(ClassElement element, ConstantReader? annotation) {
    return Class((c) {
      final datasetName = annotation?.toDataSet().name;

      c
        ..name = '_DataSet'
        ..extend = refer('DataSet')
        ..constructors.add(
          _generateConstructor(datasetName, fields: element.fields),
        );
    });
  }

  Constructor _generateConstructor(datasetName,
      {Iterable<FieldElement>? fields}) {
    final headers = fields?.where((e) =>
        e.metadata.any((meta) => meta.element?.displayName == 'DatasetHeader'));

    final recordLists = fields?.where((e) => e.metadata
        .any((meta) => meta.element?.displayName == 'DatasetRecordList'));

    final inheritedFields =
        fields?.where((e) => e.getter?.hasOverride ?? false);

    return Constructor((c) {
      var superConstName = 'super';
      c.initializers.add(Code("$superConstName('$datasetName')"));

      final blocks = <Code>[];
      headers?.forEach((element) {
        final type = element.type.getDisplayString(withNullability: false);
        final name = element.displayName.pascalCase;
        blocks.add(Code("setHeaderSchema(_$type().schema!, '$name');"));
      });

      recordLists?.forEach((element) {
        final type = element.type.coreIterableGenericType();
        final name = element.displayName.pascalCase;
        if (type.isLikeDynamic) {
          blocks.add(
              Code("setRecordListSchema(RecordSchema(const []), '$name');"));
        } else {
          blocks.add(Code(
              "setRecordListSchema(_${type.getDisplayString(withNullability: false)}().schema!, '$name');"));
        }
      });

      inheritedFields?.forEach((element) {
        final type = element.getter?.returnType
            .coreIterableGenericType()
            .getDisplayString(withNullability: false);
        final name = element.getter?.displayName.pascalCase;
        blocks.add(Code("setRecordListSchema($type.schema!, '$name');"));
      });

      c.body = Block.of(blocks);
    });
  }

  Spec _implementFromJsonFunc(String className,
      {Iterable<FieldElement>? fields}) {
    final blocks = <Code>[];
    blocks.add(declareFinal('ds').assign(refer('_DataSet').call([])).statement);
    blocks.add(Code('ds.fromList(json);'));

    final fromJsonField =
        fields?.where((e) => !(e.getter?.hasOverride ?? false)).map((e) {
      final type = e.type.getDisplayString(withNullability: false);
      final name = e.displayName.pascalCase;
      if (e.type.isIterable()) {
        if (e.type.coreIterableGenericType().isLikeDynamic) {
          return "${e.displayName}: ds.getRecordList('$name')?.toMap().map((e) => e).toList()";
        } else {
          return "${e.displayName}: ds.getRecordList('$name')?.toMap().map((e) => ${name}Record.fromJson(e)).toList()";
        }
      } else {
        return "${e.displayName}: $type.fromJson(ds.getHeader('$name')?.toMap() ?? {},)";
      }
    });
    blocks.add(Code('return $className(${fromJsonField?.join(',')},);'));
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
    blocks.add(declareFinal('ds').assign(refer('_DataSet').call([])).statement);

    fields?.forEach((element) {
      final isHeader = element.metadata
          .any((e) => e.element?.displayName == 'DatasetHeader');
      final isRecordList = element.metadata
          .any((e) => e.element?.displayName == 'DatasetRecordList');

      final name = element.displayName.pascalCase;
      final fieldRecordName = '${element.displayName}Record';
      final isInheritedField = element.getter?.hasOverride ?? false;
      if (isHeader) {
        final type = element.type.getDisplayString(withNullability: false);

        blocks.add(declareFinal(fieldRecordName)
            .assign(refer('_$type').call([]))
            .statement);
        blocks.add(Code(
            "$fieldRecordName.fromMap(instance.${element.displayName}?.toJson());"));
        blocks.add(Code("ds.setHeader($fieldRecordName, '$name');"));
      } else if (isRecordList) {
        final type = element.type.coreIterableGenericType();

        if (!type.isLikeDynamic) {
          blocks.add(declareFinal(fieldRecordName)
              .assign(refer(
                  'RecordList(_${type.getDisplayString(withNullability: false)}().schema!)'))
              .statement);
          blocks.add(Code(
              "$fieldRecordName.fromMap(instance.headerQuery?.map((e) => e.toJson()).toList());"));
          blocks.add(Code(" ds.setRecordList($fieldRecordName, '$name');"));
        }
      } else if (isInheritedField) {
              final type = element.type.coreIterableGenericType().getDisplayString(withNullability: false);
      final name = element.displayName;
        blocks.add(Code('ds.setRecordList('));
        blocks.add(Code(
            'RecordList($type.schema!).fromMap(instance.$name?.map((e) => e.toJson()).toList()),'));
        blocks.add(Code("'${name.pascalCase}',"));

        blocks.add(Code(');'));
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
}
