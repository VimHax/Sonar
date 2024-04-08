// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sounds.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sound _$SoundFromJson(Map<String, dynamic> json) => Sound(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbnail: json['thumbnail'] as String,
      audio: json['audio'] as String,
      author: json['author'] as String,
    );

Map<String, dynamic> _$SoundToJson(Sound instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'thumbnail': instance.thumbnail,
      'audio': instance.audio,
      'author': instance.author,
    };
