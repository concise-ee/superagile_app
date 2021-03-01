import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/utils/labels.dart';

class AgileWithBackIconButton extends StatelessWidget {
  AgileWithBackIconButton(this.onPressed);

  final Function() onPressed;

  @override
  Widget build(context) {
    return FlatButton.icon(
        onPressed: () => onPressed(),
        icon: Icon(Icons.arrow_back, size: 24),
        label: Text(HASH_SUPERAGILE, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)));
  }
}
