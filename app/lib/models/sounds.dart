// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:app/main.dart';
import 'package:app/util/id.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  RealtimeChannel? _channel;

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

  Sound? get(String id) {
    return _sounds!.firstWhereOrNull((e) => e.id == id);
  }

  void play(String id) {
    _channel!.sendBroadcastMessage(
        event: "play", payload: {'sound': id, 'member': getMemberID()});
  }

  void _startTracking() {
    _sub = supabase.from("sounds").stream(primaryKey: ['id']).listen((event) {
      _sounds = [];
      _sounds!.addAll(event.map((e) => Sound.fromJson(e)));
      notifyListeners();
    });
    _channel = supabase
        .channel("soundboard")
        .onBroadcast(
            event: 'playing',
            callback: (payload) {
              print('Play received: $payload');
            })
        .onBroadcast(
            event: 'error',
            callback: (payload) {
              print('Play received: $payload');
            })
        .onBroadcast(
            event: 'completed',
            callback: (payload) {
              print('Complete received: $payload');
            })
        .subscribe();
  }

  void _stopTracking() {
    _sounds = null;
    _sub?.cancel();
    _sub = null;
    if (_channel != null) {
      supabase.removeChannel(_channel!);
      _channel = null;
    }
    notifyListeners();
  }
}
