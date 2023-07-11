import 'dart:async';
// This import allows us to use asynchronous functions.

import 'dart:convert';
// This import allows us to convert data to and from JSON.

import 'dart:developer';
// This import allows us to log messages to the console.

import 'package:flutter/material.dart';
// This import gives us access to the Flutter Material library.

import 'package:shared_preferences/shared_preferences.dart';
// This import gives us access to the SharedPreferences library.

class SetCache {
  // The static instance of the class.
  static final SetCache instance = SetCache();

  // The default lifetime of a cache entry.
  Duration lifeTime = const Duration(days: 7);

  // The prefix for the keys used in SharedPreferences.
  final _key = 'sharedPreferencesCacheKey_';

  // The key for the map that stores all cache keys.
  String _cacheAllKeys = 'cacheKey_all_keys';

  // The map that stores all cache keys.
  Map allKeys = {};

  // A CompletableFuture that completes when the class is initialized.
  Completer initCompleter = Completer();

  // Returns true if the class is initialized.
  bool isInit() {
    // Returns true if the CompletableFuture is completed.
    return initCompleter.isCompleted;
  }

  // Initializes the class.
  Future init({Duration lifeTime = const Duration(days: 7)}) async {
    // Initializes the SharedPreferencesHelper class.
    await _SharedPreferencesHelper.init();

    // Sets the lifetime of the cache entries.
    this.lifeTime = lifeTime;

    // Gets the map of all cache keys from SharedPreferences.
    allKeys = _SharedPreferencesHelper.getMap(_cacheAllKeys) ?? {};

    // Iterates over the map of all cache keys.
    allKeys.forEach((key, value) {
      // Gets the timestamp and lifetime of the cache entry.
      final timestamp = value['timestamp'];
      final lifeTime = value['lifeTime'];

      // If the timestamp and lifetime are not null, then checks if the cache entry has expired.
      if (timestamp != null && lifeTime != null) {
        // Gets the current time in milliseconds since epoch.
        final now = DateTime.now().millisecondsSinceEpoch;

        // Calculates the difference between the current time and the timestamp.
        final diff = now - timestamp;

        // If the difference is greater than the lifetime, then removes the cache entry.
        if (diff > lifeTime) {
          remove(key);
        }
      }
    });

    // If the CompletableFuture is not completed, then completes it.
    if (!initCompleter.isCompleted) {
      initCompleter.complete();
    }
  }

  void save(dynamic data, String key,
      {bool isOverride = false, Duration? lifeTime}) {
    // Checks if the cache entry already exists and if the data is not null.
    if (!isOverride && (allKeys.containsKey(key) || data == null)) {
      // Returns if the conditions are met.
      return;
    }

    // Saves the data to SharedPreferences.
    _SharedPreferencesHelper.save({
      'data': data,
      'lifeTime': (lifeTime ?? this.lifeTime).inMilliseconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, _key + key);

    // Adds the key to the map of all cache keys.
    allKeys[key] = {
      'lifeTime': (lifeTime ?? this.lifeTime).inMilliseconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Saves the map of all cache keys to SharedPreferences.
    _SharedPreferencesHelper.save(allKeys, _cacheAllKeys);

    // Logs the message "SetCache save: $key".
    log("SetCache save: $key");
  }

  dynamic get(String key) {
    // Gets the cache entry from SharedPreferences.
    final data = _SharedPreferencesHelper.getMap(_key + key);
    // Checks if the cache entry is not null.
    if (data != null) {
      // Gets the timestamp and lifetime of the cache entry.
      final timestamp = data['timestamp'];
      final lifeTime = data['lifeTime'];
      // If the timestamp and lifetime are not null, then checks if the cache entry has expired.
      if (timestamp != null && lifeTime != null) {
        // Gets the current time in milliseconds since epoch.
        final now = DateTime.now().millisecondsSinceEpoch;

        // Calculates the difference between the current time and the timestamp.
        final diff = now - timestamp;

        // If the difference is greater than the lifetime, then removes the cache entry and returns null.
        if (diff > lifeTime) {
          // Removes the cache entry.
          remove(key);
          // Returns null.
          return null;
        }
      }
      // Returns the data.
      return data['data'];
    }
    return null;
  }

  void remove(String key) {
    // Removes the key from the map of all cache keys.
    allKeys.remove(key);

    // Removes the cache entry from SharedPreferences.
    _SharedPreferencesHelper.remove(_key + key);
  }

  void clear() {
    // Iterates over the map of all cache keys.
    allKeys.forEach((key, value) {
      // Removes the cache entry from SharedPreferences.
      _SharedPreferencesHelper.remove(_key + key);
    });

    // Removes the map of all cache keys from SharedPreferences.
    _SharedPreferencesHelper.remove(_cacheAllKeys);

    // Resets the map of all cache keys.
    allKeys = {};
  }
}

extension StringCacheExtension on String {
  // This extension adds the ability to cache a String value in SharedPreferences.

  String cache(String key, {bool isOverride = false}) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Saves the String value to SharedPreferences.
      SetCache.instance.save(this, key, isOverride: isOverride);
      // Returns the String value.
      return this;
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }

  // This extension gets the cached String value from SharedPreferences.

  String? getCache(String key) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Gets the String value from SharedPreferences.
      return SetCache.instance.get(key);
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }
}

extension MapCacheExtension on Map {
  // This extension adds the ability to cache a Map value in SharedPreferences.

  Map cache(String key, {bool isOverride = false}) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Saves the Map value to SharedPreferences.
      SetCache.instance.save(this, key, isOverride: isOverride);
      // Returns the Map value.
      return this;
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }

  // This extension gets the cached Map value from SharedPreferences.

  Map? getCache(String key) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Gets the Map value from SharedPreferences.
      return SetCache.instance.get(key);
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }
}

extension IntCacheExtension on int {
  // This extension adds the ability to cache an int value in SharedPreferences.

  int cache(String key, {bool isOverride = false}) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Saves the int value to SharedPreferences.
      SetCache.instance.save(this, key, isOverride: isOverride);
      // Returns the int value.
      return this;
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }

  // This extension gets the cached int value from SharedPreferences.

  int? getCache(String key) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Gets the int value from SharedPreferences.
      return SetCache.instance.get(key);
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }
}

extension DoubleCacheExtension on double {
  // This extension adds the ability to cache a double value in SharedPreferences.

  double cache(String key, {bool isOverride = false}) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Saves the double value to SharedPreferences.
      SetCache.instance.save(this, key, isOverride: isOverride);
      // Returns the double value.
      return this;
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }

  // This extension gets the cached double value from SharedPreferences.

  double? getCache(String key) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Gets the double value from SharedPreferences.
      return SetCache.instance.get(key);
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }
}

extension ListCacheExtension on List {
  // This extension adds the ability to cache a List value in SharedPreferences.

  List cache(String key, {bool isOverride = false}) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Saves the List value to SharedPreferences.
      SetCache.instance.save(this, key, isOverride: isOverride);
      // Returns the List value.
      return this;
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }

  // This extension gets the cached List value from SharedPreferences.

  List? getCache(String key) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Gets the List value from SharedPreferences.
      return SetCache.instance.get(key);
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }
}

extension BoolCacheExtension on bool {
  // This extension adds the ability to cache a bool value in SharedPreferences.

  bool cache(String key, {bool isOverride = false}) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Saves the bool value to SharedPreferences.
      SetCache.instance.save(this, key, isOverride: isOverride);
      // Returns the bool value.
      return this;
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }

  // This extension gets the cached bool value from SharedPreferences.

  bool? getCache(String key) {
    // Checks if the SetCache class is initialized.
    if (SetCache.instance.isInit()) {
      // Gets the bool value from SharedPreferences.
      return SetCache.instance.get(key);
    } else {
      // Throw an exception if the SetCache class is not initialized.
      throw Exception('SetCache is not init');
    }
  }
}

@protected
class _SharedPreferencesHelper {
  // This class is a helper class for the SharedPreferences class.

  static late SharedPreferences _prefs;
  // This is a static variable that stores the SharedPreferences instance.

  static Future init({VoidCallback? callback}) async {
    // This method initializes the SharedPreferences instance.
    _prefs = await SharedPreferences.getInstance();
    callback?.call();
  }

  static List getList(String key) {
    // This method gets a List value from SharedPreferences.
    String? walletPref = _prefs.getString('pref_$key');
    if (walletPref != null) {
      // If the value exists, decode it from JSON.
      return jsonDecode(walletPref);
    }
    // Otherwise, return an empty List.
    return [];
  }

  static Map? getMap(String? key) {
    // This method gets a Map value from SharedPreferences.
    String? walletPref = _prefs.getString('pref_$key');
    if (walletPref != null) {
      // If the value exists, decode it from JSON.
      return jsonDecode(walletPref);
    }
    // Otherwise, return null.
    return null;
  }

  static String? getString(String key) {
    // This method gets a String value from SharedPreferences.
    return _prefs.getString('pref_$key');
  }

  static int? getInt(String key) {
    // This method gets an int value from SharedPreferences.
    return _prefs.getInt('pref_$key');
  }

  static bool? getBool(String key) {
    // This method gets a bool value from SharedPreferences.
    return _prefs.getBool('pref_$key');
  }

  static double? getDouble(String key) {
    // This method gets a double value from SharedPreferences.
    return _prefs.getDouble('pref_$key');
  }

  static Future<bool> save(dynamic data, String key) async {
    // This method saves a value to SharedPreferences.
    if (data is List || data is Map) {
      // If the data is a List or Map, encode it to JSON before saving.
      return await _prefs.setString('pref_$key', jsonEncode(data));
    }
    if (data is String) {
      // If the data is a String, save it as-is.
      return await _prefs.setString('pref_$key', data);
    }
    if (data is bool) {
      // If the data is a bool, save it as-is.
      return await _prefs.setBool('pref_$key', data);
    }
    if (data is double) {
      // If the data is a double, save it as-is.
      return await _prefs.setDouble('pref_$key', data);
    }
    if (data is int) {
      // If the data is an int, save it as-is.
      return await _prefs.setInt('pref_$key', data);
    }
    // If the data is not a supported type, return false.
    return false;
  }

  static remove(String key) {
    // This method removes a value from SharedPreferences.
    _prefs.remove('pref_$key');
  }
}
