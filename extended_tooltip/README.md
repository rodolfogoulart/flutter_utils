[![Pub](https://img.shields.io/pub/v/extended_tooltip.svg)](https://pub.dev/packages/extended_tooltip)

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
## Tested on
 * windows
 * web

Need to test on other plataforms
