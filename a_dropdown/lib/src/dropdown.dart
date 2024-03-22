import 'package:a_dropdown/src/button.dart';
import 'package:a_dropdown/src/utils/fade_container.dart';
import 'package:a_dropdown/src/utils/value_notifier_list.dart';
import 'package:flutter/material.dart';

const kDurationAnimation = Duration(milliseconds: 300);

class ADropDownItem<T> {
  T value;

  /// onTap callback to use on item builder click
  ///
  /// you can build the onTap here and just use on menuItemBuilder
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

  get itens => _itens.value;

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

  isEmpty() {
    return _itens.value.isEmpty;
  }

  /// returns the selected value
  T? get selectedValue => _selectedItem.value;

  void setValue(T value) {
    hideMenu();
    _selectedItem.value = value;
  }

  removeItem(ADropDownItem<T> value) {
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
    this.paddingInBettween = EdgeInsets.zero,
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

  /// add padding between the button and the menu
  final EdgeInsetsGeometry paddingInBettween;

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
    var sizeScreen = MediaQuery.of(context).size;
    sizeScreen *= .7;

    // assert(widget.controller.itens.value.isNotEmpty, 'itens must not be empty');
    return
        // CompositedTransformTarget(
        //   link: _layerLink,
        //   child:
        OverlayPortal(
      controller: widget.controller._overlayController,
      overlayChildBuilder: (BuildContext context) {
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

        if (widget.paddingInBettween != EdgeInsets.zero) {
          child = Padding(
            padding: widget.paddingInBettween,
            child: child,
          );
        }
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
        // print('_layerLink.leaderSize ${_layerLink.leaderSize}');
        // print('_layerLink.leader?.offset ${_layerLink.leader?.offset}');
        // print(' total ${(_layerLink.leader?.offset.dx ?? 0) + (_layerLink.leaderSize?.width ?? 0)}');
        // print(MediaQuery.of(context).size);

        // RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        // var anchorSize = renderBox?.size;
        // print('anchorSize $anchorSize');
        RenderBox? renderBox = myKeyButton.currentContext?.findRenderObject() as RenderBox?;
        var sizeButton = renderBox?.size;
        var offsetButton = renderBox?.localToGlobal(Offset.zero);
        // print('anchorButton $sizeButton');
        // print('offsetButton $offsetButton');

        return CustomSingleChildLayout(
          delegate: MyDelegate(anchorSize: sizeButton!, anchorOffset: offsetButton!, sizeScreen: sizeScreen),
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
      // ),
    );
  }
}

class MyDelegate extends SingleChildLayoutDelegate {
  final Size anchorSize;
  Offset anchorOffset;
  Size sizeScreen;

  MyDelegate({required this.anchorSize, required this.anchorOffset, required this.sizeScreen});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // we allow our child to be smaller than parent's constraint:
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // print('--------------------------');
    // print("my size: $size");
    // print("childSize: $childSize");
    // print("anchor size being passed in: $anchorSize}");
    // print("anchor offset being passed in: $anchorOffset}");
    double paddingY = 5;
    // where to position the child? perform calculation here:
    var newOffsetCenter =
        Offset((anchorOffset.dx - childSize.width / 2) + anchorSize.width / 2, anchorOffset.dy + anchorSize.height);
    // print("newOffsetCenter: $newOffsetCenter");
    // print('sizeScreen: $sizeScreen');
    // print('--------------------------');

    if (newOffsetCenter.dx < 0) {
      newOffsetCenter = Offset(0, newOffsetCenter.dy);
    } else {
      if ((newOffsetCenter.dx + childSize.width) > size.width) {
        double fixPositionX = size.width - (newOffsetCenter.dx + childSize.width);
        print('fixPos?itionX $fixPositionX');
        newOffsetCenter = Offset(newOffsetCenter.dx + fixPositionX, newOffsetCenter.dy);
      }
    }
    // print('new position fixed: ${newOffsetCenter}');
    //
    return Offset(newOffsetCenter.dx, newOffsetCenter.dy + paddingY);
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) => true;
}
