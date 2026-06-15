import '../helpers/user_info.dart';
import '../helpers/api_client.dart';

class LoginService {
  Future<bool> login(String username, String password) async {
    final response = await ApiClient().post("?action=login", {
      'username': username,
      'password': password,
    });
    
    final data = response.data;
    if (data['status'] == true) {
      await UserInfo().setToken("token_${data['id']}");
      await UserInfo().setUserID(data['id']);
      await UserInfo().setUsername(data['nama']);
      await UserInfo().setRole(data['role']);
      return true;
    }
    
    return false;
  }
}
