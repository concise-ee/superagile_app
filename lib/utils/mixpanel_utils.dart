import 'package:flutuate_mixpanel/flutuate_mixpanel.dart';

MixpanelAPI mixpanel;

void initMixpanel() async {
  mixpanel = await MixpanelAPI.getInstance(String.fromEnvironment('MIXPANEL_TOKEN'));
}
