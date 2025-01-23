part of '../flutter_secure_dotenv.dart';

/// Represents a key in the environment variables.
class FieldKey {
  /// Creates a [FieldKey] with the given [name] and [defaultValue].
  const FieldKey({
    this.name,
    this.defaultValue,
  });

  /// The name of the field key.
  final String? name;

  /// The default value of the field key.
  final Object? defaultValue;
}
