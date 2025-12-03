import 'package:get/get.dart';
import 'package:inventaris_robotik/app/modules/anggota/controllers/anggota_controller.dart';
import 'package:inventaris_robotik/app/modules/barang/controllers/barang_controller.dart';
import 'package:inventaris_robotik/app/modules/peminjaman/controllers/peminjaman_controller.dart';

import '../modules/login/controllers/login_controller.dart';
import '../modules/navigation/controllers/navigation_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnggotaController>(() => AnggotaController(), fenix: true);
    Get.lazyPut<BarangController>(() => BarangController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<PeminjamanController>(
      () => PeminjamanController(),
      fenix: true,
    );
    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );
  }
}
