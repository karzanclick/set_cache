import 'package:set_cache/set_cache.dart';

void main() {
  SetCache.instance.init(lifeTime: const Duration(days: 7));
}

