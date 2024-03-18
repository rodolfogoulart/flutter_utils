import 'package:flutter_test/flutter_test.dart';
import 'package:some_extensions/some_extensions.dart';

void main() {
  test('isBetween', () {
    expect(10.isBetween(0, 10), true);
    expect(11.isBetween(0, 10), false);
    expect(11.isBetweenExclusive(0, 10), false);
    expect(1.isBetweenExclusive(0, 10), true);
    expect('test'.capitalize, 'Test');
    expect([].isEmptyOrNull, true);
    List? list;
    expect(list.isEmptyOrNull, true);
    expect(list.isNotEmptyOrNull, false);
    list = [];
    expect(list.isNotEmptyOrNull, false);
    list = ['a'];
    expect(list.isNotEmptyOrNull, true);
  });
}
