/// Support for doing something awesome.
///
/// More dartdocs go here.

library;

export 'dart:convert' show json, base64;
export 'package:flutter_secure_dotenv/src/encrypter.dart';
export 'dart:typed_data' show Uint8List;

part 'src/field_key.dart';
part 'src/rename.dart';

/// A generator for handling environment variables.
class DotEnvGen {
  /// Creates a generator for environment variables.
  ///
  /// [filename] is the .env file name.
  /// [fieldRename] sets how fields are renamed.
  const DotEnvGen({
    this.filename = '.env',
    this.fieldRename = FieldRename.screamingSnake,
  });

  /// The name of the .env file.
  final String filename;

  /// The renaming strategy for fields.
  final FieldRename fieldRename;
}
