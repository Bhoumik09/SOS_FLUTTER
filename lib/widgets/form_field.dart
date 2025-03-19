import 'package:flutter/material.dart';

class FormFields extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  const FormFields({required this.text, required this.controller, super.key});

  @override
  State<FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends State<FormFields> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(          
          hintText: "Enter here...",

          labelText: 'Enter Your ${widget.text}',
          labelStyle: const TextStyle(color: Colors.blue),
          border: const OutlineInputBorder(
            borderSide: BorderSide(width: 2),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          )),
    );
  }
}
