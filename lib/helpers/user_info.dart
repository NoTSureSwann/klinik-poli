import 'package:shared_preferences/shared_preferences.dart';

const String TOKEN = "token";
const String USER_ID = "userID";
const String USERNAME = "username";
const String ROLE = "role";

class UserInfo{
  Future setToken(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(TOKEN, value);
  }

  Future<String?> getToken() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(TOKEN);
  }

  Future setUserID(String value) async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(USER_ID, value);
  }

  Future<String> getUserID() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(USER_ID).toString();
  }

  Future setUsername(String value) async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(USERNAME, value);
  }

  Future<String> getUsername() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(USERNAME).toString();
  }

  Future<void> logout() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  Future setRole(String value) async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(ROLE, value);
  }

  Future<String> getRole() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(ROLE).toString();
  }
}