import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/format_tanggal.dart';
import '../../anggota/controllers/anggota_controller.dart';
import '../../barang/controllers/barang_controller.dart';
import '../controllers/peminjaman_controller.dart';

class PeminjamanView extends GetView<PeminjamanController> {
  PeminjamanView({super.key});

  late final AnggotaController anggotaC = Get.find();
  late final BarangController barangC = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 100,
          right: 24,
          top: 24,
          bottom: 24,
        ),
        child: Column(
          children: [
            // SEARCH + BUTTON
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari Peminjaman (Nama Anggota/Barang)",
                      suffixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 24,
                        right: 50,
                        top: 0,
                        bottom: 0,
                      ),
                      isDense: true,
                    ),
                    onChanged: (v) => controller.search.value = v,
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Get.dialog(openAddPeminjamanDialog());
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Tambah Peminjaman",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // TABLE PEMINJAMAN
            Expanded(
              child: Obx(() {
                return DataTable2(
                  columnSpacing: 24,
                  horizontalMargin: 12,
                  headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                  dataRowColor: WidgetStateProperty.all(
                    const Color(0xFFF4EEFA),
                  ),
                  minWidth: 1500,
                  columns: const [
                    DataColumn(label: Text("Anggota")),
                    DataColumn(label: Text("Barang")),
                    DataColumn(label: Text("Jumlah")),
                    DataColumn(label: Text("Tanggal Pinjam")),
                    DataColumn(label: Text("Rencana Kembali")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Aksi")),
                  ],
                  rows: controller.filteredPeminjaman.map((e) {
                    final anggotaNama =
                        e['anggotaDetail']?['nama'] ?? 'Tidak Diketahui';
                    final barangNama =
                        e['barangDetail']?['nama'] ?? 'Tidak Diketahui';
                    final status = e['status'];

                    return DataRow(
                      cells: [
                        // ANGGOTA
                        DataCell(
                          Tooltip(
                            message: anggotaNama,
                            child: Text(
                              anggotaNama,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // BARANG
                        DataCell(
                          Tooltip(
                            message: barangNama,
                            child: Text(
                              barangNama,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // JUMLAH
                        DataCell(
                          Text(
                            "${e['jumlah']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        // TANGGAL PINJAM
                        DataCell(Text(formatTanggal(e['tanggalPinjam']))),

                        // RENCANA KEMBALI
                        DataCell(
                          Text(
                            formatTanggal(e['tanggalRencanaKembali']),
                            style: TextStyle(
                              color: isTelat(e['tanggalRencanaKembali'], status)
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // STATUS
                        DataCell(statusBadgePeminjaman(status)),

                        // AKSI
                        DataCell(
                          Row(
                            children: [
                              // EDIT / UPDATE STATUS
                              GestureDetector(
                                onTap: () {
                                  if (status == 'dipinjam') {
                                    Get.dialog(
                                      updatePengembalianDialog(e['id']),
                                    );
                                  } else {
                                    Get.dialog(detailPeminjamanDialog(e));
                                  }
                                },
                                child: Tooltip(
                                  message: status == 'dipinjam'
                                      ? "Update Pengembalian"
                                      : "Detail Peminjaman",
                                  child: Icon(
                                    status == 'dipinjam'
                                        ? Icons.check_circle
                                        : Icons.info,
                                    size: 20,
                                    color: status == 'dipinjam'
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG TAMBAH PEMINJAMAN
  Widget openAddPeminjamanDialog() {
    return AlertDialog(
      title: const Text("Tambah Peminjaman"),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                          // PILIH ANGGOTA
            Obx(() {
              final List<Map<String, dynamic>> anggotaAktif = anggotaC.anggotaAktif;
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Pilih Anggota",
                  border: OutlineInputBorder(),
                ),
                value: controller.anggotaIdC.text.isNotEmpty 
                    ? controller.anggotaIdC.text 
                    : null,
                items: anggotaAktif.map<DropdownMenuItem<String>>((anggota) {
                  return DropdownMenuItem<String>(
                    value: anggota['id'] as String,
                    child: Text(
                      "${anggota['nama']}${anggota['divisi'] != null && anggota['divisi'].toString().isNotEmpty ? ' - ${anggota['divisi']}' : ''}",
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.anggotaIdC.text = value;
                    final selected = anggotaAktif.firstWhere(
                      (a) => a['id'] == value,
                      orElse: () => <String, dynamic>{},
                    );
                    controller.selectedAnggota.value = selected;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih anggota terlebih dahulu';
                  }
                  return null;
                },
              );
            }),

              const SizedBox(height: 16),

              // PILIH BARANG
            Obx(() {
              final List<Map<String, dynamic>> barangTersedia = barangC.barangList.where(
                (barang) => (barang['stok'] ?? 0) > 0
              ).toList();
              
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Pilih Barang",
                  border: OutlineInputBorder(),
                ),
                value: controller.barangIdC.text.isNotEmpty 
                    ? controller.barangIdC.text 
                    : null,
                items: barangTersedia.map<DropdownMenuItem<String>>((barang) {
                  final stok = barang['stok'] ?? 0;
                  return DropdownMenuItem<String>(
                    value: barang['id'] as String,
                    child: Text("${barang['nama']} (Stok: $stok)"),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.barangIdC.text = value;
                    final selected = barangTersedia.firstWhere(
                      (b) => b['id'] == value,
                      orElse: () => <String, dynamic>{},
                    );
                    controller.selectedBarang.value = selected;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih barang terlebih dahulu';
                  }
                  return null;
                },
              );
            }),

              const SizedBox(height: 16),

              // JUMLAH
              TextField(
                controller: controller.jumlahC,
                decoration: const InputDecoration(
                  labelText: "Jumlah",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // KONDISI SAAT PINJAM
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Kondisi Saat Pinjam",
                  border: OutlineInputBorder(),
                ),
                value: controller.kondisiSaatPinjamC.text.isNotEmpty
                    ? controller.kondisiSaatPinjamC.text
                    : 'baik',
                items: const [
                  DropdownMenuItem(value: 'baik', child: Text('Baik')),
                  DropdownMenuItem(value: 'cukup', child: Text('Cukup')),
                  DropdownMenuItem(
                    value: 'rusak_ringan',
                    child: Text('Rusak Ringan'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.kondisiSaatPinjamC.text = value;
                  }
                },
              ),

              const SizedBox(height: 16),

              // TANGGAL RENCANA KEMBALI
              TextField(
                controller: controller.tanggalRencanaKembaliC,
                decoration: const InputDecoration(
                  labelText: "Tanggal Rencana Kembali (YYYY-MM-DD)",
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    controller.tanggalRencanaKembaliC.text =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                },
              ),

              const SizedBox(height: 16),

              // CATATAN
              TextField(
                controller: controller.catatanC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Catatan (Opsional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () async {
            if (controller.anggotaIdC.text.isEmpty ||
                controller.barangIdC.text.isEmpty ||
                controller.jumlahC.text.isEmpty) {
              Get.snackbar("Error", "Anggota, Barang, dan Jumlah wajib diisi");
              return;
            }

            try {
              final jumlah = int.tryParse(controller.jumlahC.text) ?? 0;
              final barang = barangC.barangList.firstWhere(
                (b) => b['id'] == controller.barangIdC.text,
                orElse: () => {},
              );

              if (barang.isEmpty) {
                Get.snackbar("Error", "Barang tidak ditemukan");
                return;
              }

              final stokTersedia = barang['stok'] ?? 0;
              if (jumlah > stokTersedia) {
                Get.snackbar(
                  "Error",
                  "Stok tidak mencukupi. Stok tersedia: $stokTersedia",
                );
                return;
              }

              final rencanaKembali = DateTime.parse(
                controller.tanggalRencanaKembaliC.text,
              );

              await controller.savePeminjaman(
                anggotaId: controller.anggotaIdC.text,
                barangId: controller.barangIdC.text,
                jumlah: jumlah,
                kondisiSaatPinjam: controller.kondisiSaatPinjamC.text,
                tanggalRencanaKembali: rencanaKembali,
                catatan: controller.catatanC.text,
                status: 'dipinjam',
              );

              controller.clearForm();
              Get.back();
            } catch (e) {
              Get.snackbar("Error", "Gagal menyimpan peminjaman: $e");
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }

  // DIALOG UPDATE PENGEMBALIAN
  Widget updatePengembalianDialog(String peminjamanId) {
    final kondisiSaatKembaliC = TextEditingController(text: 'baik');
    final statusC = TextEditingController(text: 'selesai');
    final catatanC = TextEditingController();

    return AlertDialog(
      title: const Text("Update Pengembalian"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // KONDISI SAAT KEMBALI
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Kondisi Saat Kembali",
                border: OutlineInputBorder(),
              ),
              value: 'baik',
              items: const [
                DropdownMenuItem(value: 'baik', child: Text('Baik')),
                DropdownMenuItem(value: 'cukup', child: Text('Cukup')),
                DropdownMenuItem(
                  value: 'rusak_ringan',
                  child: Text('Rusak Ringan'),
                ),
                DropdownMenuItem(
                  value: 'rusak_berat',
                  child: Text('Rusak Berat'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  kondisiSaatKembaliC.text = value;
                }
              },
            ),

            const SizedBox(height: 16),

            // STATUS
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Status Pengembalian",
                border: OutlineInputBorder(),
              ),
              value: 'selesai',
              items: const [
                DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                DropdownMenuItem(value: 'hilang', child: Text('Hilang')),
                DropdownMenuItem(value: 'rusak', child: Text('Rusak')),
              ],
              onChanged: (value) {
                if (value != null) {
                  statusC.text = value;
                }
              },
            ),

            const SizedBox(height: 16),

            // CATATAN TAMBAHAN
            TextField(
              controller: catatanC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Catatan Tambahan (Opsional)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () async {
            await controller.updatePengembalian(
              peminjamanId: peminjamanId,
              kondisiSaatKembali: kondisiSaatKembaliC.text,
              status: statusC.text,
              catatanTambahan: catatanC.text,
            );
            Get.back();
          },
          child: const Text("Simpan Pengembalian"),
        ),
      ],
    );
  }

  // DIALOG DETAIL PEMINJAMAN
  Widget detailPeminjamanDialog(Map<String, dynamic> data) {
    final anggotaNama = data['anggotaDetail']?['nama'] ?? 'Tidak Diketahui';
    final barangNama = data['barangDetail']?['nama'] ?? 'Tidak Diketahui';

    return AlertDialog(
      title: const Text("Detail Peminjaman"),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Anggota"),
                subtitle: Text(anggotaNama),
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text("Barang"),
                subtitle: Text(barangNama),
              ),
              ListTile(
                leading: const Icon(Icons.numbers),
                title: const Text("Jumlah"),
                subtitle: Text("${data['jumlah']}"),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text("Tanggal Pinjam"),
                subtitle: Text(formatTanggal(data['tanggalPinjam'])),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text("Rencana Kembali"),
                subtitle: Text(formatTanggal(data['tanggalRencanaKembali'])),
              ),
              if (data['tanggalKembali'] != null)
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text("Tanggal Kembali"),
                  subtitle: Text(formatTanggal(data['tanggalKembali'])),
                ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("Kondisi Saat Pinjam"),
                subtitle: Text(data['kondisiSaatPinjam'] ?? '-'),
              ),
              if (data['kondisiSaatKembali'] != null)
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("Kondisi Saat Kembali"),
                  subtitle: Text(data['kondisiSaatKembali'] ?? '-'),
                ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text("Status"),
                subtitle: Text(getStatusText(data['status'])),
              ),
              if (data['catatan'] != null &&
                  data['catatan'].toString().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text("Catatan"),
                  subtitle: Text(data['catatan']),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Tutup")),
      ],
    );
  }

  // WIDGET STATUS BADGE PEMINJAMAN
  Widget statusBadgePeminjaman(String status) {
    Color bgColor;
    String statusText;

    switch (status) {
      case 'dipinjam':
        bgColor = Colors.blueAccent;
        statusText = "Dipinjam";
        break;
      case 'selesai':
        bgColor = Colors.greenAccent;
        statusText = "Selesai";
        break;
      case 'hilang':
        bgColor = Colors.redAccent;
        statusText = "Hilang";
        break;
      case 'rusak':
        bgColor = Colors.orangeAccent;
        statusText = "Rusak";
        break;
      default:
        bgColor = Colors.grey;
        statusText = "Tidak Diketahui";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  // HELPER FUNCTIONS
  bool isTelat(String tanggalRencanaKembali, String status) {
    if (status != 'dipinjam') return false;

    try {
      final rencana = DateTime.parse(tanggalRencanaKembali);
      final sekarang = DateTime.now();
      return sekarang.isAfter(rencana);
    } catch (e) {
      return false;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'dipinjam':
        return 'Dipinjam';
      case 'selesai':
        return 'Selesai';
      case 'hilang':
        return 'Hilang';
      case 'rusak':
        return 'Rusak';
      default:
        return status;
    }
  }
}
