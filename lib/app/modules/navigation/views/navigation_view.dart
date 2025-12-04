import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:inventaris_robotik/app/modules/anggota/views/anggota_view.dart';
import 'package:inventaris_robotik/app/modules/barang/views/barang_view.dart';
import 'package:inventaris_robotik/app/modules/peminjaman/views/peminjaman_view.dart';

import '../controllers/navigation_controller.dart';

class NavigationView extends GetView<NavigationController> {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Content
          Row(
            children: [
              // Content Area
              Expanded(
                child: Container(
                  color: Colors.white38,
                  child: Obx(() {
                    return IndexedStack(
                      index: controller.currentIndex.value,
                      children: [
                         BarangView(),
                        AnggotaView(),
                        PeminjamanView(),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),

          // Floating Navbar
          Positioned(
            left: 16, // Jarak dari kiri
            top: 30, // Jarak dari atas
            bottom: 30, // Jarak dari bawah
            child: Container(
              width: 64, // Lebar navbar lebih kecil seperti di gambar
              decoration: BoxDecoration(
                color: Colors.white38, // Transparan putih
                borderRadius: BorderRadius.circular(20), // Sudut melengkung
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header/Logo Navbar
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // Logo/Gambar seperti di screenshot
                        Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white38,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image(
                            image: AssetImage("assets/images/robotik.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(
                      color: Colors.grey[400]!.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),

                  // Menu Items - Vertikal seperti di gambar
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.menuItems.length,
                      itemBuilder: (context, index) {
                        return Obx(
                          () => Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Material(
                              color: controller.currentIndex.value == index
                                  ? Colors.deepPurple
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () {
                                  if (index == 3) {
                                    controller.confirmLogout();
                                  } else {
                                    controller.changePage(index);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Tooltip(
                                  message: controller
                                      .menuItems[index], // isi tooltip sesuai itemmu
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 50,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          _getIconForIndex(index),
                                          color:
                                              controller.currentIndex.value ==
                                                  index
                                              ? Colors.white
                                              : Colors.deepPurple,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom spacing
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: // Dashboard
        return CupertinoIcons.cube_box;
      case 1: // Create News
        return CupertinoIcons.group;
      case 2: // Create News
        return CupertinoIcons.square_pencil_fill;
      case 3: // Create News
        return CupertinoIcons.square_arrow_left;
      default:
        return CupertinoIcons.circle;
    }
  }
}
