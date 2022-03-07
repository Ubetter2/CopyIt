import 'package:firedart/firedart.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores tokens using a Hive store.
/// Depends on the Hive plugin: https://pub.dev/packages/hive
class HiveStore extends TokenStore {
  static const keyToken = "auth_token";

  static Future<HiveStore> create() async {
    // Make sure you call both:
    // Hive.init(storePath);
    // Hive.registerAdapter(TokenAdapter(), adapterId);

    var box = await Hive.openBox("auth_store",
        compactionStrategy: (entries, deletedEntries) => deletedEntries > 50);
    return HiveStore._internal(box);
  }

  final Box _box;

  HiveStore._internal(this._box);

  @override
  Token? read() => _box.get(keyToken);

  @override
  void write(Token? token) => _box.put(keyToken, token);

  @override
  void delete() => _box.delete(keyToken);
}

class TokenAdapter extends TypeAdapter<Token> {
  @override
  final typeId = 42;

  @override
  void write(BinaryWriter writer, Token token) =>
      writer.writeMap(token.toMap());

  @override
  Token read(BinaryReader reader) =>
      Token.fromMap(reader.readMap().map<String, dynamic>(
          (key, value) => MapEntry<String, dynamic>(key, value)));
}

/// Stores tokens as preferences in Android and iOS.
/// Depends on the shared_preferences plugin: https://pub.dev/packages/shared_preferences
class PreferencesStore extends TokenStore {
  static const keyToken = "auth_token";

  static Future<PreferencesStore> create() async =>
      PreferencesStore._internal(await SharedPreferences.getInstance());

  SharedPreferences _prefs;

  PreferencesStore._internal(this._prefs);

  @override
  Token? read() => _prefs.containsKey(keyToken)
      ? Token.fromMap(json.decode(_prefs.get(keyToken) as String))
      : null;

  @override
  void write(Token? token) => token != null
      ? _prefs.setString(keyToken, json.encode(token.toMap()))
      : null;

  @override
  void delete() => _prefs.remove(keyToken);
}
