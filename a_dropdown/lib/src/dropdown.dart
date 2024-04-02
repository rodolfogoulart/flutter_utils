import 'package:a_dropdown/src/button.dart';
import 'package:a_dropdown/src/utils/fade_container.dart';
import 'package:a_dropdown/src/utils/value_notifier_list.dart';
import 'package:flutter/material.dart';

const kDurationAnimation = Duration(milliseconds: 300);

class ADropDownItem<T> {
  T value;

  /// [onTap] callback to use on item builder click
  ///
  /// you can build the default [onTap] here and just use on [menuItemBuilder]
  VoidCallback? onTap;
  ADropDownItem({
    required this.value,
    this.onTap,
  });
}

class ControllerADropDown<T> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final ValueNotifierList<ADropDownItem<T>> _itens = ValueNotifierList();
  final ValueNotifier<T?> _selectedItem = ValueNotifier<T?>(null);

  bool isShowing = false;

  List<T> get itens => _itens.value.map((e) => e.value).toList();

  ControllerADropDown({
    List<ADropDownItem<T>> itens = const [],
  }) {
    this._itens.addAll(itens);
    _selectedItem.value = itens.firstOrNull?.value;
  }

  /// adds an item
  void addItem(ADropDownItem<T> item) {
    _itens.add(item);
    _selectedItem.value ??= _itens.value.firstOrNull?.value;
  }

  void addAllItens(List<ADropDownItem<T>> itens) {
    _itens.addAll(itens);
    _selectedItem.value ??= itens.firstOrNull?.value;
  }

  bool isEmpty() {
    return _itens.value.isEmpty;
  }

  /// returns the selected value
  T? get selectedValue => _selectedItem.value;

  void setValue(T value) {
    hideMenu();
    _selectedItem.value = value;
  }

  void removeItem(ADropDownItem<T> value) {
    _itens.remove(value);
  }

  void clear() {
    _itens.clear();
  }

  void showMenu() {
    isShowing = !isShowing;
    _overlayController.toggle();
  }

  void hideMenu() {
    isShowing = false;
    try {
      _overlayController.hide();
    } catch (e) {
      // debugPrint('error to hide menu\n$e');
    }
  }

  void dispose() {
    hideMenu();
  }
}

//https://medium.com/snapp-x/creating-custom-dropdowns-with-overlayportal-in-flutter-4f09b217cfce

/// [ADropDown] is a Custom DropDown Widget
///
/// you can build the **menu** with the [menuItemBuilder] and the **button** with the [buttonBuilder] as you want
///
/// set a animation for the menu and the button on the [animationBuilderMenu] and [animationBuilderButton]
///
/// set a default decoration for the menu and button on the [decorationMenu] and [decorationButton]
///
/// set your on menu background on the [menuBackgroundBuilder]
///
/// tips: use the [menuBackgroundBuilder] to set a size for the widget, other wise the default size will be used
///
/// use [controller] to control the menu, add itens, show and hide the menu, set the selected value and remove itens
///
/// the menu will be positioned on center of the Button, and the position of the menu will be relative to the button
class ADropDown<T> extends StatefulWidget {
  const ADropDown({
    super.key,
    required this.controller,
    required this.menuItemBuilder,
    this.animationBuilderMenu,
    this.menuBackgroundBuilder,
    this.decorationMenu,
    this.textStyleMenu,
    required this.buttonBuilder,
    this.animationBuilderButton,
    this.decorationButton,
    this.textStyleButton,
    this.paddingInBettween = 5,
  });

  final ControllerADropDown<T> controller;

  /// builder of the menu itens
  final Widget Function(BuildContext context, List<ADropDownItem<T>> itens) menuItemBuilder;

  /// builder of the menu background
  final Widget Function(BuildContext context, Widget child)? menuBackgroundBuilder;

  /// builder for animation
  final Widget Function(BuildContext context, Widget child)? animationBuilderMenu;

  /// the decoration of the menu
  final BoxDecoration? decorationMenu;

  /// the text style of the menu
  final TextStyle? textStyleMenu;

  /// builder of the selected item
  final Widget Function(BuildContext context, T value) buttonBuilder;

  /// builder for animation
  final Widget Function(BuildContext context, Widget child)? animationBuilderButton;

  /// the decoration of the button
  final BoxDecoration? decorationButton;

  /// the text style of the button
  final TextStyle? textStyleButton;

  /// add padding between the [button] and the [menu] on vertical axis
  final double paddingInBettween;

  @override
  State<ADropDown<T>> createState() => _ADropDownState<T>();
}

class _ADropDownState<T> extends State<ADropDown<T>> {
  // final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    try {
      widget.controller.dispose();
    } catch (e) {
      debugPrint('error to dispose ControllerADropDown \n$e');
    }
    super.dispose();
  }

  /// to ignore onTap when TapRegion is outside
  bool ignoreOnTap = false;
  bool isHouverButtom = false;

  GlobalKey<State<StatefulWidget>> myKeyButton = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final themeDropDown = Theme.of(context).dropdownMenuTheme;

    // assert(widget.controller.itens.value.isNotEmpty, 'itens must not be empty');
    return OverlayPortal(
      controller: widget.controller._overlayController,
      overlayChildBuilder: (BuildContext context) {
        Size sizeScreen = MediaQuery.of(context).size;
        sizeScreen *= .95;
        RenderBox? renderBox = myKeyButton.currentContext?.findRenderObject() as RenderBox?;
        Size? sizeButton = renderBox?.size;
        Offset? offsetButton = renderBox?.localToGlobal(Offset.zero);
        //fix the size with the offset of the button - the size of the button - the padding
        sizeScreen = Size(sizeScreen.width, sizeScreen.height - offsetButton!.dy - sizeButton!.height - widget.paddingInBettween);
        //
        ignoreOnTap = false;
        var child = widget.animationBuilderMenu != null
            ? widget.animationBuilderMenu!(
                context,
                Container(
                  constraints: BoxConstraints(maxWidth: sizeScreen.width, maxHeight: sizeScreen.height - 20),
                  child: widget.menuItemBuilder
                      .call(context, widget.controller._itens.value.map((e) => ADropDownItem<T>(value: e.value)).toList()),
                ),
              )
            : FadeContainer(
                duration: kDurationAnimation,
                child: Container(
                  constraints: BoxConstraints(maxWidth: sizeScreen.width, maxHeight: sizeScreen.height - 20),
                  child: widget.menuItemBuilder.call(
                    context,
                    widget.controller._itens.value.map((e) => ADropDownItem<T>(value: e.value)).toList(),
                  ),
                ),
              );

        child = widget.menuBackgroundBuilder != null
            ? widget.menuBackgroundBuilder!(context, child)
            : Container(
                decoration: widget.decorationMenu ??
                    BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(25)),
                constraints: BoxConstraints(maxWidth: sizeScreen.width, maxHeight: sizeScreen.height - 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Material(
                        type: MaterialType.transparency,
                        textStyle: widget.textStyleMenu,
                        child: child,
                      ),
                    ),
                  ],
                ),
              );
        //tapregion to hide menu on tap outside the menu
        child = TapRegion(
          onTapOutside: (event) {
            //check if is houver Button to ignore onTap
            if (isHouverButtom) {
              return;
            }
            widget.controller.hideMenu();
          },
          child: child,
        );

        /// from https://stackoverflow.com/a/65547847/17966723
        /// to position the menu
        return CustomSingleChildLayout(
          delegate: MyDelegate(
              anchorSize: sizeButton, anchorOffset: offsetButton, sizeScreen: sizeScreen, padding: widget.paddingInBettween),
          child: child,
        );
      },
      child: ValueListenableBuilder(
        valueListenable: widget.controller._selectedItem,
        builder: (context, selected, child) {
          Widget button = MouseRegion(
            onEnter: (event) {
              isHouverButtom = true;
            },
            onExit: (event) {
              isHouverButtom = false;
            },
            child: AButton(
              onTap: () {
                widget.controller.showMenu();
              },
              decoration: widget.decorationButton ?? BoxDecoration(borderRadius: BorderRadius.circular(25)),
              textStyle: widget.textStyleButton ?? themeDropDown.textStyle ?? DefaultTextStyle.of(context).style,
              child: widget.buttonBuilder.call(context, widget.controller.selectedValue as T),
            ),
          );
          Widget child;
          if (widget.animationBuilderButton != null) {
            child = widget.animationBuilderButton!(context, button);
          } else {
            child = FadeContainer(
              duration: kDurationAnimation,
              child: button,
            );
          }
          return Builder(
              key: myKeyButton,
              builder: (context) {
                return child;
              });
        },
      ),
    );
  }
}

class MyDelegate extends SingleChildLayoutDelegate {
  final Size anchorSize;
  Offset anchorOffset;
  Size sizeScreen;
  double padding;

  MyDelegate({required this.anchorSize, required this.anchorOffset, required this.sizeScreen, required this.padding});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // we allow our child to be smaller than parent's constraint:
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // debugPrint('--------------------------');
    // debugPrint("my size: $size");
    // debugPrint("childSize: $childSize");
    // debugPrint("anchor size being passed in: $anchorSize}");
    // debugPrint("anchor offset being passed in: $anchorOffset}");

    // where to position the child? perform calculation here:
    var newOffsetCenter =
        Offset((anchorOffset.dx - childSize.width / 2) + anchorSize.width / 2, anchorOffset.dy + anchorSize.height);
    // debugPrint("newOffsetCenter: $newOffsetCenter");
    // debugPrint('sizeScreen: $sizeScreen');
    // debugPrint('--------------------------');

    if (newOffsetCenter.dx < 0) {
      newOffsetCenter = Offset(0, newOffsetCenter.dy);
    } else {
      if ((newOffsetCenter.dx + childSize.width) > size.width) {
        double fixPositionX = size.width - (newOffsetCenter.dx + childSize.width);
        // debugPrint('fixPos?itionX $fixPositionX');
        newOffsetCenter = Offset(newOffsetCenter.dx + fixPositionX, newOffsetCenter.dy);
      }
    }
    // debugPrint('new position fixed: ${newOffsetCenter}');
    //
    Offset newOffset = Offset(newOffsetCenter.dx, newOffsetCenter.dy + padding);
    return newOffset;
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) => true;
}
