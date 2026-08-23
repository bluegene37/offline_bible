import 'package:flutter/material.dart';

class OutlineSearchBar extends StatefulWidget {
  final FocusNode? focusNode;
  final Color? clearButtonColor;
  final Color? cursorColor;
  final Color? searchButtonIconColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;
  final TextEditingController? textEditingController;
  final String? initText;
  final String? hintText;
  final ValueChanged<String>? onSearchButtonPressed;
  final ValueChanged<String>? onClearButtonPressed;
  final ValueChanged<String>? onKeywordChanged;

  const OutlineSearchBar({
    super.key,
    this.focusNode,
    this.clearButtonColor,
    this.cursorColor,
    this.searchButtonIconColor,
    this.borderColor,
    this.margin,
    this.textEditingController,
    this.initText,
    this.hintText,
    this.onSearchButtonPressed,
    this.onClearButtonPressed,
    this.onKeywordChanged,
  });

  @override
  State<OutlineSearchBar> createState() => _OutlineSearchBarState();
}

class _OutlineSearchBarState extends State<OutlineSearchBar> {
  late TextEditingController _controller;

  /// Only set when this widget created the controller itself. A caller-owned
  /// controller outlives this widget and must not be disposed here.
  TextEditingController? _ownedController;

  @override
  void initState() {
    super.initState();
    _controller = widget.textEditingController ??
        (_ownedController = TextEditingController());
    if (widget.initText != null && widget.initText!.isNotEmpty) {
      _controller.text = widget.initText!;
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: TextField(
        focusNode: widget.focusNode,
        controller: _controller,
        cursorColor: widget.cursorColor,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          prefixIcon: IconButton(
            icon: Icon(Icons.search, color: widget.searchButtonIconColor),
            onPressed: () {
              if (widget.onSearchButtonPressed != null) {
                widget.onSearchButtonPressed!(_controller.text);
              }
            },
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: widget.clearButtonColor),
            onPressed: () {
              _controller.clear();
              if (widget.onClearButtonPressed != null) {
                widget.onClearButtonPressed!('');
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: widget.borderColor ?? Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: widget.borderColor ?? Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: widget.borderColor ?? Colors.grey,
              width: 2.0,
            ),
          ),
        ),
        onChanged: widget.onKeywordChanged,
        onSubmitted: widget.onSearchButtonPressed,
      ),
    );
  }
}