import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/AddDocument.dart';

class BarangController extends GetxController {
  final search = ''.obs;
  final isLoading = false.obs;
  final namaC = TextEditingController();
  final kategoriC = TextEditingController(
    text: 'microcontroller',
  ); // Set default value
  final lokasiC = TextEditingController(text: 'rak 1');
  final stokC = TextEditingController();
  final kondisiC = TextEditingController(text: 'baik'); // Set default value
  final catatanC = TextEditingController();
  final isFormValid = false.obs;
  final barangList = <Map<String, dynamic>>[].obs;

  // List kategori
  final List<String> kategoriList = [
    'microcontroller',
    'sensor',
    'actuator',
    'robot_kit',
    'perlengkapan_lain',
  ];

  // List kondisi
  final List<String> kondisiList = [
    'baik',
    'cukup',
    'rusak_ringan',
    'rusak_berat',
  ];

  @override
  void onInit() {
    super.onInit();
    loadBarang();
  }

  // =====================================================
  // BUKA DIALOG
  // =====================================================
  void openAddBarangDialog() {
    Get.dialog(AddBarang(), barrierDismissible: false);
  }

  // =====================================================
  // SIMPAN BARANG KE FIREBASE
  // =====================================================
  Future<void> saveBarang({
    required String nama,
    required String kategori,
    required String lokasi,
    required String stok,
    required String kondisi,
    required String catatan,
  }) async {
    try {
      await FirebaseFirestore.instance.collection("barang").add({
        "nama": nama,
        "kategori": kategori,
        "lokasi": lokasi,
        "stok": int.tryParse(stok) ?? 0,
        "kondisi": kondisi,
        "catatan": catatan,
        "update": DateTime.now().toIso8601String(),
      });

      print('Barang berhasil disimpan');
      Get.back(); // Tutup dialog
    } catch (e) {
      print('Gagal menyimpan barang: $e');
    }
  }

  // =====================================================
  // UPDATE BARANG
  // =====================================================
  Future<void> updateBarang(String id) async {
    try {
      await FirebaseFirestore.instance.collection("barang").doc(id).update({
        "nama": namaC.text,
        "kategori": kategoriC.text,
        "lokasi": lokasiC.text,
        "stok": int.tryParse(stokC.text) ?? 0,
        "kondisi": kondisiC.text,
        "catatan": catatanC.text,
        "update": DateTime.now().toIso8601String(),
      });

      print('Barang berhasil diupdate');
      clearForm();
    } catch (e) {
      print("Error updating barang: $e");
    }
  }

  // =====================================================
  // HAPUS BARANG
  // =====================================================
  Future<void> deleteBarang(String id) async {
    try {
      await FirebaseFirestore.instance.collection("barang").doc(id).delete();
      print('Barang berhasil dihapus');
    } catch (e) {
      print('Gagal menghapus barang: $e');
    }
  }

  // Helper untuk mendapatkan stok sebagai int
  int getStokAsInt(Map<String, dynamic> data) {
    final stok = data['stok'];
    if (stok is int) return stok;
    if (stok is String) return int.tryParse(stok) ?? 0;
    if (stok is double) return stok.toInt();
    return 0;
  }

  // =====================================================
  // LOAD BARANG DARI FIRESTORE
  // =====================================================
  void loadBarang() {
    FirebaseFirestore.instance.collection("barang").snapshots().listen((snap) {
      barangList.value = snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data["id"] = d.id;
        return data;
      }).toList();
    });
  }

  // =====================================================
  // GET BARANG BY ID
  // =====================================================
  Future<Map<String, dynamic>?> getBarangById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("barang")
          .doc(id)
          .get();
      if (doc.exists) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data["id"] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting barang: $e');
      return null;
    }
  }

  // =====================================================
  // FILTER SEARCH
  // =====================================================
  List<Map<String, dynamic>> get filteredBarang {
    if (search.value.isEmpty) return barangList;

    return barangList
        .where(
          (e) => (e['nama'] ?? '').toString().toLowerCase().contains(
            search.value.toLowerCase(),
          ),
        )
        .toList();
  }

  // =====================================================
  // CLEAR FORM
  // =====================================================

  void clearForm() {
    namaC.clear();
    kategoriC.text = 'microcontroller'; // Reset ke default
    lokasiC.clear();
    stokC.clear();
    kondisiC.text = 'baik'; // Reset ke default
    catatanC.clear();
    isFormValid.value = false;
  }

  // =====================================================
  // Validasi Form
  // =====================================================
  void validateForm(
    String nama,
    String kategori,
    String lokasi,
    String stok,
    String kondisi,
    String catatan,
  ) {
    // Debug print untuk melihat nilai
    print('Validating: $nama, $kategori, $lokasi, $stok, $kondisi, $catatan');
    print(
      'kategoriList contains $kategori: ${kategoriList.contains(kategori)}',
    );
    print('kondisiList contains $kondisi: ${kondisiList.contains(kondisi)}');

    isFormValid.value =
        nama.isNotEmpty &&
        kategoriList.contains(kategori) &&
        lokasi.isNotEmpty &&
        stok.isNotEmpty &&
        kondisiList.contains(kondisi) &&
        catatan.isNotEmpty;
  }

  // Fungsi helper untuk mendapatkan warna berdasarkan kondisi
  Color getKondisiColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return Colors.green;
      case 'cukup':
        return Colors.orange;
      case 'rusak_ringan':
        return Colors.red.withOpacity(0.7);
      case 'rusak_berat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
