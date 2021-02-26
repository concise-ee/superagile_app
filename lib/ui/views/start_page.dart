import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/question_mark%20_button.dart';
import 'package:superagile_app/ui/components/update_available.dart';
import 'package:superagile_app/ui/views/player_start_page.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/mixpanel_utils.dart';
import 'package:upgrader/upgrader.dart';

import 'host_start_page.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  AppUpdateInfo _updateInfo;

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(HASH_SUPERAGILE),
            automaticallyImplyLeading: false,
            actions: [QuestionMarkButton()],
          ),
          body: _buildBody(context),
        ));
  }

  Widget _buildBody(BuildContext context) {
    return _updateInfo?.updateAvailable == true
        ? UpdateAvailable(updateInfo: _updateInfo)
        : UpgradeAlert(
            debugLogging: true,
            child: Container(
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 5,
                          child: AgileButton(
                            buttonTitle: HOST_WORKSHOP,
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  trackElement('Host Workshop');
                                  return HostStartPage();
                                }),
                              );
                            },
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Flexible(
                          flex: 5,
                          child: AgileButton(
                            buttonTitle: JOIN_WITH_CODE,
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  trackElement('Join Workshop');
                                  return PlayerStartPage();
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    ))));
  }
}
