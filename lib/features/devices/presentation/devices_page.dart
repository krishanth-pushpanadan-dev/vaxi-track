import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../dashboard/widgets/bottom_nav_bar.dart';
import '../../dashboard/widgets/device_card.dart';
import '../../dashboard/widgets/section_header.dart';

import '../models/device_model.dart';
import '../../../core/dummy/dummy_devices.dart';

import '../widgets/device_search_bar.dart';
import '../widgets/device_filter_chip.dart';
import '../widgets/device_summary_card.dart';
import '../presentation/add_device_page.dart';
import 'device_details_page.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final TextEditingController searchController = TextEditingController();

  List<DeviceModel> filteredDevices = [];

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    filteredDevices = deviceList;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {});
  }

  void filterDevices(String value) {
    setState(() {
      filteredDevices = deviceList.where((device) {
        final matchesSearch =
            device.name.toLowerCase().contains(value.toLowerCase()) ||
            device.location.toLowerCase().contains(value.toLowerCase());

        bool matchesFilter = true;

        if (selectedFilter != "All") {
          matchesFilter =
              device.status.name.toLowerCase() == selectedFilter.toLowerCase();
        }

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void changeFilter(String filter) {
    selectedFilter = filter;
    filterDevices(searchController.text);
  }

  int get onlineCount =>
      deviceList.where((e) => e.status == DeviceStatus.online).length;

  int get warningCount =>
      deviceList.where((e) => e.status == DeviceStatus.warning).length;

  int get offlineCount =>
      deviceList.where((e) => e.status == DeviceStatus.offline).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Devices"),
      ),

      body: RefreshIndicator(
        onRefresh: refreshData,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DeviceSearchBar(
                controller: searchController,
                onChanged: filterDevices,
                onClear: () {
                  searchController.clear();
                  filterDevices("");
                },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DeviceFilterChip(
                    label: "All",
                    selected: selectedFilter == "All",
                    onTap: () => setState(() => changeFilter("All")),
                  ),

                  const SizedBox(width: 10),

                  DeviceFilterChip(
                    label: "Online",
                    selected: selectedFilter == "Online",
                    onTap: () => setState(() => changeFilter("Online")),
                  ),

                  const SizedBox(width: 10),

                  DeviceFilterChip(
                    label: "Warning",
                    selected: selectedFilter == "Warning",
                    onTap: () => setState(() => changeFilter("Warning")),
                  ),

                  const SizedBox(width: 10),

                  DeviceFilterChip(
                    label: "Offline",
                    selected: selectedFilter == "Offline",
                    onTap: () => setState(() => changeFilter("Offline")),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                icon: Icons.analytics_outlined,
                title: "Device Overview",
                subtitle: "Real-time monitoring status",
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.80,
                children: [
                  DeviceSummaryCard(
                    title: "Total Devices",
                    value: deviceList.length.toString(),
                    icon: Icons.memory,
                    color: Colors.blue,
                    subtitle: "All registered devices",
                  ),

                  DeviceSummaryCard(
                    title: "Online",
                    value: onlineCount.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                    subtitle: "Devices currently online",
                  ),

                  DeviceSummaryCard(
                    title: "Warning",
                    value: warningCount.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                    subtitle: "Devices with warnings",
                  ),

                  DeviceSummaryCard(
                    title: "Offline",
                    value: offlineCount.toString(),
                    icon: Icons.cancel,
                    color: Colors.red,
                    subtitle: "Devices currently offline",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                icon: Icons.devices_other,
                title: "All Devices",
                subtitle: "${filteredDevices.length} devices available",
              ),
            ),

            const SizedBox(height: 15),

            if (filteredDevices.isEmpty)
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
                      Icon(Icons.search_off, size: 70, color: Colors.grey),

                      SizedBox(height: 15),

                      Text(
                        "No Devices Found",
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
                itemCount: filteredDevices.length,
                itemBuilder: (context, index) {
                  final device = filteredDevices[index];

                  return DeviceCard(
                    deviceName: device.name,
                    location: device.location,
                    temperature: device.temperature,
                    humidity: device.humidity,
                    battery: device.battery,
                    signal: device.signal,
                    lastUpdated: device.lastUpdated,
                    status: device.status,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DeviceDetailsPage(deviceName: device.name),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDevicePage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Device"),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              break;

            case 1:
              break;

            case 2:
              Navigator.pushReplacementNamed(context, AppRoutes.batches);
              break;

            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.alerts);
              break;
          }
        },
      ),
    );
  }
}
