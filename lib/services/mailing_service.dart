import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;

class MailingService {
  void sendResults(String email, Map<String, int> scores) async {
    List<String> subScores = new List();
    for (MapEntry<String, int> score in scores.entries) {
      subScores.add(score.value.toString());
    }
    ;
    await http.post(
        'https://script.google.com/macros/s/AKfycbyQXnLhyn1pMN4Rq0NodnfUO_r0l3GhiI6VOh15PDGngrOBzDoEzPcskw/exec',
        headers: <String, String>{'Content-Type': 'application/x-www-form-urlencoded'},
        body: convert.jsonEncode({
          'email': email,
          'finalScore': scores.values.reduce((sum, value) => sum + value).toString(),
          'agreedScore1': subScores[0],
          'agreedScore2': subScores[1],
          'agreedScore3': subScores[2],
          'agreedScore4': subScores[3],
          'agreedScore5': subScores[4],
          'agreedScore6': subScores[5],
          'agreedScore7': subScores[6],
          'agreedScore8': subScores[7],
          'agreedScore9': subScores[8],
          'agreedScore10': subScores[9],
          'agreedScore11': subScores[10],
          'agreedScore12': subScores[11],
          'agreedScore13': subScores[12],
        }),
        encoding: Encoding.getByName('utf-8'));
  }
}
