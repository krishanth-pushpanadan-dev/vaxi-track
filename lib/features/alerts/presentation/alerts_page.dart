import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_colors.dart';
import 'package:vaxi_track/features/alerts/data/alert_dummy_data.dart';
import 'package:vaxi_track/features/alerts/models/alert_model.dart';
import 'package:vaxi_track/features/alerts/presentation/alert_details_page.dart';
import 'package:vaxi_track/features/alerts/widgets/alert_card.dart';
import 'package:vaxi_track/features/dashboard/presentation/dashboard_page.dart';
import 'package:vaxi_track/features/devices/presentation/devices_page.dart';
import 'package:vaxi_track/features/vaccine_batches/presentation/batches_page.dart';

import '../../dashboard/widgets/bottom_nav_bar.dart';
import '../../dashboard/widgets/section_header.dart';
import '../widgets/alert_summary_card.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final TextEditingController searchController = TextEditingController();

  String search = "";
  String selectedFilter = "All";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _chip(String label) {
    final selected = selectedFilter.toLowerCase() == label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedFilter = label;
          });
        },
      ),
    );
  }

  List<AlertModel> get filteredAlerts {
    var list = alertList.where((alert) {
      return alert.title.toLowerCase().contains(search.toLowerCase()) ||
          alert.deviceName.toLowerCase().contains(search.toLowerCase()) ||
          alert.location.toLowerCase().contains(search.toLowerCase());
    }).toList();

    if (selectedFilter != "All") {
      list = list.where((alert) {
        if (selectedFilter == "Resolved") {
          return alert.status == AlertStatus.resolved;
        }

        return alert.severity.name.toLowerCase() ==
            selectedFilter.toLowerCase();
      }).toList();
    }

    return list;
  }

  int get criticalCount =>
      alertList.where((e) => e.severity == AlertSeverity.critical).length;

  int get warningCount =>
      alertList.where((e) => e.severity == AlertSeverity.warning).length;

  int get infoCount =>
      alertList.where((e) => e.severity == AlertSeverity.info).length;

  int get resolvedCount =>
      alertList.where((e) => e.status == AlertStatus.resolved).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Alerts"), centerTitle: true),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Alerts",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                icon: Icons.analytics,
                title: "Overview",
                subtitle: "Alert Statistics",
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 0.80,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  AlertSummaryCard(
                    title: "Critical",
                    value: "$criticalCount",
                    subtitle: "Immediate Action",
                    icon: Icons.warning,
                    color: Colors.red,
                  ),

                  AlertSummaryCard(
                    title: "Warning",
                    value: "$warningCount",
                    subtitle: "Monitor",
                    icon: Icons.report_problem,
                    color: Colors.orange,
                  ),

                  AlertSummaryCard(
                    title: "Information",
                    value: "$infoCount",
                    subtitle: "Notifications",
                    icon: Icons.info,
                    color: Colors.blue,
                  ),

                  AlertSummaryCard(
                    title: "Resolved",
                    value: "$resolvedCount",
                    subtitle: "Completed",
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _chip("All"),
                  _chip("Critical"),
                  _chip("Warning"),
                  _chip("Info"),
                  _chip("Resolved"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                icon: Icons.notifications_active,
                title: "Alert List",
                subtitle: "${filteredAlerts.length} alerts found",
              ),
            ),
            const SizedBox(height: 15),

            if (filteredAlerts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 15),
                      Text(
                        "No Alerts Found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Try another search keyword or filter.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredAlerts.length,
                itemBuilder: (context, index) {
                  final alert = filteredAlerts[index];

                  return AlertCard(
                    alert: alert,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlertDetailsPage(alert: alert),
                        ),
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.notifications_active),
        label: const Text("Alerts"),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Alert management coming soon")),
          );
        },
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DevicesPage()),
              );
              break;

            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BatchesPage()),
              );
              break;

            case 3:
              break;

            case 4:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings page coming soon")),
              );
              break;
          }
        },
      ),
    );
  }
}
