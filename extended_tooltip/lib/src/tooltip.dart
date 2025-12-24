import 'package:extended_tooltip/src/utils/fade_container.dart';
import 'package:extended_tooltip/src/utils/widget_size.dart';
import 'package:flutter/material.dart';

/// Position of the tooltip in relation to the child on horizontal axis
enum ExtendedTooltipPosition { right, left, center }

/// [ExtendedToolTip]
///
/// Extends the functionality of [Tooltip]
class ExtendedToolTip extends StatefulWidget {
  final Widget child;
  final Widget message;
  final ExtendedTooltipPosition? horizontalPosition;
  final Duration animation;
  final bool keepTooltipWhenMouseHover;
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final bool useGestureDetector;

  const ExtendedToolTip(
      {super.key,
      required this.child,
      required this.message,
      this.horizontalPosition = ExtendedTooltipPosition.right,
      this.animation = const Duration(milliseconds: 200),
      this.keepTooltipWhenMouseHover = true,
      this.decoration,
      this.textStyle,
      this.useGestureDetector = false});

  @override
  State<ExtendedToolTip> createState() => _ExtendedToolTipState();
}

class _ExtendedToolTipState extends State<ExtendedToolTip>
    with WidgetsBindingObserver {
  bool isMouseOverMessage = false;
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    hideOverlay();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Hide overlay quando app vai para background
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      hideOverlay();
      isMouseOverMessage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useGestureDetector) {
      return GestureDetector(
        onTap: () async {
          if (!mounted) return;

          if (isMouseOverMessage) {
            isMouseOverMessage = false;
            await Future.delayed(const Duration(milliseconds: 100))
                .then((value) {
              if (!mounted) return;
              if (isMouseOverMessage) return;
              hideOverlay();
            });
          } else {
            showOverlay(context);
            isMouseOverMessage = true;
          }
        },
        child: TapRegion(
            onTapOutside: (event) async {
              if (!mounted) return;
              isMouseOverMessage = false;
              await Future.delayed(const Duration(milliseconds: 100))
                  .then((value) {
                if (!mounted) return;
                if (isMouseOverMessage) return;
                hideOverlay();
              });
            },
            child: widget.child),
      );
    } else {
      return MouseRegion(
        onEnter: (details) {
          if (!mounted) return;
          showOverlay(context);
          isMouseOverMessage = true;
        },
        onExit: (details) async {
          if (!mounted) return;
          isMouseOverMessage = false;
          await Future.delayed(const Duration(milliseconds: 100)).then((value) {
            if (!mounted) return;
            if (isMouseOverMessage) return;
            hideOverlay();
          });
        },
        child: widget.child,
      );
    }
  }

  showOverlay(BuildContext context) {
    if (!mounted) return;
    if (entry != null) return;

    // Verificar se o context ainda é válido
    if (!context.mounted) return;

    try {
      final overlay = Overlay.of(context);
      final renderBox = context.findRenderObject() as RenderBox?;

      // Verificar se renderBox existe e está attached
      if (renderBox == null || !renderBox.attached) return;

      final size = renderBox.size;
      final offSetChild = renderBox.localToGlobal(Offset.zero);

      var sizeScreen = MediaQuery.of(context).size;

      Widget overlayWidget = buildOverlay();
      ValueNotifier<Size> overlaySize = ValueNotifier<Size>(Size.zero);
      ThemeData theme = Theme.of(context);

      entry = OverlayEntry(
        builder: (context) => ValueListenableBuilder(
          valueListenable: overlaySize,
          builder: (context, value, child) {
            // Calcular posição baseada no tamanho do overlay
            double left = offSetChild.dx + size.width;
            double top = offSetChild.dy;

            // Ajustar posição horizontal baseado em horizontalPosition
            if (widget.horizontalPosition == ExtendedTooltipPosition.left) {
              left = offSetChild.dx - value.width;
            } else if (widget.horizontalPosition ==
                ExtendedTooltipPosition.center) {
              left = offSetChild.dx + (size.width - value.width) / 2;
            }

            // Ajustar se está saindo da tela no eixo Y
            if (top + value.height > sizeScreen.height) {
              top = offSetChild.dy + size.height - value.height;
            }

            // Ajustar se está saindo da tela no eixo X
            if (left + value.width > sizeScreen.width) {
              left = offSetChild.dx - value.width;
            }
            if (left < 0) {
              left = 15;
            }

            return Positioned(
              left: left,
              top: top,
              child: child!,
            );
          },
          child: FadeContainer(
            duration: widget.animation,
            child: Container(
              decoration: widget.decoration ?? theme.tooltipTheme.decoration,
              child: Material(
                textStyle: widget.textStyle ?? theme.tooltipTheme.textStyle,
                color: Colors.transparent,
                child: WidgetSize(
                    onChange: (value) {
                      overlaySize.value = value;
                    },
                    child: overlayWidget),
              ),
            ),
          ),
        ),
      );

      overlay.insert(entry!);
    } catch (e) {
      // Silenciosamente falhar se houver problema de lifecycle
      entry = null;
    }
  }

  hideOverlay() {
    entry?.remove();
    entry = null;
  }

  Widget buildOverlay() {
    if (widget.keepTooltipWhenMouseHover == false) return widget.message;

    return MouseRegion(
      child: widget.message,
      onEnter: (details) {
        isMouseOverMessage = true;
      },
      onExit: (details) async {
        if (!mounted) return;
        isMouseOverMessage = false;
        await Future.delayed(const Duration(milliseconds: 100)).then((value) {
          if (!mounted) return;
          if (isMouseOverMessage) return;
          hideOverlay();
        });
      },
    );
  }
}
