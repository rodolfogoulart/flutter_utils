import 'package:flutter/widgets.dart';

extension OffsetExtension on Offset {
  Offset copyWith({double? dx, double? dy}) => Offset(dx ?? this.dx, dy ?? this.dy);
}
