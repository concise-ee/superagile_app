import 'dart:convert';

import 'package:http/http.dart' as http;

class MailingService {
  static const APP_SCRIPTS_URL =
      'https://script.google.com/macros/s/AKfycbyQXnLhyn1pMN4Rq0NodnfUO_r0l3GhiI6VOh15PDGngrOBzDoEzPcskw/exec';

  void sendResults(String email, Map<String, int> scores, String totalScore) {
    http.post(APP_SCRIPTS_URL,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'finalScore': totalScore,
          'agreedScore1': scores['1'],
          'agreedScore2': scores['2'],
          'agreedScore3': scores['3'],
          'agreedScore4': scores['4'],
          'agreedScore5': scores['5'],
          'agreedScore6': scores['6'],
          'agreedScore7': scores['7'],
          'agreedScore8': scores['8'],
          'agreedScore9': scores['9'],
          'agreedScore10': scores['10'],
          'agreedScore11': scores['11'],
          'agreedScore12': scores['12'],
          'agreedScore13': scores['13'],
        }));
  }
}
