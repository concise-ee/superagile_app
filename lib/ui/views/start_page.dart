import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/question_mark%20_button.dart';
import 'package:superagile_app/ui/components/update_available.dart';
import 'package:superagile_app/ui/views/player_start_page.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/mixpanel_utils.dart';
import 'package:upgrader/upgrader.dart';

import 'host_start_page.dart';

class BeforeMain extends StatefulWidget {
  @override
  _BeforeMainState createState() => _BeforeMainState();
}

class _BeforeMainState extends State<BeforeMain> {

  @override
  Widget build(BuildContext context) {
    return buildSplashScreen(context);
  }

  Widget buildSplashScreen(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      navigateAfterSeconds: StartPage(),
      image: new Image.asset('lib/assets/superagile_app_logo.png'),
      backgroundColor: Colors.yellowAccent,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      loaderColor: Colors.black,
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  AppUpdateInfo _updateInfo;

  @override
  void initState() {
    checkForUpdate();
    super.initState();
  }

  Future<void> checkForUpdate() async {
    if (kReleaseMode) {
      var info = await InAppUpdate.checkForUpdate();
      setState(() => _updateInfo = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return popScope(context);
  }

  Widget popScope(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(HASH_SUPERAGILE),
            automaticallyImplyLeading: false,
            actions: [QuestionMarkButton()],
          ),
          body: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!kReleaseMode) {
      return _buildBodyContainer(context);
    }
    if (Platform.isAndroid) {
      return (_updateInfo?.updateAvailable == true
          ? UpdateAvailable(updateInfo: _updateInfo)
          : _buildBodyContainer(context));
    } else if (Platform.isIOS) {
      return UpgradeAlert(
          child: _buildBodyContainer(context),
          dialogStyle: UpgradeDialogStyle.cupertino,
          showIgnore: false,
          showLater: false);
    }
    throw ('Unsupported platform.');
  }

  Container _buildBodyContainer(BuildContext context) {
    return Container(
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
                          mixpanel.track('start_page: HOST THE WORKSHOP');
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
                          mixpanel.track('start_page: JOIN WITH CODE');
                          return PlayerStartPage();
                        }),
                      );
                    },
                  ),
                ),
              ],
            )));
  }
}
