import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
  final VoidCallback? onChange;

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
  });

  @override
  State<TextBoxField> createState() => _TextBoxFieldState();
}

class _TextBoxFieldState extends State<TextBoxField> {
  late bool isObscureText = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    isObscureText = widget.isisSenstive;
    _controller = TextEditingController(text: widget.rxObjectName?.value);

    _controller.addListener((){
       widget.rxObjectName?.value = _controller.text;
    });

  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //===============styling============
    final Color borderColor = widget.isDisabled ? Colors.red : Colors.grey.shade900;
     Widget suffix;
      if(widget.isisSenstive){
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
      }
      else if(widget.onSufixIconClick != null){
        suffix = IconButton(onPressed: widget.onSufixIconClick, icon: widget.sufixIcon!);
      }else{
        suffix =  widget.sufixIcon!;
      }
    OutlineInputBorder _border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 2),
      );
    }

    //===================================
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: widget.objectName,
        cursorColor: Colors.white,
        obscureText: isObscureText,
        decoration: InputDecoration(

          prefixIcon:
              widget.onPreFixIconClick != null
                  ? IconButton(onPressed: widget.onPreFixIconClick, icon: widget.preFixIcon!)
                  : widget.preFixIcon,
          suffixIcon:suffix,
          hintText: widget.placeHolder,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),

          errorText: widget.errorText,
          //errorStyle: ,
          filled: true,
          fillColor: Colors.grey.shade900,
          enabledBorder: _border(borderColor),
          focusedBorder: _border(borderColor),
        ),
        readOnly: widget.isDisabled,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onChanged: (value){
         // widget.objectName.value=value;
          widget.rxObjectName?.value=value;
        },
        //onChanged: widget.onChange != null ? widget.onChange : null,
      ),
    );
  }
}
