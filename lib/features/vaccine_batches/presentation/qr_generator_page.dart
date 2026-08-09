import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/batch_model.dart';

class QRGeneratorPage extends StatelessWidget {
  final BatchModel batch;

  const QRGeneratorPage({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    final qrData =
        '''
Batch ID: ${batch.id}
Vaccine: ${batch.vaccineName}
Batch No: ${batch.batchNumber}
Manufacturer: ${batch.manufacturer}
Quantity: ${batch.quantity}
Location: ${batch.location}
Expiry Date: ${batch.expiryDate}
Storage: ${batch.storageTemperature}
''';

    return Scaffold(
      appBar: AppBar(title: const Text("Batch QR Code"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 250,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              batch.vaccineName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              batch.batchNumber,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("Manufacturer"),
              subtitle: Text(batch.manufacturer),
            ),

            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Quantity"),
              subtitle: Text("${batch.quantity} doses"),
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Location"),
              subtitle: Text(batch.location),
            ),

            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("Expiry Date"),
              subtitle: Text(batch.expiryDate),
            ),

            ListTile(
              leading: const Icon(Icons.ac_unit),
              title: const Text("Storage"),
              subtitle: Text(batch.storageTemperature),
            ),
          ],
        ),
      ),
    );
  }
}
