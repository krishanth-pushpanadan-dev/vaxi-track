import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_colors.dart';
import 'package:vaxi_track/app/app_routes.dart';
import 'package:vaxi_track/features/vaccine_batches/models/batch_model.dart';
import 'package:vaxi_track/features/vaccine_batches/presentation/qr_generator_page.dart';

import '../../dashboard/widgets/bottom_nav_bar.dart';
import '../../dashboard/widgets/section_header.dart';

import '../data/batch_dummy_data.dart';
import '../presentation/batch_details_page.dart';
import '../widgets/batch_card.dart';
import '../widgets/vaccine_summary_card.dart';
import '../presentation/add_batch_page.dart';

class BatchesPage extends StatefulWidget {
  const BatchesPage({super.key});

  @override
  State<BatchesPage> createState() => _BatchesPageState();
}

class _BatchesPageState extends State<BatchesPage> {
  final TextEditingController searchController = TextEditingController();

  String search = "";
  String selectedFilter = "All";

  Widget _chip(String label) {
    final selected = selectedFilter.toLowerCase() == label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label[0].toUpperCase() + label.substring(1)),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedFilter = label[0].toUpperCase() + label.substring(1);
          });
        },
      ),
    );
  }

  List<BatchModel> get filteredBatches {
    var list = batchList.where((batch) {
      return batch.vaccineName.toLowerCase().contains(search.toLowerCase()) ||
          batch.batchNumber.toLowerCase().contains(search.toLowerCase());
    }).toList();

    if (selectedFilter != "All") {
      list = list.where((batch) {
        return batch.status.name.toLowerCase() == selectedFilter.toLowerCase();
      }).toList();
    }

    return list;
  }

  int get activeCount =>
      batchList.where((e) => e.status == BatchStatus.stored).length;

  int get transitCount =>
      batchList.where((e) => e.status == BatchStatus.transit).length;

  int get deliveredCount =>
      batchList.where((e) => e.status == BatchStatus.delivered).length;

  int get expiredCount =>
      batchList.where((e) => e.status == BatchStatus.expired).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Vaccine Batches"), centerTitle: true),

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
                  hintText: "Search Vaccine Batch",

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

                subtitle: "Batch Statistics",
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: GridView.count(
                crossAxisCount: 2,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                childAspectRatio: 0.80,

                crossAxisSpacing: 15,

                mainAxisSpacing: 15,

                children: [
                  BatchSummaryCard(
                    title: "Stored",
                    value: "$activeCount",
                    subtitle: "Available",
                    icon: Icons.inventory,
                    color: Colors.green,
                  ),

                  BatchSummaryCard(
                    title: "Transit",
                    value: "$transitCount",
                    subtitle: "Shipping",
                    icon: Icons.local_shipping,
                    color: Colors.orange,
                  ),

                  BatchSummaryCard(
                    title: "Delivered",
                    value: "$deliveredCount",
                    subtitle: "Completed",
                    icon: Icons.check_circle,
                    color: Colors.blue,
                  ),

                  BatchSummaryCard(
                    title: "Expired",
                    value: "$expiredCount",
                    subtitle: "Need Action",
                    icon: Icons.warning,
                    color: Colors.red,
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

                  _chip("stored"),

                  _chip("transit"),

                  _chip("delivered"),

                  _chip("expired"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                icon: Icons.vaccines,
                title: "Batch List",
                subtitle: "${filteredBatches.length} batches found",
              ),
            ),

            if (filteredBatches.isEmpty)
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
                        Icons.inventory_2_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 15),

                      Text(
                        "No Vaccine Batches",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "Try another search or filter.",
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
                itemCount: filteredBatches.length,
                itemBuilder: (context, index) {
                  final batch = filteredBatches[index];

                  return BatchCard(
                    vaccineName: batch.vaccineName,
                    batchNo: batch.batchNumber,
                    quantity: batch.quantity,
                    expiryDate: batch.expiryDate,
                    storageTemperature: batch.storageTemperature,
                    status: batch.status,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BatchDetailsPage(vaccineName: batch.vaccineName),
                        ),
                      );
                    },

                    onGenerateQR: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QRGeneratorPage(batch: batch),
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
            MaterialPageRoute(builder: (_) => const AddBatchPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Batch"),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              break;

            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.devices);
              break;

            case 2:
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
