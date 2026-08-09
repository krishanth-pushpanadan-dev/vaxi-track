import 'package:flutter/material.dart';

class BatchDetailsPage extends StatelessWidget {
  final String vaccineName;

  const BatchDetailsPage({super.key, required this.vaccineName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Batch Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Vaccine Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(
                      Icons.vaccines,
                      size: 42,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    vaccineName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Batch No : PF-2026-001",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Stored",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _section(
              title: "Batch Information",
              children: const [
                _InfoTile(
                  icon: Icons.factory,
                  title: "Manufacturer",
                  value: "Pfizer",
                ),

                _InfoTile(
                  icon: Icons.calendar_today,
                  title: "Manufactured",
                  value: "15 Jan 2026",
                ),

                _InfoTile(
                  icon: Icons.event,
                  title: "Expiry Date",
                  value: "15 Jan 2027",
                ),

                _InfoTile(
                  icon: Icons.inventory,
                  title: "Available Doses",
                  value: "2,500",
                ),
              ],
            ),

            const SizedBox(height: 20),

            _section(
              title: "Storage Information",
              children: const [
                _InfoTile(
                  icon: Icons.location_on,
                  title: "Current Location",
                  value: "Central Vaccine Store",
                ),

                _InfoTile(
                  icon: Icons.ac_unit,
                  title: "Storage Temperature",
                  value: "2°C - 8°C",
                ),

                _InfoTile(
                  icon: Icons.thermostat,
                  title: "Current Temperature",
                  value: "4.3°C",
                ),

                _InfoTile(
                  icon: Icons.warehouse,
                  title: "Storage Unit",
                  value: "Refrigerator A-01",
                ),
              ],
            ),

            const SizedBox(height: 20),

            _section(
              title: "Delivery Timeline",
              children: const [
                _InfoTile(
                  icon: Icons.local_shipping,
                  title: "Shipment",
                  value: "Delivered Successfully",
                ),

                _InfoTile(
                  icon: Icons.check_circle,
                  title: "Quality Check",
                  value: "Passed",
                ),

                _InfoTile(
                  icon: Icons.schedule,
                  title: "Last Inspection",
                  value: "Today • 09:30 AM",
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text("Export"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {},
                icon: const Icon(Icons.delete),
                label: const Text("Delete Batch"),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
