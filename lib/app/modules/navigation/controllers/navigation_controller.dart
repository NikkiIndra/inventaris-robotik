import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventaris_robotik/app/modules/barang/controllers/barang_controller.dart';

import '../../../helper/loading.dart';
import '../../login/bindings/login_binding.dart';
import '../../login/views/login_view.dart';

class NavigationController extends GetxController {
  final controller = Get.find<BarangController>();
  var currentIndex = 0.obs;

  List<String> menuItems = ['Barang', 'Anggota', 'Peminjaman', 'Logout'];

  void changePage(int index) {
    controller.search.value = "";
    currentIndex.value = index;
  }

  Future<void> logout() async {
    LoadingHelper.show();

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 500));

    // HAPUS semua controller GetX biar tidak bentrok
    Get.deleteAll(force: true);

    LoadingHelper.hide();

    Get.offAll(() => const LoginView(), binding: LoginBinding());
  }

  // Di NavigationController atau controller yang mengatur logout
  Future<void> confirmLogout() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Yakin ingin keluar dari akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (result == true) {
      await logout();
    }
  }
}
