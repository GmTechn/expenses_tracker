import 'package:flutter/material.dart';

class Mytransaction extends StatelessWidget {
  const Mytransaction({
    super.key,
    required this.logo,
    required this.title,
    required this.date,
    required this.amount,
  });

  final String logo; // URL ou asset path
  final String title;
  final String date;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = amount >= 0;
    final Color amountColor = isIncome ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 35, 37, 46),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: logo.startsWith('http')
                  ? Image.network(
                      logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.store, color: Color(0xff181a1e)),
                    )
                  : Image.asset(
                      logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.store, color: Color(0xff181a1e)),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}",
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
