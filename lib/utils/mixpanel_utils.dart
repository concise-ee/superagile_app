import 'package:mixpanel_flutter/mixpanel_flutter.dart';

Mixpanel mixpanel;
Future<void> initMixpanel() async {
  mixpanel = await Mixpanel.init(String.fromEnvironment('MIXPANEL_TOKEN'), optOutTrackingDefault: false);
}
