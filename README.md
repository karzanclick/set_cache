# SetCache

SetCache is a versatile data caching package for Dart and Flutter, allowing you to efficiently cache maps, integers, and strings. It provides two convenient ways of caching data: through extension methods and using the SetCache singleton instance.

## Features

- Effortlessly cache maps, integers, and strings
- Extension methods for easy caching: `"Test".cache('key')`
- Singleton instance for direct caching: `SetCache.instance.save('key', 'value')`
- Simple and intuitive API
- Supports time-based expiration for cache entries
- Efficient storage and retrieval of cached data
- Lightweight and optimized for performance

## Installation

To start using SetCache in your Dart or Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  set_cache: ^1.0.0
```

After adding the dependency, run `flutter pub get` to fetch the package.

## Usage

### Using Extension Methods

```dart
import 'package:set_cache/set_cache.dart';

void main() {
  final data = "Test".cache('key');
  
  // Retrieve data from cache
  print(data); // Output: Test
  
  // Store data in cache with expiration
  "New Value".cache('key', expiration: Duration(minutes: 30));
}
```

### Using SetCache Instance

```dart
import 'package:set_cache/set_cache.dart';

void main() {
  // Save data using the SetCache instance
  SetCache.instance.save('key', 'value');
  
  // Retrieve data from cache
  final data = SetCache.instance.get('key');
  print(data); // Output: value
  
  // Remove data from cache
  SetCache.instance.remove('key');
}
```

That's it! You're now ready to leverage SetCache for efficient caching of maps, integers, and strings in your Dart and Flutter applications.