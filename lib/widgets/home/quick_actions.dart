import 'package:flutter/material.dart';
import '../../routes/app_routes.dart'; // ✅ adjust path if needed

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        "title": "Find Advocates",
        "icon": Icons.gavel,
        "route": AppRoutes.advocates, // ✅ route added
      },
      {"title": "Free Consult", "icon": Icons.support_agent},
      {"title": "Ask Question", "icon": Icons.question_answer},
      {"title": "My Cases", "icon": Icons.folder},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final item = actions[index];

          return GestureDetector(
            onTap: () {
              // ✅ Navigation handling
              if (item["route"] != null) {
                Navigator.pushNamed(context, item["route"] as String);
              } else {
                // Optional: show message for unimplemented features
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${item["title"]} coming soon")),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item["icon"] as IconData,
                    size: 36,
                    color: const Color.fromARGB(255, 56, 110, 41),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item["title"] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
