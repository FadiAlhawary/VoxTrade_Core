// import 'package:flutter/material.dart';
// import 'package:voxtrade_core/Components/common/TextField/TextBoxField.dart';

// class SearchBox extends StatelessWidget {
//   final Future<List<String>> Function(String query) fetchSymbols;
//   final ValueChanged<String>? onSelected;

//   const SearchBox({super.key, required this.fetchSymbols, this.onSelected});

//   @override
//   Widget build(BuildContext context) {
//     return Autocomplete<String>(
//       optionsBuilder: (TextEditingValue textEditingValue) async {
//         final query = textEditingValue.text.trim();

//         if (query.isEmpty) {
//           return const Iterable<String>.empty();
//         }

//         try {
//           final results = await fetchSymbols(query);
//           return results;
//         } catch (_) {
//           return const Iterable<String>.empty();
//         }
//       },
//       onSelected: (String selection) {
//         onSelected?.call(selection);
//       },
//       fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
//         return TextBoxField(
//           placeHolder: "Search symbol",
//           preFixIcon: const Icon(Icons.search),
//           objectName: controller,
//           onChange: (value) {
//             onSelected?.call(value);
//           },
//         );
//       },
//     );
//   }
// }
