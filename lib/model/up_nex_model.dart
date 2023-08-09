class UpNext {
  UpNext({
     required this.id,
     required this.visitor,});

  UpNext.fromJson(dynamic json) {
    id = json['id'];
    visitor = json['visitor'];
  }
  String? id;
  String? visitor;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['visitor'] = visitor;
    return map;
  }

}