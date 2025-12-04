import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/format_tanggal.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/anggota_controller.dart';

class AnggotaView extends GetView<AnggotaController> {
  AnggotaView({super.key});
  final authC = Get.put(LoginController());
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
                      hintText: "Cari Anggota",
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
                if (authC.userRole.value == "admin" ||
                    authC.userRole.value == "inventaris")
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Get.dialog(openAddAnggotaDialog());
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Tambah Anggota",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // TABLE ANGGOTA
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("anggota")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // Update list ke controller
                controller.anggotaList.value = docs.map((d) {
                  return {
                    "id": d.id,
                    "nama": d["nama"],
                    "kontak": d["kontak"],
                    "divisi": d["divisi"],
                    "status": d["status"],
                    "tanggalDaftar": d["tanggalDaftar"],
                    "update": d["update"],
                  };
                }).toList();

                return Expanded(
                  child: Obx(() {
                    return DataTable2(
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey[200],
                      ),
                      dataRowColor: WidgetStateProperty.all(
                        const Color(0xFFF4EEFA),
                      ),
                      minWidth: 1200,
                      columns: [
                        DataColumn(label: Text("Nama")),
                        DataColumn(label: Text("Kontak")),
                        DataColumn(label: Text("Divisi/Bagian")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Tanggal Daftar")),
                        DataColumn(label: Text("Update")),
                        if (authC.userRole.value == "admin" ||
                            authC.userRole.value == "inventaris")
                          DataColumn(label: Text("Aksi")),
                      ],
                      rows: controller.filteredAnggota.map((e) {
                        final isAdmin = authC.userRole.value == "admin";
                        final isInventaris =
                            authC.userRole.value == "inventaris";

                        return DataRow(
                          cells: [
                            DataCell(Text(e['nama'])),
                            DataCell(Text(e['kontak'])),
                            DataCell(Text(e['divisi'] ?? '-')),
                            DataCell(statusBadge(e['status'])),
                            DataCell(Text(formatTanggal(e['tanggalDaftar']))),
                            DataCell(
                              Text(
                                e['update'] == null
                                    ? "-"
                                    : formatTanggal(e['update']),
                              ),
                            ),

                            // === TAMBAHKAN DATA CELL AKSI HANYA UNTUK ADMIN & INVENTARIS ===
                            if (isAdmin || isInventaris)
                              DataCell(
                                Row(
                                  children: [
                                    // EDIT
                                    if (isAdmin || isInventaris)
                                      GestureDetector(
                                        onTap: () {
                                          controller.namaC.text = e['nama'];
                                          controller.kontakC.text = e['kontak'];
                                          controller.divisiC.text =
                                              e['divisi'] ?? '';
                                          controller.statusC.text = e['status'];
                                          Get.dialog(
                                            editAnggotaDialog(e['id']),
                                          );
                                        },
                                        child: Tooltip(
                                          message: "Edit Anggota",
                                          child: const Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    // DELETE hanya admin
                                    if (isAdmin)
                                      GestureDetector(
                                        onTap: () {
                                          Get.defaultDialog(
                                            title: "Hapus Anggota?",
                                            middleText:
                                                "Yakin ingin menghapus anggota ini?",
                                            onConfirm: () {
                                              controller.deleteAnggota(e['id']);
                                              Get.back();
                                            },
                                            textConfirm: "Hapus",
                                            textCancel: "Batal",
                                          );
                                        },

                                        child: Tooltip(
                                          message: "Hapus Anggota",
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG EDIT ANGGOTA
  Widget editAnggotaDialog(String id) {
    return AlertDialog(
      title: const Text("Edit Anggota"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.namaC,
              decoration: const InputDecoration(labelText: "Nama Lengkap"),
            ),
            TextField(
              controller: controller.kontakC,
              decoration: const InputDecoration(labelText: "Nomor Kontak/WA"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: controller.divisiC,
              decoration: const InputDecoration(
                labelText: "Divisi/Kelas/Bagian (Opsional)",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: controller.statusC.text.isNotEmpty
                  ? controller.statusC.text
                  : 'aktif',
              items: const [
                DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                DropdownMenuItem(value: 'diblokir', child: Text('Diblokir')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.statusC.text = value;
                }
              },
              decoration: const InputDecoration(labelText: "Status"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () async {
            if (controller.namaC.text.isEmpty ||
                controller.kontakC.text.isEmpty) {
              Get.snackbar("Error", "Nama dan Kontak wajib diisi");
              return;
            }

            await controller.updateAnggota(id);
            controller.clearForm();
            Get.back();
          },
          child: const Text("Update"),
        ),
      ],
    );
  }

  // DIALOG TAMBAH ANGGOTA
  Widget openAddAnggotaDialog() {
    return AlertDialog(
      title: const Text("Tambah Anggota"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.namaC,
              decoration: const InputDecoration(labelText: "Nama Lengkap"),
            ),
            TextField(
              controller: controller.kontakC,
              decoration: const InputDecoration(labelText: "Nomor Kontak/WA"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: controller.divisiC,
              decoration: const InputDecoration(
                labelText: "Divisi/Kelas/Bagian (Opsional)",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: 'aktif',
              items: const [
                DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                DropdownMenuItem(value: 'diblokir', child: Text('Diblokir')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.statusC.text = value;
                }
              },
              decoration: const InputDecoration(labelText: "Status"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () {
            if (controller.namaC.text.isEmpty ||
                controller.kontakC.text.isEmpty) {
              Get.snackbar("Error", "Nama dan Kontak wajib diisi");
              return;
            }

            FirebaseFirestore.instance.collection("anggota").add({
              "nama": controller.namaC.text,
              "kontak": controller.kontakC.text,
              "divisi": controller.divisiC.text,
              "status": controller.statusC.text.isEmpty
                  ? 'aktif'
                  : controller.statusC.text,
              "tanggalDaftar": DateTime.now().toIso8601String(),
              "update": DateTime.now().toIso8601String(),
            });
            controller.clearForm();
            Get.back();
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }

  // WIDGET STATUS BADGE
  Widget statusBadge(String status) {
    Color bgColor;
    String statusText;

    if (status == "aktif") {
      bgColor = Colors.greenAccent;
      statusText = "Aktif";
    } else if (status == "nonaktif") {
      bgColor = Colors.orangeAccent;
      statusText = "Nonaktif";
    } else if (status == "diblokir") {
      bgColor = Colors.redAccent;
      statusText = "Diblokir";
    } else {
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
}
