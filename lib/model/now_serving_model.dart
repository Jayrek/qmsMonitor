class NowServing {
  NowServing({
    required this.visitor,
    required this.window,
  });

  NowServing.fromJson(dynamic json) {
    visitor = json['visitor'];
    window = json['window'];
  }

  String? visitor;
  int? window;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['visitor'] = visitor;
    map['window'] = window;
    return map;
  }
}
