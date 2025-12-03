import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnggotaController extends GetxController {
  final search = ''.obs;
  final isLoading = false.obs;
  final namaC = TextEditingController();
  final kontakC = TextEditingController();
  final divisiC = TextEditingController();
  final statusC = TextEditingController(text: "aktif");
  final isFormValid = false.obs;
  final anggotaList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAnggota();
  }

  // =====================================================
  // SIMPAN ANGGOTA KE FIREBASE
  // =====================================================
  Future<void> saveAnggota({
    required String nama,
    required String kontak,
    required String divisi,
    required String status,
  }) async {
    try {
      await FirebaseFirestore.instance.collection("anggota").add({
        "nama": nama,
        "kontak": kontak,
        "divisi": divisi,
        "status": status,
        "tanggalDaftar": DateTime.now().toIso8601String(),
        "update": DateTime.now().toIso8601String(),
      });

      print('Anggota berhasil disimpan');
      Get.back(); // Tutup dialog
    } catch (e) {
      print('Gagal menyimpan anggota: $e');
    }
  }

  // =====================================================
  // UPDATE ANGGOTA
  // =====================================================
  Future<void> updateAnggota(String id) async {
    try {
      await FirebaseFirestore.instance.collection("anggota").doc(id).update({
        "nama": namaC.text,
        "kontak": kontakC.text,
        "divisi": divisiC.text,
        "status": statusC.text,
        "update": DateTime.now().toIso8601String(),
      });

      print('Anggota berhasil diupdate');
      clearForm();
    } catch (e) {
      print("Error updating anggota: $e");
    }
  }

  // =====================================================
  // HAPUS ANGGOTA
  // =====================================================
  Future<void> deleteAnggota(String id) async {
    try {
      await FirebaseFirestore.instance.collection("anggota").doc(id).delete();
      print('Anggota berhasil dihapus');
    } catch (e) {
      print('Gagal menghapus anggota: $e');
    }
  }

  // =====================================================
  // LOAD ANGGOTA DARI FIRESTORE
  // =====================================================
  void loadAnggota() {
    FirebaseFirestore.instance.collection("anggota").snapshots().listen((snap) {
      anggotaList.value = snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data["id"] = d.id;
        return data;
      }).toList();
    });
  }

  // =====================================================
  // GET ANGGOTA BY ID
  // =====================================================
  Future<Map<String, dynamic>?> getAnggotaById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("anggota")
          .doc(id)
          .get();
      if (doc.exists) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data["id"] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting anggota: $e');
      return null;
    }
  }

  // =====================================================
  // GET ANGGOTA AKTIF SAJA
  // =====================================================
  // GET ANGGOTA AKTIF SAJA
  List<Map<String, dynamic>> get anggotaAktif {
    return anggotaList.where((anggota) {
      final status = anggota['status'];
      return status != null && status.toString() == 'aktif';
    }).toList();
  }

  // =====================================================
  // FILTER SEARCH
  // =====================================================
  List<Map<String, dynamic>> get filteredAnggota {
    if (search.value.isEmpty) return anggotaList;

    return anggotaList
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
    kontakC.clear();
    divisiC.clear();
    statusC.clear();
  }

  // =====================================================
  // Validasi Form
  // =====================================================
  void validateForm(String nama, String kontak, String divisi, String status) {
    isFormValid.value =
        nama.isNotEmpty && kontak.isNotEmpty && status.isNotEmpty;
  }
}
