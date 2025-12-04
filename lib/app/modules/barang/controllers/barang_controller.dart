import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../service/export_service.dart';
import '../utils/AddDocument.dart';

class BarangController extends GetxController {
  final search = ''.obs;
  final isLoading = false.obs;
  final namaC = TextEditingController();
  final kategoriC = TextEditingController(text: 'microcontroller');
  final lokasiC = TextEditingController(text: 'rak 1');
  final stokC = TextEditingController();
  final kondisiC = TextEditingController(text: 'baik');
  final catatanC = TextEditingController();
  final isFormValid = false.obs;
  final barangList = <Map<String, dynamic>>[].obs;
  final _searchQuery = ''.obs;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final ExportService exportService = ExportService();
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

  // Configuration for export
  final List<String> _headers = [
    'Nama Barang',
    'Kategori',
    'Lokasi',
    'Stok',
    'Kondisi',
    'Catatan',
    'Tanggal Update',
  ];

  final List<String> _fields = [
    'nama',
    'kategori',
    'lokasi',
    'stok',
    'kondisi',
    'catatan',
    'update',
  ];

  @override
  void onInit() {
    super.onInit();
    loadBarang();
  }

  // =====================================================
  // EXPORT FUNCTIONALITY
  // =====================================================
  void showExportDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Export Data Barang'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFormatSelector(),
              SizedBox(height: 20),
              _buildDateRangeSelector(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Batal')),
          ElevatedButton(
            onPressed: () => _handleExport(format: 'excel'),
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    final selectedFormat = 'excel'.obs; // Default Excel

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Format Export:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Excel (.xlsx)'),
                  value: 'excel',
                  groupValue: selectedFormat.value,
                  onChanged: (value) => selectedFormat.value = value!,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('PDF (.pdf)'),
                  value: 'pdf',
                  groupValue: selectedFormat.value,
                  onChanged: (value) => selectedFormat.value = value!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final exportAll = true.obs;
    final startDate = Rx<DateTime?>(null);
    final endDate = Rx<DateTime?>(null);

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: Text('Semua Data'),
                  value: true,
                  groupValue: exportAll.value,
                  onChanged: (value) {
                    exportAll.value = value!;
                    startDate.value = null;
                    endDate.value = null;
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: Text('Rentang Tanggal'),
                  value: false,
                  groupValue: exportAll.value,
                  onChanged: (value) => exportAll.value = value!,
                ),
              ),
            ],
          ),

          if (!exportAll.value) ...[
            SizedBox(height: 10),
            Container(
              height: 200,
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    final range = args.value as PickerDateRange;
                    startDate.value = range.startDate;
                    endDate.value = range.endDate;
                  }
                },
                minDate: DateTime(2020),
                maxDate: DateTime.now(),
                initialSelectedRange: PickerDateRange(
                  DateTime.now().subtract(Duration(days: 30)),
                  DateTime.now(),
                ),
              ),
            ),
            SizedBox(height: 10),
            if (startDate.value != null && endDate.value != null)
              Text(
                'Dipilih: ${_dateFormat.format(startDate.value!)} - '
                '${_dateFormat.format(endDate.value!)}',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> exportBarang({
    required DateTime? startDate,
    required DateTime? endDate,
    required String format,
  }) async {
    List<Map<String, dynamic>> data = barangList;

    // Jika filter tanggal
    if (startDate != null && endDate != null) {
      data = data.where((item) {
        final tgl = DateTime.tryParse(item['update'] ?? '');
        if (tgl == null) return false;
        return tgl.isAfter(startDate) && tgl.isBefore(endDate);
      }).toList();
    }

    if (format == 'excel') {
      await exportService.exportToXlsx(
        title: 'Data Barang',
        data: data,
        headers: _headers,
        fields: _fields,
      );
    } else {
      // PDF belum dibuat
      print("Export PDF belum dibuat");
    }
  }

  Future<void> _handleExport({required String format}) async {
    try {
      // Show loading
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Menyiapkan export...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Get data
      List<Map<String, dynamic>> dataToExport = filteredBarang;

      // Export berdasarkan format
      if (format == 'excel') {
        await exportService.exportToXlsx(
          title: 'Data Barang',
          data: dataToExport,
          headers: _headers,
          fields: _fields,
        );
      } else {
        await exportService.exportToPdf(
          title: 'Data Barang',
          data: dataToExport,
          headers: _headers,
          fields: _fields,
        );
      }

      // Close loading
      Get.back();

      // Show success
    } catch (e) {
      Get.back();
    }
  }

  void handleExport(String format) async {
    final data = barangList; // semua data barang yang sudah ada di controller

    if (format == 'excel') {
      await exportService.exportToXlsx(
        title: "Data Barang",
        headers: ["Nama", "Kategori", "Lokasi", "Stok", "Kondisi", "Update"],
        fields: ["nama", "kategori", "lokasi", "stok", "kondisi", "update"],
        data: data,
      );
    } else if (format == 'pdf') {
      await exportService.exportToPdf(
        title: "Data Barang",
        headers: ["Nama", "Kategori", "Lokasi", "Stok", "Kondisi", "Update"],
        fields: ["nama", "kategori", "lokasi", "stok", "kondisi", "update"],
        data: data,
      );
    }

    Get.snackbar("Export", "Export berhasil ($format)");
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
      final list = snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data["id"] = d.id;
        return data;
      }).toList();

      // ========== SORT BERDASARKAN KATEGORI LIST ==========

      list.sort((a, b) {
        int indexA = kategoriList.indexOf(a["kategori"]);
        int indexB = kategoriList.indexOf(b["kategori"]);

        // Jika kategori tidak ada di daftar, letakkan di paling belakang
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;

        return indexA.compareTo(indexB);
      });

      barangList.value = list;
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
    kategoriC.text = 'microcontroller';
    lokasiC.clear();
    stokC.clear();
    kondisiC.text = 'baik';
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
