import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/utils/global_theme.dart';

class RoundedTextFormField extends StatelessWidget {
  RoundedTextFormField(
      {@required this.hintText,
      @required this.controller,
      this.maxLength,
      this.keyboardType,
      this.key,
      this.validator});

  final String hintText;
  final TextEditingController controller;
  final int maxLength;
  final TextInputType keyboardType;
  final Key key;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        key: key,
        validator: validator,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(fontSize: fontMedium),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(24.0),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: fontMedium, color: accentColor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: secondaryColor, width: 3), borderRadius: BorderRadius.circular(60.0)),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: secondaryColor, width: 3), borderRadius: BorderRadius.circular(60.0)),
        ),
      ),
    );
  }
}
