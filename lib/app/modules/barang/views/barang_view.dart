import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../helper/format_tanggal.dart';
import '../controllers/barang_controller.dart';

class BarangView extends GetView<BarangController> {
  const BarangView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 110,
          right: 24,
          top: 24,
          bottom: 24,
        ),
        child: Column(
          children: [
            // SEARCH + BUTTONS
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari Barang",
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

                SizedBox(width: 12),

                // TOMBOL TAMBAH BARANG
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => controller.openAddBarangDialog(),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Tambah Barang",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // TABLE BARANG
            Expanded(
              child: Obx(() {
                return DataTable2(
                  minWidth: 900,
                  columnSpacing: 24,
                  horizontalMargin: 12,
                  headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                  dataRowColor: WidgetStateProperty.all(
                    Colors.purple.shade50, // ungu pastel
                  ),
                  columns: const [
                    DataColumn(label: Text("Nama Barang")),
                    DataColumn(label: Text("Update")),
                    DataColumn(label: Text("Kategori")),
                    DataColumn(label: Text("Lokasi")),
                    DataColumn(label: Text("Stok")),
                    DataColumn(label: Text("Kondisi")),
                    DataColumn(label: Text("Aksi")),
                  ],
                  rows: controller.filteredBarang.map((data) {
                    return DataRow(
                      cells: [
                        // NAMA BARANG (ellipsis + tooltip)
                        DataCell(
                          Tooltip(
                            message: data['nama'],
                            child: Text(
                              data['nama'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // UPDATE
                        DataCell(Text(formatTanggal(data['update']))),

                        // KATEGORI
                        DataCell(
                          kategoriBadge(data['kategori'] ?? 'microcontroller'),
                        ),

                        // LOKASI
                        DataCell(Text("${data['lokasi'] ?? ''}")),

                        // STOK
                        DataCell(
                          Text(
                            "${controller.getStokAsInt(data)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.getStokAsInt(data) <= 5
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ),
                        // KONDISI - ganti dengan badge/warna berdasarkan teks
                        DataCell(kondisiBadge(data['kondisi'] ?? 'baik')),

                        // AKSI ICONS
                        DataCell(
                          Row(
                            children: [
                              // EDIT
                              IconButton(
                                onPressed: () {
                                  final rowData = data;
                                  controller.namaC.text = rowData['nama'] ?? '';
                                  controller.kategoriC.text =
                                      rowData['kategori'] ?? '';
                                  controller.lokasiC.text =
                                      rowData['lokasi'] ?? '';
                                  controller.stokC.text =
                                      rowData['stok']?.toString() ?? '';
                                  controller.kondisiC.text =
                                      rowData['kondisi'] ?? '';
                                  controller.catatanC.text =
                                      rowData['catatan'] ?? '';

                                  // Panggil dialog edit
                                  Get.dialog(editBarangDialog(data['id']));
                                },
                                icon: Tooltip(
                                  message: "Edit Barang",
                                  child: const Icon(
                                    CupertinoIcons.pencil,
                                    size: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // DELETE
                              IconButton(
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: "Hapus Barang?",
                                    middleText:
                                        "Yakin ingin menghapus barang ini?",
                                    textConfirm: "Hapus",
                                    textCancel: "Batal",
                                    onConfirm: () {
                                      controller.deleteBarang(data['id']);
                                      Get.back();
                                    },
                                  );
                                },
                                icon: Tooltip(
                                  message: "Hapus Barang",
                                  child: const Icon(
                                    CupertinoIcons.delete,
                                    size: 20,
                                    color: Colors.red,
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

  // Fungsi untuk menampilkan badge kondisi
  Widget kategoriBadge(String kategori) {
    Color bgColor;
    String kategoriText;

    switch (kategori.toLowerCase()) {
      case 'microcontroller':
        bgColor = Colors.greenAccent;
        kategoriText = "microcontroller";
        break;
      case 'sensor':
        bgColor = Colors.orangeAccent;
        kategoriText = "sensor";
        break;
      case 'actuator':
        bgColor = Colors.redAccent.withOpacity(0.7);
        kategoriText = "actuator";
        break;
      case 'robot_kit':
        bgColor = Colors.redAccent;
        kategoriText = "Robot Kit";
        break;
      default:
        bgColor = Colors.grey;
        kategoriText = kategori;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kategoriText,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  // Fungsi untuk menampilkan badge kondisi
  Widget kondisiBadge(String kondisi) {
    Color bgColor;
    String kondisiText;

    switch (kondisi.toLowerCase()) {
      case 'baik':
        bgColor = Colors.greenAccent;
        kondisiText = "Baik";
        break;
      case 'cukup':
        bgColor = Colors.orangeAccent;
        kondisiText = "Cukup";
        break;
      case 'rusak_ringan':
        bgColor = Colors.redAccent.withOpacity(0.7);
        kondisiText = "Rusak Ringan";
        break;
      case 'rusak_berat':
        bgColor = Colors.redAccent;
        kondisiText = "Rusak Berat";
        break;
      default:
        bgColor = Colors.grey;
        kondisiText = kondisi;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kondisiText,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  // DIALOG EDIT BARANG
  // DIALOG EDIT BARANG
  Widget editBarangDialog(String id) {
    return AlertDialog(
      title: const Text("Edit Barang"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.namaC,
              decoration: const InputDecoration(labelText: "Nama Barang"),
            ),
            TextField(
              controller: controller.kategoriC,
              decoration: const InputDecoration(labelText: "Kategori"),
            ),
            TextField(
              controller: controller.lokasiC,
              decoration: const InputDecoration(labelText: "Lokasi"),
            ),
            TextField(
              controller: controller.stokC,
              decoration: const InputDecoration(labelText: "Stok"),
              keyboardType: TextInputType.number,
            ),

            // DROPDOWN KONDISI
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: controller.kondisiC.text.isNotEmpty
                  ? controller.kondisiC.text
                  : 'baik',
              decoration: const InputDecoration(
                labelText: "Kondisi",
                border: OutlineInputBorder(),
              ),
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
                  controller.kondisiC.text = value;
                }
              },
            ),

            const SizedBox(height: 12),
            TextField(
              controller: controller.catatanC,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Catatan",
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            await controller.updateBarang(id);
            Get.back();
          },
          child: const Text("Update"),
        ),
      ],
    );
  }
}
