import 'package:rng/src/rng.dart';

main() {
  final rng = RNG(0);
  final list = rng.intList(-20, 60, 0, 255);
  print('rng list: $list');
}
