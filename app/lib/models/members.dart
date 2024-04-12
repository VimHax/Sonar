// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:app/main.dart';
import 'package:app/util/id.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'members.g.dart';

@JsonSerializable()
class Member {
  Member(
      {required this.id,
      required this.username,
      required this.global_name,
      required this.avatar,
      required this.banner,
      required this.accent_color,
      required this.joined});

  final String id;
  final String username;
  final String? global_name;
  final String avatar;
  final String? banner;
  final int? accent_color;
  final bool joined;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}

class MembersModel extends ChangeNotifier {
  List<Member>? _members;
  StreamSubscription? _sub;

  UnmodifiableListView<Member>? get all =>
      _members == null ? null : UnmodifiableListView(_members!);

  Member? get me {
    if (_members == null) return null;
    return getNullable(getMemberID());
  }

  MembersModel() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        _stopTracking();
      } else {
        _startTracking();
      }
    });
  }

  Member get(String id) {
    return _members!.firstWhere((e) => e.id == id);
  }

  Member? getNullable(String id) {
    return _members!.firstWhereOrNull((e) => e.id == id);
  }

  void _startTracking() {
    _sub = supabase.from("members").stream(primaryKey: ['id']).listen((event) {
      _members = [];
      _members!.addAll(event.map((e) => Member.fromJson(e)));
      notifyListeners();
    });
  }

  void _stopTracking() {
    _members = null;
    _sub?.cancel();
    _sub = null;
    notifyListeners();
  }
}
