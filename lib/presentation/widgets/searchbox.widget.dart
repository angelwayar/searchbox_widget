import 'dart:async';
import 'package:flutter/material.dart';

enum StateOfSearchbox { initial, loading, success, error }

class CustomClass<T extends Object> {
  final List<T>? data;
  final StateOfSearchbox stateOfSearchbox;

  CustomClass({this.data, this.stateOfSearchbox = StateOfSearchbox.initial});
}

class SearchboxWidget<T extends Object> extends StatefulWidget {
  final TextEditingController textEditingController;
  final String Function(T option) displayStringForOption;
  final CustomClass<T> customClassHelper;
  final double spaceBetweenOptions;
  final TextStyle? textStyle;
  final Text? label;
  final void Function(T option) onSelected;

  const SearchboxWidget({
    Key? key,
    required this.textEditingController,
    required this.displayStringForOption,
    required this.customClassHelper,
    this.spaceBetweenOptions = 12.0,
    this.textStyle,
    this.label,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<SearchboxWidget<T>> createState() => _SearchboxWidgetState<T>();
}

class _SearchboxWidgetState<T extends Object>
    extends State<SearchboxWidget<T>> {
  final link = LayerLink();
  late final OverlayEntry overlayEntry;
  late final OverlayState? overlayState;
  final streamController = StreamController<CustomClass<T>>.broadcast();
  final focusNode = FocusNode();
  var hasOverlay = false;

  @override
  void initState() {
    overlayState = Overlay.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlayEntry = _createOverlayEntry();
    });
    focusNode.addListener(() {
      if ((!focusNode.hasFocus) && (hasOverlay)) {
        hasOverlay = false;
        overlayEntry.remove();
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SearchboxWidget<T> oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.hasFocus) {
        if ((widget.customClassHelper.stateOfSearchbox ==
                StateOfSearchbox.loading) &&
            (oldWidget.customClassHelper.data == null)) {
          hasOverlay = true;
          overlayState?.insert(overlayEntry);
          streamController.sink.add(widget.customClassHelper);
        } else if ((widget.customClassHelper.stateOfSearchbox ==
                StateOfSearchbox.loading) &&
            (oldWidget.customClassHelper.data != null)) {
          if (!hasOverlay) {
            hasOverlay = true;
            overlayState?.insert(overlayEntry);
          }
          streamController.sink.add(widget.customClassHelper);
        } else if ((widget.customClassHelper.stateOfSearchbox ==
            StateOfSearchbox.success)) {
          streamController.sink.add(widget.customClassHelper);
        }
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    streamController.close();
    focusNode.dispose();
    super.dispose();
  }

  Widget _suggestion() {
    return StreamBuilder<CustomClass<T>>(
      stream: streamController.stream,
      builder: (BuildContext context, AsyncSnapshot<CustomClass<T>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.active:
            if (snapshot.hasData) {
              final data = snapshot.data as CustomClass;
              if (data.stateOfSearchbox == StateOfSearchbox.success) {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: widget.customClassHelper.data?.length,
                  itemBuilder: (context, index) {
                    final option =
                        widget.customClassHelper.data?.elementAt(index) as T;
                    final String text = widget.displayStringForOption(option);
                    return Padding(
                      padding: EdgeInsets.only(
                        top: 0,
                        bottom: widget.spaceBetweenOptions,
                      ),
                      child: InkWell(
                        onTap: () {
                          widget.onSelected(option);
                          widget.textEditingController.text = text;
                          widget.textEditingController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                              offset: widget.textEditingController.text.length,
                            ),
                          );
                          hasOverlay = false;
                          focusNode.unfocus();
                          overlayEntry.remove();
                        },
                        child: Text(text, style: widget.textStyle),
                      ),
                    );
                  },
                );
              } else if (data.stateOfSearchbox == StateOfSearchbox.loading) {
                return const Center(child: CircularProgressIndicator());
              }
            }
            return const SizedBox();
          default:
            return const SizedBox();
        }
      },
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: ((BuildContext context) {
        return StreamBuilder<CustomClass<T>>(
          stream: streamController.stream,
          builder: (context, snapshot) {
            return Positioned(
              left: size.width,
              child: CompositedTransformFollower(
                link: link,
                offset: Offset(0, size.height + 7),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Material(
                    child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.885,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 12.0),
                            blurRadius: 12.0,
                            spreadRadius: 1.2,
                          )
                        ],
                      ),
                      child: _suggestion(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: link,
      child: TextFormField(
        focusNode: focusNode,
        controller: widget.textEditingController,
        decoration: InputDecoration(
          label: widget.label,
        ),
      ),
    );
  }
}
