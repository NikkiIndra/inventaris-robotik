import 'package:get/get.dart';

import '../controllers/barang_controller.dart';

class BarangBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BarangController>(
      () => BarangController(),
    );
  }
}
