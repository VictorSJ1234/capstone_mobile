import 'package:http/http.dart' as http;
import 'dart:convert';

final url = 'http://192.168.0.140:3000/';
final registration = url + "registration";
final login = url + "login";
final createUserReport = url + "createUserReport";
final getUserReport = url + 'getUserReport';
final getUserData = url + 'getUserData';
final deleteUserReport = url + 'deleteUserReport';
final editUserData = url + 'editUser';
final getAdminResponse = url + 'getAdminResponse';
final getCommunityProjects= url + 'getAllCommunityProjects';
final getCommunityProjectsById= url + 'getCommunityProject';
final communityProjectNotificationStatus= url + 'createNotificationStatus';
final getNotificationStatus= url + 'getNotificationStatus';
final editPassword = url + 'changeMobileUserPassword';
final updateNotificationStatus = url + 'updateNotificationStatus';
final updateReportNotificationStatus = url + 'updateReportNotificationStatus';
final getReportById = url + 'getUserReportById';
final resetPassword = url + 'resetPassword';


//192.168.1.119 - dorm ip
//192.168.43.115 - mobile ip


String? userId;

// Function to fetch unread notifications and update the unreadCardCount
Future<void> fetchUnreadNotifications(String userId) async {
  try {
    var response = await http.post(
      Uri.parse(getNotificationStatus),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "notificationStatus": "Unread"}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List notifications = jsonResponse['notifications'];

      int unreadCount = notifications.where((notification) =>
      notification['notificationStatus'] == 'Unread').length;

      updateUnreadCardCount(unreadCount);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print(error);
  }
}


//for notification
int unreadCardCount = 0;

void updateUnreadCardCount(int count) {
  unreadCardCount = count;
}
