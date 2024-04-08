import 'package:app/main.dart';
import 'package:app/models/sounds.dart';

String getThumbnail(Sound sound) {
  return supabase.storage
      .from("thumbnail")
      .getPublicUrl("${sound.author}/${sound.thumbnail}");
}

String getAudio(Sound sound) {
  return supabase.storage
      .from("audio")
      .getPublicUrl("${sound.author}/${sound.audio}");
}
