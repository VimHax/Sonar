// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      id: json['id'] as String,
      username: json['username'] as String,
      global_name: json['global_name'] as String?,
      avatar: json['avatar'] as String,
      banner: json['banner'] as String?,
      accent_color: json['accent_color'] as int?,
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'global_name': instance.global_name,
      'avatar': instance.avatar,
      'banner': instance.banner,
      'accent_color': instance.accent_color,
    };
