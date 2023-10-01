import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart' show TypeChecker;
import 'package:source_helper/source_helper.dart';

extension DartTypeExtensions on DartType {
  bool isPrimitive() {
    return this.isDartCoreObject ||
        this is DynamicType ||
        simpleJsonTypeChecker.isAssignableFromType(this);
  }

  bool isIterable() {
    return TypeChecker.any([coreIterableTypeChecker])
        .isAssignableFromType(this);
  }

  /// Returns the generic type of the [Iterable] represented by [type].
  ///
  /// If [type] does not extend [Iterable], an error is thrown.
  DartType coreIterableGenericType() =>
      this.typeArgumentsOf(coreIterableTypeChecker)!.single;
}

/// A [TypeChecker] for [Iterable].
const coreIterableTypeChecker = TypeChecker.fromUrl('dart:core#Iterable');

/// A [TypeChecker] for [String], [bool] and [num].
const simpleJsonTypeChecker = TypeChecker.any([
  TypeChecker.fromUrl('dart:core#String'),
  TypeChecker.fromUrl('dart:core#bool'),
  TypeChecker.fromUrl('dart:core#num')
]);
