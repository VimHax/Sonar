// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:collection';

import 'package:app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sounds.g.dart';

@JsonSerializable()
class Sound {
  Sound(
      {required this.id,
      required this.name,
      required this.thumbnail,
      required this.audio,
      required this.author});

  final String id;
  final String name;
  final String thumbnail;
  final String audio;
  final String author;

  factory Sound.fromJson(Map<String, dynamic> json) => _$SoundFromJson(json);
}

class SoundsModel extends ChangeNotifier {
  List<Sound>? _sounds;
  StreamSubscription? _sub;

  UnmodifiableListView<Sound>? get all =>
      _sounds == null ? null : UnmodifiableListView(_sounds!);

  SoundsModel() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        _stopTracking();
      } else {
        _startTracking();
      }
    });
  }

  void _startTracking() {
    _sub = supabase.from("sounds").stream(primaryKey: ['id']).listen((event) {
      _sounds = [];
      _sounds!.addAll(event.map((e) => Sound.fromJson(e)));
      notifyListeners();
    });
  }

  void _stopTracking() {
    _sounds = null;
    _sub?.cancel();
    _sub = null;
    notifyListeners();
  }
}
