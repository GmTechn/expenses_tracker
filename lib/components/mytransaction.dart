import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Mytransaction extends StatelessWidget {
  const Mytransaction(
      {super.key,
      required this.logo,
      required this.title,
      required this.date,
      required this.amount});

  final String logo;
  final String title;
  final String date;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.1),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          //logo image of transaction
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(logo),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(
            width: 16,
          ),
          //Title + Transaction Date

          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                date,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              //Amount

              Text(
                amount >= 0
                    ? "+\$${amount.toStringAsFixed(2)}"
                    : "-\$${amount.abs().toStringAsFixed(2)}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: amount >= 0 ? Colors.green : Colors.red),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
