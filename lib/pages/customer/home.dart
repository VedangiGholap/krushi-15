import 'package:flutter/material.dart';
import 'orders.dart';
import 'cart.dart';
import 'profile.dart';
import 'produce_list_page.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  MainHomeState createState() => MainHomeState();
}

class MainHomeState extends State<MainHome> {
  int _selectedIndex = 0;

  List<String> categories = ['Vegetables', 'Fruits', 'Grains'];
  String selectedCategory = 'Vegetables';
  String searchQuery = '';

  Future<Map<String, List<Map<String, String>>>> fetchProducts() async {
    return {
      'Vegetables': [
        {'title': 'Tomatoes', 'image': 'lib/assets/images/Tomato.png'},
        {'title': 'Spinach', 'image': 'lib/assets/images/Spinach.png'},
        {'title': 'LadyFinger', 'image': 'lib/assets/images/LadyFinger.png'},
      ],
      'Fruits': [
        {'title': 'Bananas', 'image': 'lib/assets/images/Banana.png'},
        {'title': 'Strawberries', 'image': 'lib/assets/images/Strawberry.png'},
      ],
      'Grains': [
        {'title': 'Rice', 'image': 'lib/assets/images/Rice.png'},
        {'title': 'Wheat', 'image': 'lib/assets/images/Wheat.png'},
      ],
    };
  }

  List<Widget> get _pages => [
    buildHomePageContent(),
    CustomerOrdersPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget buildHomePageContent() {
    return FutureBuilder<Map<String, List<Map<String, String>>>>(
      future: fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading products"));
        }

        final productsByCategory = snapshot.data!;

        return DefaultTabController(
          length: categories.length,
          child: SafeArea(
            child: Column(
              children: [
                // Top Bar with Location and Search
                Container(
                  color: Colors.green,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/profile.png'),
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Location",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Text("Thane, Maharashtra",
                                  style: TextStyle(color: Colors.white70, fontSize: 16)),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.notifications, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SearchBar(
                        backgroundColor: const WidgetStatePropertyAll(Colors.white),
                        padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 16)),
                        hintText: 'Search any item...',
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        leading: const Icon(Icons.search),
                        trailing: [
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // TabBar
                    ],
                  ),
                ),
                // TabBar Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.white,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      indicatorPadding: const EdgeInsets.all(4),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: categories
                          .map((cat) => Tab(
                        child: Text(
                          cat,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ))
                          .toList(),
                      labelStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),

                // Body Content
                Expanded(
                  child: TabBarView(
                    children: categories.map((category) {
                      final allProducts = productsByCategory[category] ?? [];
                      final filteredProducts = allProducts
                          .where((product) => product['title']!
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                          children: filteredProducts.map((product) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProduceListPage(
                                        productName: product['title']!),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12)),
                                        child: Image.asset(
                                          product['image']!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(product['title']!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
