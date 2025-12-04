import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../helper/format_tanggal.dart';
import '../../../widgets/export_dialog.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/barang_controller.dart';

class BarangView extends GetView<BarangController> {
  BarangView({super.key});
  final authC = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 110,
          right: 24,
          top: 24,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================
            //            HEADER ROW
            // ================================
            Row(
              children: [
                // SEARCH FIELD
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari Barang...",
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (v) => controller.search.value = v,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // EXPORT BUTTON
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ExportDialog(
                        title: "Barang",
                        onExport: (format) {
                          controller.handleExport(format);
                        },
                      ),
                    );
                  },

                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text(
                    "Export",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(width: 12),
                if (authC.userRole.value == "admin" ||
                    authC.userRole.value == "inventaris")
                  // TOMBOL TAMBAH BARANG
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
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
                      "Tambah",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            // ================================
            //                TABLE
            // ================================
            Expanded(
              child: Obx(() {
                final filteredData = controller.filteredBarang;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.04),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DataTable2(
                    minWidth: 950,
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    headingRowColor: WidgetStateProperty.all(
                      Colors.grey.shade200,
                    ),
                    dataRowColor: WidgetStateProperty.all(Colors.white),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    columns: [
                      const DataColumn(label: Text("Nama Barang")),
                      const DataColumn(label: Text("Update")),
                      const DataColumn(label: Text("Kategori")),
                      const DataColumn(label: Text("Lokasi")),
                      const DataColumn(label: Text("Stok")),
                      const DataColumn(label: Text("Kondisi")),
                      if (authC.userRole.value == "admin" ||
                          authC.userRole.value == "inventaris")
                        const DataColumn(label: Text("Aksi")),
                    ],
                    rows: filteredData.map((data) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(data['nama'], overflow: TextOverflow.ellipsis),
                          ),
                          DataCell(Text(formatTanggal(data['update']))),
                          DataCell(kategoriBadge(data['kategori'])),
                          DataCell(Text(data['lokasi'] ?? "-")),
                          DataCell(
                            Text(
                              "${controller.getStokAsInt(data)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: controller.getStokAsInt(data) <= 5
                                    ? Colors.red
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                          DataCell(kondisiBadge(data['kondisi'])),
                          if (authC.userRole.value == "admin" ||
                              authC.userRole.value == "inventaris")
                            DataCell(
                              Row(
                                children: [
                                  Tooltip(
                                    message: "Edit",
                                    child: IconButton(
                                      icon: const Icon(
                                        CupertinoIcons.pencil,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        final row = data;
                                        controller.namaC.text =
                                            row['nama'] ?? '';
                                        controller.kategoriC.text =
                                            row['kategori'] ?? '';
                                        controller.lokasiC.text =
                                            row['lokasi'] ?? '';
                                        controller.stokC.text = row['stok']
                                            .toString();
                                        controller.kondisiC.text =
                                            row['kondisi'] ?? '';
                                        controller.catatanC.text =
                                            row['catatan'] ?? '';

                                        Get.dialog(
                                          editBarangDialog(data['id']),
                                        );
                                      },
                                    ),
                                  ),
                                  if (authC.userRole.value == "admin")
                                    Tooltip(
                                      message: "Hapus",
                                      child: IconButton(
                                        icon: const Icon(
                                          CupertinoIcons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          Get.defaultDialog(
                                            title: "Hapus Barang?",
                                            middleText:
                                                "Yakin ingin menghapus barang ini?",
                                            textConfirm: "Hapus",
                                            textCancel: "Batal",
                                            onConfirm: () {
                                              controller.deleteBarang(
                                                data['id'],
                                              );
                                              Get.back();
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  //            BADGES
  // ===============================

  Widget kategoriBadge(String? kategori) {
    kategori = kategori?.toLowerCase() ?? "unknown";

    final colors = {
      "microcontroller": Colors.greenAccent.shade700,
      "sensor": Colors.orange.shade700,
      "actuator": Colors.red.shade400,
      "robot_kit": Colors.blue.shade700,
      "perlengkapan_lain": Colors.purple.shade700,
    };

    final labels = {
      "microcontroller": "Microcontroller",
      "sensor": "Sensor",
      "actuator": "Actuator",
      "robot_kit": "Robot Kit",
      "perlengkapan_lain": "Perlengkapan Lain",
      "unknown": "Tidak Ada",
    };

    final color = colors[kategori] ?? Colors.grey; // fallback aman

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[kategori] ?? kategori,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  Widget kondisiBadge(String kondisi) {
    final colors = {
      "baik": Colors.green.shade600,
      "cukup": Colors.orange.shade600,
      "rusak_ringan": Colors.red.shade400,
      "rusak_berat": Colors.red.shade800,
    };

    final labels = {
      "baik": "Baik",
      "cukup": "Cukup",
      "rusak_ringan": "Rusak Ringan",
      "rusak_berat": "Rusak Berat",
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: colors[kondisi]!.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[kondisi] ?? kondisi,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: colors[kondisi],
        ),
      ),
    );
  }

  // ===============================
  //      EDIT BARANG DIALOG
  // ===============================

  Widget editBarangDialog(String id) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Edit Barang",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildInput(controller.namaC, "Nama Barang"),
            buildDropdownKategori(),
            buildInput(controller.lokasiC, "Lokasi"),
            buildInput(controller.stokC, "Stok", number: true),
            buildDropdownKondisi(),
            buildInput(controller.catatanC, "Catatan", multi: true),
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

  Widget buildInput(
    TextEditingController c,
    String label, {
    bool number = false,
    bool multi = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: multi ? 3 : 1,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDropdownKategori() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: controller.kategoriC.text,
        decoration: const InputDecoration(
          labelText: "Kategori",
          border: OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(
            value: 'microcontroller',
            child: Text('Microcontroller'),
          ),
          DropdownMenuItem(value: 'sensor', child: Text('Sensor')),
          DropdownMenuItem(value: 'actuator', child: Text('Actuator')),
          DropdownMenuItem(value: 'robot_kit', child: Text('Robot Kit')),
          DropdownMenuItem(
            value: 'perlengkapan_lain',
            child: Text('Perlengkapan Lain'),
          ),
        ],
        onChanged: (value) {
          if (value != null) controller.kategoriC.text = value;
        },
      ),
    );
  }

  Widget buildDropdownKondisi() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: controller.kondisiC.text,
        decoration: const InputDecoration(
          labelText: "Kondisi",
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'baik', child: Text('Baik')),
          DropdownMenuItem(value: 'cukup', child: Text('Cukup')),
          DropdownMenuItem(value: 'rusak_ringan', child: Text('Rusak Ringan')),
          DropdownMenuItem(value: 'rusak_berat', child: Text('Rusak Berat')),
        ],
        onChanged: (value) {
          if (value != null) controller.kondisiC.text = value;
        },
      ),
    );
  }
}
