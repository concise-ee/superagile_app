import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        FOLLOW_US,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: Image.asset('lib/assets/facebook.png'),
              onPressed: () => _launchURL('https://www.facebook.com/concisechangestheworld')),
          IconButton(
              icon: Image.asset('lib/assets/instagram.png'),
              onPressed: () => _launchURL('https://www.instagram.com/concisechangestheworld')),
          IconButton(
              icon: Image.asset('lib/assets/linkedin.png'),
              onPressed: () => _launchURL('https://ee.linkedin.com/company/concisechangestheworld')),
          IconButton(
              icon: Image.asset('lib/assets/youtube.png'),
              onPressed: () => _launchURL('https://www.youtube.com/channel/UCK7wm7UDEIP0t6a9FGTMlqg')),
        ],
      )
    ]);
  }

  _launchURL(String url) async {
    await launch(url);
  }
}
