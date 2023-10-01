import 'package:build/build.dart';
import 'package:nimbus_generator/src/dataset_generator.dart';
import 'package:nimbus_generator/src/record_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:nimbus_generator/src/nimbus_generator.dart';

Builder nimbusGenerator(BuilderOptions options) => SharedPartBuilder(
      [
        NimbusSupporterGenerator(),
        RecordSupporterGenerator(),
        DatasetSupporterGenerator(),
      ],
      'nimbus_generator',
    );
