import 'package:flutter/material.dart';

extension RangeNum on num {
  bool isBetween(num a, num b) {
    //not  ( both greater || both lesser )
    return !((a > this && b > this) || (a < this && b < this));
  }

  bool isBetweenExclusive(num a, num b) {
    return !((a >= this && b >= this) || (a <= this && b <= this));
  }
}

extension StringExtension on String? {
  /// Capitalize the first letter in a string.
  String get capitalize {
    return (this!.length > 1) ? this![0].toUpperCase() + this!.substring(1) : this!.toUpperCase();
  }

  /// returns true if the list is null
  get isNull => this == null;

  /// returns true if the list is null or empty
  bool get isEmptyOrNull => (isNull || (this != null && this?.isEmpty == true)) ? true : false;

  /// returns true if the list is not null and not empty
  bool get isNotEmptyOrNull => !isEmptyOrNull;

  /// Returns a list of words from a string
  /// split the string by space and punctuation
  ///
  /// "hello world" => ["hello", "world"]
  ///
  ///usage: Google NLP does separate the text in tokens based on space and punctuation
  List<String> get tokenizer {
    String text = this ?? '';
    List<String> tokens = [];
    String word = '';
    for (var i = 0; i < text.length; i++) {
      if (text[i] == ' ') {
        if (word.isNotEmpty) tokens.add(word);
        word = '';
        continue;
      } else {
        //regex for puntuation " "
        if (RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ0-9]').hasMatch(text[i])) {
          if (word.isNotEmpty) {
            tokens.add(word);
            word = '';
          }
          if (text[i].isNotEmpty) tokens.add(text[i]);
          word = '';
          continue;
        } else {
          word += text[i];
          //when the text ends without puntuation
          if (i + 1 == text.length) {
            tokens.add(word);
            word = '';
          }
        }
      }
    }
    return tokens;
  }

  ///return just the printable characters from ASCII and replace the others with changeFor
  ///
  ///[to see ASCII table](https://www.ascii-code.com/)
  String printableCharacters([String changeFor = ' ']) {
    List<String> text = (this ?? '').characters.toList();
    for (int i = 0; i < text.length; i++) {
      var char = text[i].codeUnits[0];
      if (char > 255 && char < 32) {
        text[i] = changeFor;
      }
    }
    return text.join();
  }
}

extension ListExtension<T> on List<T?>? {
  /// returns the last element of the list or Null if the list is null or empty
  T? get lastOrNull => !this.isNull && this!.isNotEmptyOrNull ? this!.last : null;

  /// returns true if the list is null
  get isNull => this == null;

  /// returns true if the list is null or empty
  bool get isEmptyOrNull => (this.isNull || (this != null && this?.isEmpty == true)) ? true : false;

  /// returns true if the list is not null and not empty
  bool get isNotEmptyOrNull => !this.isEmptyOrNull;
}

extension BuildContextExtension on BuildContext {
  /// Returns the height and width of the screen
  double get height => MediaQuery.of(this).size.height;

  /// Returns the height and width of the screen
  double get width => MediaQuery.of(this).size.width;

  /// Returns the height and width of the screen
  Size get size => MediaQuery.of(this).size;

  /// Returns the default text style
  get defaultTextStyle => DefaultTextStyle.of(this);

  /// Returns the media query
  get mediaQuery => MediaQuery.of(this);
  get theme => Theme.of(this);
}

/// copy from flutter_animate
extension OffsetCopyWithExtensions on Offset {
  /// Returns a copy of the offset with the given values for [dx] and [dy].
  Offset copyWith({double? dx, double? dy}) => Offset(dx ?? this.dx, dy ?? this.dy);
}
