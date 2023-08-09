import 'now_serving_model.dart';
import 'up_nex_model.dart';

class QueueModel {
  QueueModel({
    required this.respcode,
    required this.message,
    required this.newCall,
    required this.nowServing,
    required this.upNext,
  });

  QueueModel.fromJson(dynamic json) {
    respcode = json['respcode'];
    message = json['message'];
    newCall = json['new_call'];
    if (json['now_serving'] != null) {
      nowServing = [];
      json['now_serving'].forEach((v) {
        nowServing?.add(NowServing.fromJson(v));
      });
    }
    if (json['up_next'] != null) {
      upNext = [];
      json['up_next'].forEach((v) {
        upNext?.add(UpNext.fromJson(v));
      });
    }
  }

  int? respcode;
  String? message;
  String? newCall;
  List<NowServing>? nowServing;
  List<UpNext>? upNext;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['respcode'] = respcode;
    map['message'] = message;
    map['new_call'] = newCall;
    if (nowServing != null) {
      map['now_serving'] = nowServing?.map((v) => v.toJson()).toList();
    }
    if (upNext != null) {
      map['up_next'] = upNext?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
