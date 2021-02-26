import 'package:flutuate_mixpanel/flutuate_mixpanel.dart';

const mixpanelToken = String.fromEnvironment('MIXPANEL_TOKEN');

void trackElement(String eventName) async {
  MixpanelAPI instance = await MixpanelAPI.getInstance(mixpanelToken);
  instance.track(eventName);
}
