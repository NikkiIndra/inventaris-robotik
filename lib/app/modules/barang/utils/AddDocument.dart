import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventaris_robotik/app/modules/barang/controllers/barang_controller.dart';

class AddBarang extends StatelessWidget {
  AddBarang({super.key});
  final controller = Get.find<BarangController>();

  @override
  Widget build(BuildContext context) {
    // Set default value untuk dropdown jika kosong
    if (controller.kategoriC.text.isEmpty) {
      controller.kategoriC.text = 'microcontroller';
    }
    if (controller.kondisiC.text.isEmpty) {
      controller.kondisiC.text = 'baik';
    }

    return AlertDialog(
      title: const Text("Tambah Barang"),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: controller.namaC, // Gunakan controller dari BarangController
                decoration: const InputDecoration(labelText: "Nama Barang"),
                onChanged: (_) => controller.validateForm(
                  controller.namaC.text,
                  controller.kategoriC.text,
                  controller.lokasiC.text,
                  controller.stokC.text,
                  controller.kondisiC.text,
                  controller.catatanC.text,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // DROPDOWN KATEGORI
              DropdownButtonFormField<String>(
                value: controller.kategoriC.text, // Pastikan ini ada di items list
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'microcontroller',
                    child: Text('Microcontroller'),
                  ),
                  DropdownMenuItem(value: 'sensor', child: Text('Sensor')),
                  DropdownMenuItem(value: 'actuator', child: Text('Actuator')),
                  DropdownMenuItem(
                    value: 'robot_kit',
                    child: Text('Robot Kit'),
                  ),
                  DropdownMenuItem(
                    value: 'perlengkapan_lain',
                    child: Text('Perlengkapan Lain'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.kategoriC.text = value; // PERBAIKAN: kategoriC, BUKAN kondisiC
                    controller.validateForm(
                      controller.namaC.text,
                      controller.kategoriC.text,
                      controller.lokasiC.text,
                      controller.stokC.text,
                      controller.kondisiC.text,
                      controller.catatanC.text,
                    );
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              TextField(
                controller: controller.lokasiC,
                decoration: const InputDecoration(labelText: "Lokasi"),
                onChanged: (_) => controller.validateForm(
                  controller.namaC.text,
                  controller.kategoriC.text,
                  controller.lokasiC.text,
                  controller.stokC.text,
                  controller.kondisiC.text,
                  controller.catatanC.text,
                ),
              ),
              
              const SizedBox(height: 12),
              
              TextField(
                controller: controller.stokC,
                decoration: const InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
                onChanged: (_) => controller.validateForm(
                  controller.namaC.text,
                  controller.kategoriC.text,
                  controller.lokasiC.text,
                  controller.stokC.text,
                  controller.kondisiC.text,
                  controller.catatanC.text,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // DROPDOWN KONDISI
              DropdownButtonFormField<String>(
                value: controller.kondisiC.text, // Pastikan ini ada di items list
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
                  if (value != null) {
                    controller.kondisiC.text = value;
                    controller.validateForm(
                      controller.namaC.text,
                      controller.kategoriC.text,
                      controller.lokasiC.text,
                      controller.stokC.text,
                      controller.kondisiC.text,
                      controller.catatanC.text,
                    );
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
                onChanged: (_) => controller.validateForm(
                  controller.namaC.text,
                  controller.kategoriC.text,
                  controller.lokasiC.text,
                  controller.stokC.text,
                  controller.kondisiC.text,
                  controller.catatanC.text,
                ),
              ),
            ],
          ),
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
        Obx(
          () => ElevatedButton(
            onPressed: controller.isFormValid.value
                ? () async {
                    await controller.saveBarang(
                      nama: controller.namaC.text,
                      kategori: controller.kategoriC.text,
                      lokasi: controller.lokasiC.text,
                      stok: controller.stokC.text,
                      kondisi: controller.kondisiC.text,
                      catatan: controller.catatanC.text,
                    );
                    Get.back();
                  }
                : null,
            child: const Text("Simpan"),
          ),
        ),
      ],
    );
  }
}