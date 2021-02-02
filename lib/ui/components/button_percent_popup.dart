import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';

class ButtonPercentPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.fitWidth,
        child: FlatButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  elevation: 16,
                  child: Container(
                    height: 400.0,
                    width: 360.0,
                    child: ListView(
                      children: <Widget>[
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            ANSWERED,
                            style: TextStyle(fontSize: 24, color: accentColor),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 5.0,
            animation: true,
            percent: 0.7,
            progressColor: Colors.yellow,
            backgroundColor: Colors.black,
          ),
        ));
  }
}
