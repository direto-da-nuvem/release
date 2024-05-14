import 'package:get/get.dart';
import 'package:dduff/routes/app_pages.dart';

class DashboardController extends GetxController {
  void logout(){
    Get.offAndToNamed(Routes.DASHBOARD);
  }
}