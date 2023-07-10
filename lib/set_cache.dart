import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetCache {
  static final SetCache instance = SetCache();
  double maxAge = 7; // 7 days
  final key = 'sharedPreferencesCacheKey_';
  final cacheAllKeys = 'cacheKey_all_keys';
  Map allKeys = {};
  bool isInit = false;

  /// maxAge: days
  Future init({double maxAge = 7}) async {
    await _SharedPreferencesHelper.init();
    isInit = true;
    this.maxAge = maxAge * 24 * 60 * 60 * 1000;
    allKeys = _SharedPreferencesHelper.getMap(cacheAllKeys) ?? {};

    try {
      allKeys.forEach((key, value) {
        final timestamp = value['timestamp'];
        final maxAge = value['maxAge'];
        if (timestamp != null && maxAge != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final diff = now - timestamp;
          if (diff > maxAge) {
            remove(key);
          }
        }
      });
    } catch (e) {
      // print(e);
      log(e.toString());
    }
  }

  void save(dynamic data, String key) {
    if (allKeys.containsKey(key) || data == null) {
      return;
    }
    _SharedPreferencesHelper.save({
      'data': data,
      'maxAge': maxAge,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, this.key + key);

    allKeys[key] = {
      'maxAge': maxAge,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _SharedPreferencesHelper.save(allKeys, cacheAllKeys);
  }

  dynamic get(String key) {
    //remove(key);
    final data = _SharedPreferencesHelper.getMap(this.key + key);
    // print('data: $data');
    if (data != null) {
      final timestamp = data['timestamp'];
      final maxAge = data['maxAge'];
      if (timestamp != null && maxAge != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final diff = now - timestamp;
        // print('diff: $diff, maxAge: $maxAge');
        if (diff > maxAge) {
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
    _SharedPreferencesHelper.remove(this.key + key);
  }

  void clear() {
    allKeys.forEach((key, value) {
      _SharedPreferencesHelper.remove(this.key + key);
    });
    _SharedPreferencesHelper.remove(cacheAllKeys);
    allKeys = {};
  }
}

extension StringCacheExtension on String {
  void cache(String key) {
    if (SetCache.instance.isInit) {
      SetCache.instance.save(this, key);
    }
    throw Exception('SetCache is not init');
  }

  String getCache(String key) {
    if (SetCache.instance.isInit) {
      return SetCache.instance.get(key) ?? '';
    }
    throw Exception('SetCache is not init');
  }
}

extension MapCacheExtension on Map {
  void cache(String key) {
    if (SetCache.instance.isInit) {
      SetCache.instance.save(this, key);
    }
    throw Exception('SetCache is not init');
  }

  Map getCache(String key) {
    if (SetCache.instance.isInit) {
      return SetCache.instance.get(key) ?? {};
    }
    throw Exception('SetCache is not init');
  }
}

extension IntCacheExtension on int {
  void cache(String key) {
    if (SetCache.instance.isInit) {
      SetCache.instance.save(this, key);
    }
    throw Exception('SetCache is not init');
  }

  int getCache(String key) {
    if (SetCache.instance.isInit) {
      return SetCache.instance.get(key) ?? 0;
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
