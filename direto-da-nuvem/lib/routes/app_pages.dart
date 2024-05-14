import 'package:get/get.dart';
import 'package:dduff/ui/views/dashboard_page.dart';
import 'package:dduff/ui/views/device_page.dart';
import 'package:dduff/ui/views/login_page.dart';
import 'package:dduff/ui/views/showcase_page.dart';
import 'package:dduff/ui/views/edit_page.dart';
import 'package:dduff/ui/views/admin_page.dart';
import 'package:dduff/ui/views/device_page.dart';
import 'package:dduff/ui/views/start_page.dart';
import 'package:dduff/ui/views/notifications.dart';
import 'package:dduff/ui/views/about.dart';

import '../ui/views/queue_page.dart';

part './app_routes.dart';

abstract class Pages{

  static final pages = [
    GetPage(name: Routes.DASHBOARD, page:() => const DashboardPage()),
    GetPage(name: Routes.DEVICES, page:() => const DeviceInfoPage()),
    GetPage(name: Routes.LOGIN, page:() => const LoginPage()),
    GetPage(name: Routes.SHOWCASE, page:() => const ShowcasePage()),
    GetPage(name: Routes.EDIT, page:() => const EditPage()),
    GetPage(name: Routes.ADMIN, page:() => const AdminPage()),
    GetPage(name: Routes.QUEUE, page:() => const QueueListPage()),
    GetPage(name: Routes.START, page:() => const StartPage()),
    GetPage(name: Routes.NOTIFICATIONS, page:() => NotificationPage()),
    GetPage(name: Routes.ABOUT, page:() => AboutPage()),

    //QueueListPage
  ];
}
