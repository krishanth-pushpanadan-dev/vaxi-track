import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TemperatureChart extends StatelessWidget {
  const TemperatureChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,

          gridData: FlGridData(show: true),

          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const labels = ["9AM", "11AM", "1PM", "3PM", "5PM", "7PM"];

                  if (value.toInt() >= labels.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 4.2),
                FlSpot(1, 4.5),
                FlSpot(2, 4.8),
                FlSpot(3, 5.0),
                FlSpot(4, 4.6),
                FlSpot(5, 4.3),
              ],

              isCurved: true,

              barWidth: 4,

              color: Colors.blue,

              dotData: const FlDotData(show: true),

              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
