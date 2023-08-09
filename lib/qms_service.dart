import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constant_util.dart';
import 'model/queue_model.dart';

class QmsService {
  QmsService._();

  static Future<QueueModel> getQueue() async {
    final client = http.Client();

    try {
      var response =
          await client.get(Uri.parse('${ConstantUtil.baseUrl}queue/get_next'));
      final responseBody = jsonDecode(response.body);
      final queue = QueueModel.fromJson(responseBody);
      return queue;
    } catch (e) {
      throw Exception(e);
    }
  }
}
