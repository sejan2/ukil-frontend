import 'package:flutter/material.dart';
import '../../services/public_service.dart';
import 'advocate_profile_view.dart';

class AdvocatesScreen extends StatefulWidget {
  const AdvocatesScreen({super.key});

  @override
  State<AdvocatesScreen> createState() => _AdvocatesScreenState();
}

class _AdvocatesScreenState extends State<AdvocatesScreen> {
  List<Map<String, dynamic>> advocates = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  int total = 0;
  int selectedIndex = -1;
  String selectedPractice = '';

  final searchCtrl = TextEditingController();
  final practices = [
    "All",
    "Criminal",
    "Family",
    "Corporate",
    "Real Estate",
    "Civil",
  ];

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    // search on pause (debounce)
    searchCtrl.addListener(_onSearch);
  }

  String? _debounce;
  void _onSearch() async {
    final q = searchCtrl.text;
    _debounce = q;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_debounce == q) _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        advocates = [];
      });
    } else {
      setState(() => isLoadingMore = true);
    }

    try {
      final res = await PublicService.browseAdvocates(
        name: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
        practice: (selectedPractice.isEmpty || selectedPractice == 'All')
            ? null
            : selectedPractice,
        page: currentPage,
        limit: 12,
      );

      final newList = List<Map<String, dynamic>>.from(res['advocates']);
      setState(() {
        advocates = reset ? newList : [...advocates, ...newList];
        total = res['total'];
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _selectPractice(String p) {
    setState(() => selectedPractice = p == 'All' ? '' : p);
    _load(reset: true);
  }

  void _loadMore() {
    currentPage++;
    _load();
  }

  bool get _hasMore => advocates.length < total;

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

          // 🔍 SEARCH BAR
          TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: "Search lawyers by name...",
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

          // 🟢 HEADER BOX
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF138424),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Find a Lawyer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$total approved advocates available",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🧩 PRACTICE AREA CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: practices.map((p) {
                final isActive =
                    (p == 'All' && selectedPractice.isEmpty) ||
                    selectedPractice == p;
                return GestureDetector(
                  onTap: () => _selectPractice(p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Chip(
                      label: Text(p),
                      backgroundColor: isActive
                          ? Colors.green
                          : Colors.green.shade50,
                      labelStyle: TextStyle(
                        color: isActive ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // 👨‍⚖️ ADVOCATE LIST
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Colors.green),
              ),
            )
          else if (advocates.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  "No advocates found",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else ...[
            ...advocates.asMap().entries.map(
              (e) => _advocateCard(e.value, e.key),
            ),

            // LOAD MORE
            if (_hasMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: isLoadingMore
                      ? const CircularProgressIndicator(color: Colors.green)
                      : OutlinedButton(
                          onPressed: _loadMore,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Load More",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _advocateCard(Map<String, dynamic> a, int index) {
    final isSelected = selectedIndex == index;
    final photoUrl = a['photo_url'];
    final areas = a['practice_areas'];
    final specialty = areas is List
        ? (areas as List).take(2).join(', ')
        : areas?.toString() ?? 'General';

    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdvocateProfileView(advocateId: a['id'].toString()),
          ),
        );
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
            // PHOTO
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.withOpacity(0.1),
              backgroundImage: photoUrl != null
                  ? NetworkImage("http://10.0.2.2:5000$photoUrl")
                  : null,
              child: photoUrl == null
                  ? const Icon(Icons.person, color: Colors.green)
                  : null,
            ),

            const SizedBox(width: 12),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a['name'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: isSelected ? Colors.white70 : Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        a['district'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ARROW
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isSelected ? Colors.white : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}
