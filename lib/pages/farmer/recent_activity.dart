import 'package:flutter/material.dart';

class RecentActivityPage extends StatelessWidget {
  const RecentActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Activity"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.add_box),
            title: Text("Added 5kg Tomatoes to Inventory"),
            subtitle: Text("Today, 9:30 AM"),
          ),
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text("Order #10234 dispatched"),
            subtitle: Text("Yesterday, 4:10 PM"),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text("Earnings updated: ₹3,000"),
            subtitle: Text("2 days ago"),
          ),
          // You can add more dummy tiles or make this dynamic later
        ],
      ),
    );
  }
}
