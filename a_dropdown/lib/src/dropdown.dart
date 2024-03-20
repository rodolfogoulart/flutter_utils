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
  final ValueNotifierList<ADropDownItem<T>> itens = ValueNotifierList();
  final ValueNotifier<T?> _selectedItem = ValueNotifier<T?>(null);

  bool isShowing = false;

  ControllerADropDown({
    List<ADropDownItem<T>> items = const [],
  }) {
    this.itens.addAll(items);
    _selectedItem.value = items.firstOrNull?.value;
  }

  /// adds an item
  void addItem(ADropDownItem<T> item) {
    itens.add(item);
    _selectedItem.value ??= itens.value.firstOrNull?.value;
  }

  void addAllItens(List<ADropDownItem<T>> items) {
    itens.addAll(items);
    _selectedItem.value ??= items.firstOrNull?.value;
  }

  /// returns the selected value
  T? get selectedValue => _selectedItem.value;

  void setValue(T value) {
    hideMenu();
    _selectedItem.value = value;
  }

  removeItem(ADropDownItem<T> value) {
    itens.remove(value);
  }

  void clear() {
    itens.clear();
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
      debugPrint('error to hide menu\n$e');
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
  });

  final ControllerADropDown<T> controller;

  /// builder of the menu items
  final Widget Function(BuildContext context, List<ADropDownItem<T>> items) menuItemBuilder;

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

  @override
  State<ADropDown<T>> createState() => _ADropDownState<T>();
}

class _ADropDownState<T> extends State<ADropDown<T>> {
  final LayerLink _layerLink = LayerLink();

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
  @override
  Widget build(BuildContext context) {
    final themeDropDown = Theme.of(context).dropdownMenuTheme;
    var sizeScreen = MediaQuery.of(context).size;
    sizeScreen *= .7;

    assert(widget.controller.itens.value.isNotEmpty, 'items must not be empty');
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: widget.controller._overlayController,
        overlayChildBuilder: (BuildContext context) {
          ignoreOnTap = false;
          var child = widget.animationBuilderMenu != null
              ? widget.animationBuilderMenu!(
                  context,
                  Container(
                    constraints: BoxConstraints(maxWidth: sizeScreen.width, maxHeight: sizeScreen.height - 20),
                    child: widget.menuItemBuilder
                        .call(context, widget.controller.itens.value.map((e) => ADropDownItem<T>(value: e.value)).toList()),
                  ),
                )
              : FadeContainer(
                  duration: kDurationAnimation,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: sizeScreen.width, maxHeight: sizeScreen.height - 20),
                    child: widget.menuItemBuilder.call(
                      context,
                      widget.controller.itens.value.map((e) => ADropDownItem<T>(value: e.value)).toList(),
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
          child = TapRegion(
            onTapOutside: (event) {
              widget.controller.hideMenu();
              ignoreOnTap = true;
            },
            child: child,
          );

          return CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: child,
            ),
          );
        },
        child: ValueListenableBuilder(
          valueListenable: widget.controller._selectedItem,
          builder: (context, selected, child) {
            Widget button = AButton(
              onTap: onTap,
              decoration: widget.decorationButton ?? BoxDecoration(borderRadius: BorderRadius.circular(25)),
              textStyle: widget.textStyleButton ?? themeDropDown.textStyle ?? DefaultTextStyle.of(context).style,
              child: widget.buttonBuilder.call(context, widget.controller.selectedValue as T),
            );
            if (widget.animationBuilderButton != null) {
              return widget.animationBuilderButton!(context, button);
            } else {
              return FadeContainer(
                duration: kDurationAnimation,
                child: button,
              );
            }
          },
        ),
      ),
    );
  }

  void onTap() {
    if (ignoreOnTap) {
      ignoreOnTap = false;
      return;
    }
    widget.controller.showMenu();
  }
}
