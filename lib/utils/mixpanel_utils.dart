import 'package:mixpanel_flutter/mixpanel_flutter.dart';

Mixpanel mixpanel;
const mixpanelToken = String.fromEnvironment('MIXPANEL_TOKEN');
Future<void> initMixpanel() async {
  mixpanel = await Mixpanel.init(mixpanelToken, optOutTrackingDefault: false);
}
