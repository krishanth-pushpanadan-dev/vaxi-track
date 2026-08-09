import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_colors.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController deviceNameController = TextEditingController();

  final TextEditingController deviceIdController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  final TextEditingController gpsController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  String? selectedType;
  String? selectedTemperature;
  String? selectedBatch;

  final List<String> deviceTypes = ["ESP32", "ESP8266", "Arduino"];

  final List<String> temperatureRanges = ["2°C - 8°C", "-20°C", "-80°C"];

  final List<String> batches = ["PF-2026-001", "BCG-2026-014", "MMR-2026-008"];

  @override
  void dispose() {
    deviceNameController.dispose();
    deviceIdController.dispose();
    locationController.dispose();
    gpsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void registerDevice() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Success"),
          content: const Text("Device registered successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        value: value,
        validator: (value) => value == null ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Add Device"),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Device Information",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            buildTextField(
              controller: deviceNameController,
              label: "Device Name",
              icon: Icons.memory,
            ),

            buildTextField(
              controller: deviceIdController,
              label: "Device ID",
              icon: Icons.confirmation_number,
            ),

            buildTextField(
              controller: locationController,
              label: "Hospital / Location",
              icon: Icons.location_on,
            ),

            buildTextField(
              controller: gpsController,
              label: "GPS Coordinates",
              icon: Icons.gps_fixed,
            ),

            buildDropdown(
              label: "Device Type",
              icon: Icons.developer_board,
              items: deviceTypes,
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),

            buildDropdown(
              label: "Temperature Range",
              icon: Icons.thermostat,
              items: temperatureRanges,
              value: selectedTemperature,
              onChanged: (value) {
                setState(() {
                  selectedTemperature = value;
                });
              },
            ),

            buildDropdown(
              label: "Assign Vaccine Batch",
              icon: Icons.vaccines,
              items: batches,
              value: selectedBatch,
              onChanged: (value) {
                setState(() {
                  selectedBatch = value;
                });
              },
            ),

            buildTextField(
              controller: notesController,
              label: "Additional Notes",
              icon: Icons.notes,
              maxLines: 4,
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: registerDevice,
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  "Register Device",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
