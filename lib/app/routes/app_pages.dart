import 'package:get/get.dart';
import '../views/home_view.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => HomeView(),
    ),
  ];
}

class Routes {
  static const home = '/';
  static const other = '/other';
}
