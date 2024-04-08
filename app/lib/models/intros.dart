// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

part 'intros.g.dart';

@JsonSerializable()
class Intro {
  Intro({required this.id, required this.sound});

  final String id;
  final String sound;

  factory Intro.fromJson(Map<String, dynamic> json) => _$IntroFromJson(json);
}

class IntrosModel extends ChangeNotifier {
  List<Intro>? _intros;
  StreamSubscription? _sub;

  UnmodifiableListView<Intro>? get all =>
      _intros == null ? null : UnmodifiableListView(_intros!);

  IntrosModel() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        _stopTracking();
      } else {
        _startTracking();
      }
    });
  }

  Intro? get(String id) {
    return _intros!.firstWhereOrNull((e) => e.id == id);
  }

  void _startTracking() {
    _sub = supabase.from("intros").stream(primaryKey: ['id']).listen((event) {
      _intros = [];
      _intros!.addAll(event.map((e) => Intro.fromJson(e)));
      notifyListeners();
    });
  }

  void _stopTracking() {
    _intros = null;
    _sub?.cancel();
    _sub = null;
    notifyListeners();
  }
}
