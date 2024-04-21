import 'package:get/get.dart';

class CheckInOutTabController extends GetxController {
  RxInt _currentIndex = 0.obs;

  RxInt get currentIndex => _currentIndex;

  set setCurrentIndex(int val) {
    _currentIndex.value = val;
    update();
  }
}