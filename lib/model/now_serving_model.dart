class NowServing {
  NowServing({
    required this.visitor,
    required this.window,
    required this.trans,
  });

  NowServing.fromJson(dynamic json) {
    visitor = json['visitor'];
    window = json['window'];
    trans = json['trans'];
  }

  String? visitor;
  int? window;
  String? trans;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['visitor'] = visitor;
    map['window'] = window;
    map['trans'] = trans;
    return map;
  }
}
