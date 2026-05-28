import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';

class TextBoxField extends StatefulWidget {
  final bool isDisabled;
  final String? errorText;
  final String placeHolder;
  final TextEditingController objectName;
  final RxString? rxObjectName;
  final Icon? preFixIcon;
  final VoidCallback? onPreFixIconClick;
  final Icon? sufixIcon;
  final VoidCallback? onSufixIconClick;
  final bool isisSenstive;
  final Function(String value)? onChange;
  final TextInputType? keyboardType;
  final String? suffixText;
  final double horizontalPadding;

  const TextBoxField({
    super.key,
    this.isDisabled = false,
    this.errorText,
    required this.placeHolder,
    required this.objectName,
    this.rxObjectName,
    this.preFixIcon,
    this.onPreFixIconClick,
    this.sufixIcon,
    this.onSufixIconClick,
    this.isisSenstive = false,
    this.onChange,
    this.keyboardType,
    this.suffixText,
    this.horizontalPadding = 20,
  });

  @override
  State<TextBoxField> createState() => _TextBoxFieldState();
}

class _TextBoxFieldState extends State<TextBoxField> {
  late bool isObscureText = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    isObscureText = widget.isisSenstive;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode.value;
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    //===============styling============
    final Color baseFillColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final Color borderColor =
        hasError
            ? Colors.red
            : _isFocused
            ? accentColor
            : (isDarkMode
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.12));
    final double borderWidth = _isFocused ? 1.6 : 1.1;
    final Color iconColor =
        hasError
            ? Colors.redAccent
            : _isFocused
            ? accentColor
            : (isDarkMode ? Colors.white60 : Colors.black54);
    Widget? suffix;

    if (widget.isisSenstive) {
      suffix = IconButton(
        onPressed: () {
          setState(() {
            isObscureText = !isObscureText;
          });
        },
        icon:
            isObscureText
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
      );
    } else if (widget.onSufixIconClick != null && widget.sufixIcon != null) {
      suffix = IconButton(
        onPressed: widget.onSufixIconClick,
        icon: widget.sufixIcon!,
      );
    } else if (widget.sufixIcon != null) {
      suffix = widget.sufixIcon;
    }
    OutlineInputBorder _border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    //===================================
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: AnimatedScale(
        scale: _isFocused ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: baseFillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow:
                _isFocused
                    ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.14),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: widget.objectName,
            keyboardType: widget.keyboardType,
            cursorColor: isDarkMode ? Colors.white : Colors.black,
            obscureText: isObscureText,
            decoration: InputDecoration(
              prefixIcon:
                  widget.onPreFixIconClick != null
                      ? IconButton(
                        onPressed: widget.onPreFixIconClick,
                        icon: widget.preFixIcon!,
                      )
                      : widget.preFixIcon,
              suffixIcon: suffix,
              prefixIconColor: iconColor,
              suffixIconColor: iconColor,
              hintText: widget.placeHolder,
              hintStyle: TextStyle(
                color:
                    _isFocused
                        ? (isDarkMode ? Colors.white70 : Colors.black54)
                        : (isDarkMode ? Colors.white38 : Colors.black38),
              ),
              suffixText: widget.suffixText,
              enabledBorder: _border(Colors.transparent, 0),
              focusedBorder: _border(Colors.transparent, 0),
              errorBorder: _border(Colors.transparent, 0),
              focusedErrorBorder: _border(Colors.transparent, 0),
              errorText: widget.errorText,
              filled: true,
              fillColor: Colors.transparent,
            ),
            readOnly: widget.isDisabled,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onChanged: (value) {
              widget.rxObjectName?.value = value;
              widget.onChange?.call(value);
            },
          ),
        ),
      ),
    );
  }
}
