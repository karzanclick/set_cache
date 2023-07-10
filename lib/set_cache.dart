import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetCache {
  static final SetCache instance = SetCache();
  Duration lifeTime = const Duration(days: 7);
  final _key = 'sharedPreferencesCacheKey_';
  String _cacheAllKeys = 'cacheKey_all_keys';
  Map allKeys = {};

  Completer initCompleter = Completer();

  bool isInit() {
    return initCompleter.isCompleted;
  }

  Future init({Duration lifeTime = const Duration(days: 7)}) async {
    await _SharedPreferencesHelper.init();
    this.lifeTime = lifeTime;
    allKeys = _SharedPreferencesHelper.getMap(_cacheAllKeys) ?? {};
    try {
      allKeys.forEach((key, value) {
        final timestamp = value['timestamp'];
        final lifeTime = value['lifeTime'];
        if (timestamp != null && lifeTime != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final diff = now - timestamp;
          if (diff > lifeTime) {
            remove(key);
          }
        }
      });
    } catch (e) {
      log(e.toString());
    }
    if (!initCompleter.isCompleted) {
      initCompleter.complete();
    }
  }

  void save(dynamic data, String key, {bool isOverride = false}) {
    if (!isOverride && (allKeys.containsKey(key) || data == null)) {
      return;
    }
    _SharedPreferencesHelper.save({
      'data': data,
      'lifeTime': lifeTime.inMilliseconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, _key + key);

    allKeys[key] = {
      'lifeTime': lifeTime.inMilliseconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _SharedPreferencesHelper.save(allKeys, _cacheAllKeys);
    log("SetCache save: $key");
  }

  dynamic get(String key) {
    final data = _SharedPreferencesHelper.getMap(_key + key);
    if (data != null) {
      final timestamp = data['timestamp'];
      final lifeTime = data['lifeTime'];
      if (timestamp != null && lifeTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final diff = now - timestamp;
        if (diff > lifeTime) {
          remove(key);
          return null;
        }
      }
      return data['data'];
    }
    return null;
  }

  remove(String key) {
    allKeys.remove(key);
    _SharedPreferencesHelper.remove(_key + key);
  }

  void clear() {
    allKeys.forEach((key, value) {
      _SharedPreferencesHelper.remove(_key + key);
    });
    _SharedPreferencesHelper.remove(_cacheAllKeys);
    allKeys = {};
  }
}

extension StringCacheExtension on String {
  String cache(String key, {bool isOverride = false}) {
    if (SetCache.instance.isInit()) {
      SetCache.instance.save(this, key, isOverride: isOverride);
      return this;
    }
    throw Exception('SetCache is not init');
  }

  String? getCache(String key) {
    if (SetCache.instance.isInit()) {
      return SetCache.instance.get(key);
    }
    throw Exception('SetCache is not init');
  }
}

extension MapCacheExtension on Map {
  Map cache(String key, {bool isOverride = false}) {
    if (SetCache.instance.isInit()) {
      SetCache.instance.save(this, key, isOverride: isOverride);
      return this;
    }
    throw Exception('SetCache is not init');
  }

  Map? getCache(String key) {
    if (SetCache.instance.isInit()) {
      return SetCache.instance.get(key);
    }
    throw Exception('SetCache is not init');
  }
}

extension IntCacheExtension on int {
  int cache(String key, {bool isOverride = false}) {
    if (SetCache.instance.isInit()) {
      SetCache.instance.save(this, key, isOverride: isOverride);
      return this;
    }
    throw Exception('SetCache is not init');
  }

  int? getCache(String key) {
    if (SetCache.instance.isInit()) {
      return SetCache.instance.get(key);
    }
    throw Exception('SetCache is not init');
  }
}

extension DoubleCacheExtension on double {
  double cache(String key, {bool isOverride = false}) {
    if (SetCache.instance.isInit()) {
      SetCache.instance.save(this, key, isOverride: isOverride);
      return this;
    }
    throw Exception('SetCache is not init');
  }

  double? getCache(String key) {
    if (SetCache.instance.isInit()) {
      return SetCache.instance.get(key);
    }
    throw Exception('SetCache is not init');
  }
}

extension ListCacheExtension on List {
  List cache(String key, {bool isOverride = false}) {
    if (SetCache.instance.isInit()) {
      SetCache.instance.save(this, key, isOverride: isOverride);
      return this;
    }
    throw Exception('SetCache is not init');
  }

  List? getCache(String key) {
    if (SetCache.instance.isInit()) {
      return SetCache.instance.get(key);
    }
    throw Exception('SetCache is not init');
  }
}

extension BoolCacheExtension on bool {
  bool cache(String key, {bool isOverride = false}) {
    if (SetCache.instance.isInit()) {
      SetCache.instance.save(this, key, isOverride: isOverride);
      return this;
    }
    throw Exception('SetCache is not init');
  }

  bool? getCache(String key) {
    if (SetCache.instance.isInit()) {
      return SetCache.instance.get(key);
    }
    throw Exception('SetCache is not init');
  }
}

@protected
class _SharedPreferencesHelper {
  static late SharedPreferences _prefs;
  static Future init({VoidCallback? callback}) async {
    _prefs = await SharedPreferences.getInstance();
    callback?.call();
  }

  static List getList(String key) {
    String? walletPref = _prefs.getString('pref_$key');
    if (walletPref != null) {
      return jsonDecode(walletPref);
    }
    return [];
  }

  static Map? getMap(String? key) {
    String? walletPref = _prefs.getString('pref_$key');
    if (walletPref != null) {
      return jsonDecode(walletPref);
    }
    return null;
  }

  static String? getString(String key) {
    return _prefs.getString('pref_$key');
  }

  static int? getInt(String key) {
    return _prefs.getInt('pref_$key');
  }

  static bool? getBool(String key) {
    return _prefs.getBool('pref_$key');
  }

  static double? getDouble(String key) {
    return _prefs.getDouble('pref_$key');
  }

  static Future<bool> save(dynamic data, String key) async {
    if (data is List || data is Map) {
      return await _prefs.setString('pref_$key', jsonEncode(data));
    }
    if (data is String) {
      return await _prefs.setString('pref_$key', data);
    }
    if (data is bool) {
      return await _prefs.setBool('pref_$key', data);
    }
    if (data is double) {
      return await _prefs.setDouble('pref_$key', data);
    }
    if (data is int) {
      return await _prefs.setInt('pref_$key', data);
    }
    return false;
  }

  static remove(String key) {
    _prefs.remove('pref_$key');
  }
}
