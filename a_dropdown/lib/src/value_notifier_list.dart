import 'package:flutter/widgets.dart';

class ValueNotifierList<T> extends ValueNotifier<List<T>> {
  ValueNotifierList() : super([]);
  void add(T value) {
    this.value.add(value);
    notifyListeners();
  }

  void addAll(List<T> value) {
    this.value.addAll(value);
    notifyListeners();
  }

  void remove(T value) {
    this.value.remove(value);
    notifyListeners();
  }

  void removeAt(int index) {
    value.removeAt(index);
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }

  void sort(int Function(T a, T b) compare) {
    value.sort(compare);
    notifyListeners();
  }
}
