import 'package:flutter/material.dart';
import 'recent_activity.dart';


class FarmerHome extends StatefulWidget {
  const FarmerHome({super.key});

  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // optional
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.png'),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Welcome back,",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text("Farmer F-100",
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
      
              // Quick Stats Cards
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(title: "Inventory", value: "12 Items", icon: Icons.store),
                  _StatCard(title: "Orders", value: "5 Pending", icon: Icons.receipt_long),
                  _StatCard(title: "Earnings", value: "₹12,300", icon: Icons.attach_money),
                  _StatCard(title: "Top Seller", value: "Tomatoes", icon: Icons.trending_up),
                ],
              ),
              const SizedBox(height: 24),
      
              // Recent Activity Header
              Text("Recent Activity",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
      
              // Activity List
              // Tappable Scrollable Recent Activity
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecentActivityPage()),
                  );
                },
                child: SizedBox(
                  height: 180, // Adjust as needed
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: const [
                      _ActivityTile(
                        icon: Icons.add_box,
                        title: "Added 5kg Tomatoes to Inventory",
                        subtitle: "Today, 9:30 AM",
                      ),
                      _ActivityTile(
                        icon: Icons.local_shipping,
                        title: "Order #10234 dispatched",
                        subtitle: "Yesterday, 4:10 PM",
                      ),
                      _ActivityTile(
                        icon: Icons.account_balance_wallet,
                        title: "Earnings updated: ₹3,000",
                        subtitle: "2 days ago",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Optional: Shortcut Buttons
              Text("Quick Actions", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickActionButton(
                      icon: Icons.add_circle, label: "Add Item", onTap: () {}),
                  _QuickActionButton(
                      icon: Icons.receipt, label: "Orders", onTap: () {}),
                  _QuickActionButton(
                      icon: Icons.attach_money, label: "Withdraw", onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add `const` to constructor to enable constant usage
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(color: Colors.black54, fontSize: 14)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: Icon(icon, color: Colors.green[800]),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.green[800], size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
