import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/ui/views/about_page.dart';
import 'package:superagile_app/utils/global_theme.dart';

class QuestionMarkButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.help),
      color: accentColor,
      iconSize: 40,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AboutPage(),
            fullscreenDialog: true,
          ),
        );
      },
    );
  }
}
