import 'package:expenses_tracker/components/myappbar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/pages/appcolors.dart';
import 'package:expenses_tracker/models/transactions.dart';
import 'package:expenses_tracker/services/balance_provider.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({Key? key, required DateTime selectedDate})
      : super(key: key);

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final balanceProvider = context.watch<BalanceProvider>();
    final allTransactions = balanceProvider.allTransactions;

    // Group transactions by day
    final grouped = <DateTime, List<TransactionModel>>{};
    for (var t in allTransactions) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(day, () => []).add(t);
    }

    final sortedDays = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: AppBar(
        backgroundColor: const Color(0xff181a1e),
        title: const Text(
          'O V E R V I E W',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ---- BAR CHART ----
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final dayIndex = value.toInt();
                          if (dayIndex < 0 || dayIndex >= sortedDays.length) {
                            return const SizedBox.shrink();
                          }
                          final date = sortedDays[dayIndex];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "${date.day}/${date.month}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(sortedDays.length, (i) {
                    final day = sortedDays[i];
                    final txs = grouped[day]!;
                    final income = txs
                        .where((t) => t.amount > 0)
                        .fold(0.0, (s, t) => s + t.amount);
                    final expense = txs
                        .where((t) => t.amount < 0)
                        .fold(0.0, (s, t) => s + t.amount.abs());

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: income,
                          color: Colors.green.withOpacity(.5),
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: expense,
                          color: Colors.red.withOpacity(.5),
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.green,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = sortedDays[group.x.toInt()];
                        final dateStr = "${day.day}/${day.month}/${day.year}";
                        return BarTooltipItem(
                          "$dateStr\n${rod.toY.toStringAsFixed(2)}",
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response != null &&
                          response.spot != null &&
                          event.isInterestedForInteractions) {
                        final i = response.spot!.touchedBarGroupIndex;
                        final day = sortedDays[i];
                        setState(() => selectedDate = day);
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---- TRANSACTIONS LIST WHEN A BAR IS SELECTED ----
            if (selectedDate != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Transactions for ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: grouped[selectedDate!]!.map((t) {
                          return ListTile(
                            leading: Icon(
                              t.amount > 0
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: t.amount > 0 ? Colors.green : Colors.red,
                            ),
                            title: Text(t.place),
                            trailing: Text(
                              "${t.amount > 0 ? "+" : "-"}\$${t.amount.abs().toStringAsFixed(2)}",
                              style: TextStyle(
                                color: t.amount > 0
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                "Tap on a bar to view transactions for that day.",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
