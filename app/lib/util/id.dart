import 'package:app/main.dart';

String getMemberID() {
  return supabase.auth.currentSession!.user.identities!.elementAt(0).id;
}
