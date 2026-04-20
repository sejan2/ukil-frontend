import 'package:flutter/material.dart';

class AdvocatesScreen extends StatefulWidget {
  const AdvocatesScreen({super.key});

  @override
  State<AdvocatesScreen> createState() => _AdvocatesScreenState();
}

class _AdvocatesScreenState extends State<AdvocatesScreen> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Find a Lawyer"),
        backgroundColor: const Color(0xFF138424),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),

          // 🔍 Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search lawyers...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🟢 FIND LAWYER BOX
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF138424),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Find a Lawyer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Over 15 categories and 100+ lawyers available",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🧩 Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip("Criminal"),
                _chip("Family"),
                _chip("Corporate"),
                _chip("Real Estate"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 👨‍⚖️ Advocate List
          ...dummyAdvocates.asMap().entries.map((entry) {
            int index = entry.key;
            var advocate = entry.value;
            return _advocateCard(advocate, index);
          }).toList(),
        ],
      ),
    );
  }

  // 🔘 Chip Widget
  Widget _chip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(label: Text(text), backgroundColor: Colors.green.shade50),
    );
  }

  // 👤 Advocate Card
  Widget _advocateCard(Map<String, dynamic> data, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF138424) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(data['image']),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['speciality'],
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        data['rating'].toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Dot
            Icon(
              Icons.circle,
              size: 10,
              color: isSelected ? Colors.white : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

// 📦 Dummy Data
final List<Map<String, dynamic>> dummyAdvocates = [
  {
    "name": "Barr. John Doe",
    "speciality": "Criminal Lawyer",
    "rating": 4.5,
    "image": "https://randomuser.me/api/portraits/men/1.jpg",
  },
  {
    "name": "Barr. Sarah Smith",
    "speciality": "Family Lawyer",
    "rating": 4.8,
    "image": "https://randomuser.me/api/portraits/women/2.jpg",
  },
  {
    "name": "Barr. Alex Johnson",
    "speciality": "Corporate Lawyer",
    "rating": 4.3,
    "image": "https://randomuser.me/api/portraits/men/3.jpg",
  },
  {
    "name": "Barr. Emily Davis",
    "speciality": "Real Estate Lawyer",
    "rating": 4.7,
    "image": "https://randomuser.me/api/portraits/women/4.jpg",
  },
];
