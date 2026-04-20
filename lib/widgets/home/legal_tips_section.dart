import 'package:flutter/material.dart';

class LegalTipsSection extends StatelessWidget {
  const LegalTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      {
        "title": "Know Your Legal Rights",
        "desc": "Understand your basic citizen rights in Bangladesh.",
        "icon": Icons.gavel,
        "color": Colors.blue,
      },
      {
        "title": "How to File a Complaint",
        "desc": "Step-by-step guide to file a legal complaint properly.",
        "icon": Icons.report_problem,
        "color": Colors.orange,
      },
      {
        "title": "Legal Notice Basics",
        "desc": "What to do when you receive a legal notice.",
        "icon": Icons.article,
        "color": Colors.green,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💎 HEADER
          const Text(
            "Legal Tips",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // 💎 LIST
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final item = tips[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    // ICON CIRCLE
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (item["color"] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item["icon"] as IconData,
                        color: item["color"] as Color,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            item["desc"] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
