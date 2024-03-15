<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This package extends Tooltip option, giving the option to pass a Widget as tooltip.

This package uses Overlay to build the tooltip.

Dart Tooltip normally only accepts String or TextSpan, with this package you can extend this functionality by passing a Widget.

The tooltip position is calculated by checking the widget size and position relative to the screen.


## Usage

go to `/example` folder to more examples

```dart
ExtendedToolTip(
  overlayHorizontalPosition: OverlayHorizontalPosition.right,
  message: Container(
      width: 200,
      height: 200,
      color: Colors.red,
      child: const Center(child: Text('My custom Message')),  
  ),
  child: Text(
    'ExtendToolTip Example',
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)
```

```dart
ExtendedToolTip(
  overlayHorizontalPosition: OverlayHorizontalPosition.right,
  message: Container(
      width: 200,
      height: 200,
      color: Colors.red,
      child: const Center(child: Text('My custom Message')),  
  ),
  child: Text(
    'ExtendToolTip Example',
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)
```
