import 'package:get/get.dart';

import '../modules/anggota/bindings/anggota_binding.dart';
import '../modules/anggota/views/anggota_view.dart';
import '../modules/barang/bindings/barang_binding.dart';
import '../modules/barang/views/barang_view.dart';
import '../modules/login/views/login_view.dart';
import '../modules/navigation/bindings/navigation_binding.dart';
import '../modules/navigation/views/navigation_view.dart';
import '../modules/peminjaman/bindings/peminjaman_binding.dart';
import '../modules/peminjaman/views/peminjaman_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
    ),
    GetPage(
      name: _Paths.BARANG,
      page: () => const BarangView(),
      binding: BarangBinding(),
    ),
    GetPage(
      name: _Paths.ANGGOTA,
      page: () => const AnggotaView(),
      binding: AnggotaBinding(),
    ),
    GetPage(
      name: _Paths.PEMINJAMAN,
      page: () => PeminjamanView(),
      binding: PeminjamanBinding(),
    ),
    GetPage(
      name: _Paths.NAVIGATION,
      page: () => const NavigationView(),
      binding: NavigationBinding(),
    ),
  ];
}
