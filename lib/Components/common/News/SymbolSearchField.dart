import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/Loader.dart';
import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';

class SymbolSearchField extends StatefulWidget {
  final Future<List<String>> Function(String query) fetchSymbols;
  final ValueChanged<String>? onSelected;

  const SymbolSearchField({
    super.key,
    required this.fetchSymbols,
    this.onSelected,
  });

  @override
  State<SymbolSearchField> createState() => _SymbolSearchFieldState();
}

class _SymbolSearchFieldState extends State<SymbolSearchField> {
  Timer? _debounce;
  bool isLoading = false;

  Future<Iterable<String>> _search(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return const [];
    }

    final completer = Completer<Iterable<String>>();

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      try {
        final results = await widget.fetchSymbols(query);

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        if (!completer.isCompleted) {
          completer.complete(results);
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        if (!completer.isCompleted) {
          completer.complete(const []);
        }
      }
    });

    return completer.future;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            return await _search(textEditingValue.text);
          },
          onSelected: (String selection) {
            widget.onSelected?.call(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextBoxField(
              objectName: controller,
              placeHolder: "Search symbol",
              onChange: (value) {
                widget.onSelected?.call(value);
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    maxWidth: 300,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () => widget.onSelected?.call(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(child: Loader()),
          ),
      ],
    );
  }
}
