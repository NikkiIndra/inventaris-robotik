import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../service/export_service.dart';

class PeminjamanController extends GetxController {
  final search = ''.obs;
  final isLoading = false.obs;

  // Controller untuk form peminjaman
  final anggotaIdC = TextEditingController();
  final barangIdC = TextEditingController();
  final jumlahC = TextEditingController();
  final kondisiSaatPinjamC = TextEditingController();
  final tanggalRencanaKembaliC = TextEditingController();
  final catatanC = TextEditingController();
  final statusC = TextEditingController(text: "dipinjam");
  final RxString statusPengembalian = 'selesai'.obs;

  // Untuk pencarian
  final selectedAnggota = Rx<Map<String, dynamic>?>(null);
  final selectedBarang = Rx<Map<String, dynamic>?>(null);

  final isFormValid = false.obs;
  final peminjamanList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPeminjaman();
  }


  final ExportService exportService = ExportService();

  // Header untuk file export
  final List<String> peminjamanHeaders = [
    'Nama Anggota',
    'Nama Barang',
    'Jumlah',
    'Kondisi Saat Pinjam',
    'Kondisi Saat Kembali',
    'Tanggal Pinjam',
    'Rencana Kembali',
    'Tanggal Kembali',
    'Status',
    'Catatan',
  ];

  // Field yang diambil dari Map Firestore
  final List<String> peminjamanFields = [
    'anggotaDetail.nama',
    'barangDetail.nama',
    'jumlah',
    'kondisiSaatPinjam',
    'kondisiSaatKembali',
    'tanggalPinjam',
    'tanggalRencanaKembali',
    'tanggalKembali',
    'status',
    'catatan',
  ];

  void handleExportPeminjaman(String format) async {
    final data = peminjamanList; // semua data peminjaman

    try {
      if (format == 'excel') {
        await exportService.exportToXlsx(
          title: "Data Peminjaman",
          headers: peminjamanHeaders,
          fields: peminjamanFields,
          data: data,
        );
      } else if (format == 'pdf') {
        await exportService.exportToPdf(
          title: "Data Peminjaman",
          headers: peminjamanHeaders,
          fields: peminjamanFields,
          data: data,
        );
      }

      Get.snackbar("Export", "Export berhasil ($format)");
    } catch (e) {
      Get.snackbar("Error", "Gagal export: $e");
    }
  }

  // =====================================================
  // SIMPAN PEMINJAMAN KE FIREBASE (DENGAN REFERENSI)
  // =====================================================
  Future<void> savePeminjaman({
    required String anggotaId,
    required String barangId,
    required int jumlah,
    required String kondisiSaatPinjam,
    required DateTime tanggalRencanaKembali,
    required String catatan,
    required String status,
  }) async {
    try {
      // Membuat referensi ke dokumen anggota dan barang
      final anggotaRef = FirebaseFirestore.instance
          .collection("anggota")
          .doc(anggotaId);
      final barangRef = FirebaseFirestore.instance
          .collection("barang")
          .doc(barangId);

      // Mengurangi stok barang
      await kurangiStokBarang(barangId, jumlah);

      await FirebaseFirestore.instance.collection("peminjaman").add({
        "anggotaRef": anggotaRef, // Menyimpan referensi
        "barangRef": barangRef, // Menyimpan referensi
        "anggotaId": anggotaId, // Menyimpan ID juga untuk kemudahan
        "barangId": barangId, // Menyimpan ID juga untuk kemudahan
        "jumlah": jumlah,
        "kondisiSaatPinjam": kondisiSaatPinjam,
        "kondisiSaatKembali": null,
        "tanggalPinjam": DateTime.now().toIso8601String(),
        "tanggalRencanaKembali": tanggalRencanaKembali.toIso8601String(),
        "tanggalKembali": null,
        "status": status,
        "catatan": catatan,
        "update": DateTime.now().toIso8601String(),
      });

      print('Peminjaman berhasil disimpan');
      Get.back(); // Tutup dialog
    } catch (e) {
      print('Gagal menyimpan peminjaman: $e');
    }
  }

  // =====================================================
  // UPDATE STATUS PENGEMBALIAN
  // =====================================================
  Future<void> updatePengembalian({
    required String peminjamanId,
    required String kondisiSaatKembali,
    required String status,
    required int jumlahRusak,
    required int jumlahHilang,
    String? catatanTambahan,
  }) async {
    try {
      final peminjamanDoc = await FirebaseFirestore.instance
          .collection("peminjaman")
          .doc(peminjamanId)
          .get();

      if (!peminjamanDoc.exists) return;

      final data = peminjamanDoc.data()!;
      final barangId = data['barangId'];
      final jumlahDipinjam = data['jumlah'];

      // Hitung jumlah yang benar-benar kembali
      int jumlahKembali = jumlahDipinjam;

      if (status == 'rusak') {
        jumlahKembali = jumlahDipinjam - jumlahRusak;
      } else if (status == 'hilang') {
        jumlahKembali = jumlahDipinjam - jumlahHilang;
      }

      if (jumlahKembali < 0) jumlahKembali = 0;

      // === Update stok barang ===
      if (jumlahKembali > 0) {
        await FirebaseFirestore.instance
            .collection("barang")
            .doc(barangId)
            .update({"stok": FieldValue.increment(jumlahKembali)});
      }

      // === Update data peminjaman ===
      await FirebaseFirestore.instance
          .collection("peminjaman")
          .doc(peminjamanId)
          .update({
            "kondisiSaatKembali": kondisiSaatKembali,
            "status": status,
            "tanggalKembali": DateTime.now().toIso8601String(),
            "jumlahKembali": jumlahKembali,
            "jumlahRusak": jumlahRusak,
            "jumlahHilang": jumlahHilang,
            "catatan": catatanTambahan != null
                ? "${data['catatan'] ?? ''}\n[Pengembalian]: $catatanTambahan"
                : data['catatan'],
            "update": DateTime.now().toIso8601String(),
          });

      print("Pengembalian berhasil diupdate");
    } catch (e) {
      print("❌ Error updating pengembalian: $e");
    }
  }

  // =====================================================
  // KURANGI STOK BARANG SAAT PEMINJAMAN
  // =====================================================
  Future<void> kurangiStokBarang(String barangId, int jumlah) async {
    try {
      final barangDoc = await FirebaseFirestore.instance
          .collection("barang")
          .doc(barangId)
          .get();

      if (barangDoc.exists) {
        final stokSekarang = barangDoc.data()!['stok'] ?? 0;
        final stokBaru = stokSekarang - jumlah;

        await FirebaseFirestore.instance
            .collection("barang")
            .doc(barangId)
            .update({
              "stok": stokBaru >= 0 ? stokBaru : 0,
              "update": DateTime.now().toIso8601String(),
            });
      }
    } catch (e) {
      print('Error mengurangi stok: $e');
    }
  }

  // =====================================================
  // TAMBAH STOK BARANG SAAT PENGEMBALIAN
  // =====================================================
  Future<void> tambahStokBarang(String barangId, int jumlah) async {
    try {
      final barangDoc = await FirebaseFirestore.instance
          .collection("barang")
          .doc(barangId)
          .get();

      if (barangDoc.exists) {
        final stokSekarang = barangDoc.data()!['stok'] ?? 0;
        final stokBaru = stokSekarang + jumlah;

        await FirebaseFirestore.instance
            .collection("barang")
            .doc(barangId)
            .update({
              "stok": stokBaru,
              "update": DateTime.now().toIso8601String(),
            });
      }
    } catch (e) {
      print('Error menambah stok: $e');
    }
  }

  // =====================================================
  // LOAD PEMINJAMAN DENGAN DATA TERKAIT
  // =====================================================
  void loadPeminjaman() {
    FirebaseFirestore.instance
        .collection("peminjaman")
        .orderBy('tanggalPinjam', descending: true)
        .snapshots()
        .listen((snap) async {
          // Untuk setiap peminjaman, load data anggota dan barang terkait
          final peminjamanWithDetails = <Map<String, dynamic>>[];

          for (var doc in snap.docs) {
            final data = Map<String, dynamic>.from(doc.data());
            data["id"] = doc.id;

            // Load data anggota jika ada referensi
            if (data['anggotaId'] != null) {
              try {
                final anggotaDoc = await FirebaseFirestore.instance
                    .collection("anggota")
                    .doc(data['anggotaId'])
                    .get();
                if (anggotaDoc.exists) {
                  data['anggotaDetail'] = anggotaDoc.data();
                }
              } catch (e) {
                print('Error loading anggota: $e');
              }
            }

            // Load data barang jika ada referensi
            if (data['barangId'] != null) {
              try {
                final barangDoc = await FirebaseFirestore.instance
                    .collection("barang")
                    .doc(data['barangId'])
                    .get();
                if (barangDoc.exists) {
                  data['barangDetail'] = barangDoc.data();
                }
              } catch (e) {
                print('Error loading barang: $e');
              }
            }

            peminjamanWithDetails.add(data);
          }

          peminjamanList.value = peminjamanWithDetails;
        });
  }

  // =====================================================
  // GET PEMINJAMAN BY ID
  // =====================================================
  Future<Map<String, dynamic>?> getPeminjamanById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("peminjaman")
          .doc(id)
          .get();
      if (doc.exists) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data["id"] = doc.id;

        // Load detail anggota dan barang
        if (data['anggotaId'] != null) {
          final anggota = await FirebaseFirestore.instance
              .collection("anggota")
              .doc(data['anggotaId'])
              .get();
          if (anggota.exists) {
            data['anggotaDetail'] = anggota.data();
          }
        }

        if (data['barangId'] != null) {
          final barang = await FirebaseFirestore.instance
              .collection("barang")
              .doc(data['barangId'])
              .get();
          if (barang.exists) {
            data['barangDetail'] = barang.data();
          }
        }

        return data;
      }
      return null;
    } catch (e) {
      print('Error getting peminjaman: $e');
      return null;
    }
  }

  // =====================================================
  // GET PEMINJAMAN AKTIF (BELUM DIKEMBALIKAN)
  // =====================================================
  List<Map<String, dynamic>> get peminjamanAktif {
    return peminjamanList.where((p) => p['status'] == 'dipinjam').toList();
  }

  // =====================================================
  // GET PEMINJAMAN OLEH ANGGOTA
  // =====================================================
  List<Map<String, dynamic>> getPeminjamanByAnggota(String anggotaId) {
    return peminjamanList.where((p) => p['anggotaId'] == anggotaId).toList();
  }

  // =====================================================
  // GET PEMINJAMAN BARANG TERTENTU
  // =====================================================
  List<Map<String, dynamic>> getPeminjamanByBarang(String barangId) {
    return peminjamanList.where((p) => p['barangId'] == barangId).toList();
  }

  // =====================================================
  // FILTER SEARCH
  // =====================================================
  List<Map<String, dynamic>> get filteredPeminjaman {
    if (search.value.isEmpty) return peminjamanList;

    return peminjamanList.where((p) {
      final namaAnggota = p['anggotaDetail']?['nama'] ?? '';
      final namaBarang = p['barangDetail']?['nama'] ?? '';
      final searchLower = search.value.toLowerCase();

      return namaAnggota.toString().toLowerCase().contains(searchLower) ||
          namaBarang.toString().toLowerCase().contains(searchLower);
    }).toList();
  }

  // =====================================================
  // CLEAR FORM
  // =====================================================
  void clearForm() {
    anggotaIdC.clear();
    barangIdC.clear();
    jumlahC.clear();
    kondisiSaatPinjamC.clear();
    tanggalRencanaKembaliC.clear();
    catatanC.clear();
    statusC.clear();
    selectedAnggota.value = null;
    selectedBarang.value = null;
  }

  // =====================================================
  // Validasi Form
  // =====================================================
  void validateForm(
    String anggotaId,
    String barangId,
    String jumlah,
    String kondisiSaatPinjam,
    String tanggalRencanaKembali,
  ) {
    isFormValid.value =
        anggotaId.isNotEmpty &&
        barangId.isNotEmpty &&
        jumlah.isNotEmpty &&
        kondisiSaatPinjam.isNotEmpty &&
        tanggalRencanaKembali.isNotEmpty;
  }
}
