import 'package:extended_tooltip/src/utils/extensions.dart';
import 'package:extended_tooltip/src/utils/fade_container.dart';
import 'package:extended_tooltip/src/utils/widget_size.dart';
import 'package:flutter/material.dart';

/// Position of the tooltip in relation to the child on horizontal axis
enum ExtendedTooltipPosition { right, left, center }

/// [ExtendedToolTip]
///
/// Extends the functionality of [Tooltip]
///
/// This widget uses [CompositedTransformTarget] to position the [Tooltip] widget, and the tooltip is build using overlay
///
/// The position of the tooltip is based on the [horizontalPosition], but is overridden if the [Tooltip] widget is off the screen
class ExtendedToolTip extends StatefulWidget {
  final Widget child;

  ///your custom tooltip widget message
  final Widget message;

  ///default [ExtendedTooltipVerticalHorizontalPosition.right]
  ///
  ///horizontal position of the tooltip in relation to the child
  final ExtendedTooltipPosition? horizontalPosition;

  ///default 200 milliseconds
  final Duration animation;

  ///keep the tooltip on screen to interact if mouse is hovering the message
  ///
  ///default [true]
  final bool keepTooltipWhenMouseHover;

  ///default [BoxDecoration] Theme.of(context).tooltipTheme.decoration,
  final BoxDecoration? decoration;

  const ExtendedToolTip({
    super.key,
    required this.child,
    required this.message,
    this.horizontalPosition = ExtendedTooltipPosition.right,
    this.animation = const Duration(milliseconds: 200),
    this.keepTooltipWhenMouseHover = true,
    this.decoration,
  });

  @override
  State<ExtendedToolTip> createState() => _ExtendedToolTipState();
}

class _ExtendedToolTipState extends State<ExtendedToolTip> {
  final layerLink = LayerLink();
  bool isMouseOverMessage = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (details) {
        showOverlay(context);
        isMouseOverMessage = true;
      },
      onExit: (details) async {
        isMouseOverMessage = false;
        await Future.delayed(const Duration(milliseconds: 100)).then((value) {
          if (isMouseOverMessage) return;
          if (!isMouseOverMessage) hideOverlay();
        });
      },
      child: CompositedTransformTarget(link: layerLink, child: widget.child),
    );
  }

  OverlayEntry? entry;
  showOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offSetChild = renderBox.localToGlobal(Offset.zero);
    if (entry != null) {
      return;
    }
    //[right] position, the overlay will be show on the right of the widget
    var offSetPosition = Offset(size.width, size.height);

    var sizeScreen = MediaQuery.of(context).size;

    Widget overlayWidget = buildOverlay();

    ValueNotifier<Size> overlaySize = ValueNotifier<Size>(Size.zero);

    ThemeData theme = Theme.of(context);

    entry = OverlayEntry(
      builder: (context) => Positioned(
        right: offSetChild.dx,
        // top: offSetChild.dy,
        child: ValueListenableBuilder(
          valueListenable: overlaySize,
          builder: (context, value, child) {
            //set the position
            if (widget.horizontalPosition == ExtendedTooltipPosition.left) {
              offSetPosition = offSetPosition.copyWith(dx: -(value.width));
            } else if (widget.horizontalPosition == ExtendedTooltipPosition.center) {
              offSetPosition = offSetPosition.copyWith(dx: (value.width) / -2);
            }
            //
            //check if the overlay is out of the screen on y axis
            if (offSetChild.dy + value.height > sizeScreen.height) {
              offSetPosition = offSetPosition.copyWith(dy: -(value.height));
            }
            // check if the overlay is out of the screen on x axis
            if (offSetChild.dx + value.width + 15 > sizeScreen.width) {
              offSetPosition = offSetPosition.copyWith(dx: -(value.width));
            }
            return CompositedTransformFollower(
              link: layerLink,
              offset: offSetPosition,
              child: child,
            );
          },
          //the animate fade is used to do the trick of the overlay to not see the
          //change of position when the widget is off screen, widget.message size is calculated in the builder
          child: FadeContainer(
            duration: widget.animation,
            child: Container(
              decoration: widget.decoration ?? theme.tooltipTheme.decoration,
              child: Material(
                textStyle: theme.tooltipTheme.textStyle,
                child: WidgetSize(
                    onChange: (value) {
                      overlaySize.value = value;
                    },
                    child: overlayWidget),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry!);
  }

  hideOverlay() {
    entry?.remove();
    entry = null;
  }

  Widget buildOverlay() {
    // if the user don't want to keep the tooltip and interact with the widget, return the widget.message
    if (widget.keepTooltipWhenMouseHover == false) return widget.message;
    //use the MouseRegion to check if the mouse pointer is over the tooltip
    return MouseRegion(
      child: widget.message,
      onEnter: (details) {
        isMouseOverMessage = true;
      },
      onExit: (details) async {
        isMouseOverMessage = false;
        await Future.delayed(const Duration(milliseconds: 100)).then((value) {
          if (isMouseOverMessage) return;
          if (!isMouseOverMessage) hideOverlay();
        });
      },
    );
  }
}
