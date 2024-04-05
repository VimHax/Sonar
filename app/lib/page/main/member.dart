// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

@JsonSerializable()
class Member {
  Member(
      {required this.username,
      required this.global_name,
      required this.avatar,
      required this.banner,
      required this.accent_color});

  final String username;
  final String? global_name;
  final String avatar;
  final String? banner;
  final int? accent_color;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}

class MemberModel extends ChangeNotifier {
  Member? _member;

  Member? get value => _member;

  void set(Member member) {
    if (_member != null) throw Exception("Member already set.");
    _member = member;
    notifyListeners();
  }
}
