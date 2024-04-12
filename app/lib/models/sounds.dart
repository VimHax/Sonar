// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:math';

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
  final Map<String, Map<String, int>> _playing = {};
  StreamSubscription? _sub;
  RealtimeChannel? _channel;

  UnmodifiableListView<Sound>? get all =>
      _sounds == null ? null : UnmodifiableListView(_sounds!);

  UnmodifiableMapView<String, Set<String>> get playing =>
      UnmodifiableMapView(_playing.map((soundID, members) => MapEntry(
          soundID,
          members.entries
              .where((x) => x.value > 0)
              .map((x) => x.key)
              .toSet())));

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
    if (_channel == null) return;
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
            callback: (msg) {
              stdout.writeln('Playing received: $msg');
              try {
                String soundID = msg['payload']['sound'];
                String memberID = msg['payload']['member'];
                var members = _playing[soundID] ?? {};
                members[memberID] = (members[memberID] ?? 0) + 1;
                _playing[soundID] = members;
                notifyListeners();
              } catch (e) {
                // Ignore
              }
            })
        .onBroadcast(
            event: 'error',
            callback: (msg) {
              stdout.writeln('Error received: $msg');
              try {
                String soundID = msg['payload']['sound'];
                String memberID = msg['payload']['member'];
                var members = _playing[soundID] ?? {};
                members[memberID] = max((members[memberID] ?? 0) - 1, 0);
                _playing[soundID] = members;
                notifyListeners();
              } catch (e) {
                // Ignore
              }
            })
        .onBroadcast(
            event: 'completed',
            callback: (msg) {
              stdout.writeln('Completed received: $msg');
              try {
                String soundID = msg['payload']['sound'];
                String memberID = msg['payload']['member'];
                var members = _playing[soundID] ?? {};
                members[memberID] = max((members[memberID] ?? 0) - 1, 0);
                _playing[soundID] = members;
                notifyListeners();
              } catch (e) {
                // Ignore
              }
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
