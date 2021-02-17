import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:superagile_app/utils/labels.dart';

class MailingService {
  void sendResults(String email, Map<String, int> scores, String totalScore) {
    http.post(APP_SCRIPTS_URL,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: convert.jsonEncode({
          'email': email,
          'finalScore': totalScore,
          'agreedScore1': scores['0'],
          'agreedScore2': scores['1'],
          'agreedScore3': scores['2'],
          'agreedScore4': scores['3'],
          'agreedScore5': scores['4'],
          'agreedScore6': scores['5'],
          'agreedScore7': scores['6'],
          'agreedScore8': scores['7'],
          'agreedScore9': scores['8'],
          'agreedScore10': scores['9'],
          'agreedScore11': scores['10'],
          'agreedScore12': scores['11'],
          'agreedScore13': scores['12'],
        }),
        encoding: Encoding.getByName('utf-8'));
  }
}
