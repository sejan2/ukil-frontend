import 'dart:ui';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/article_screen.dart';
import 'screens/message_screen.dart';
import 'screens/user_screen.dart';
import 'screens/more_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    ArticleScreen(),
    MessageScreen(),
    UserScreen(),
    MoreScreen(),
  ];

  final List<IconData> icons = [
    Icons.home,
    Icons.article,
    Icons.chat,
    Icons.person,
    Icons.more_horiz,
  ];

  final List<String> labels = ["Home", "Article", "Message", "User", "More"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0f172a), Color(0xff1e293b), Color(0xff0b1220)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          child: IndexedStack(index: currentIndex, children: pages),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.20)),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(icons.length, (i) {
                    bool active = currentIndex == i;

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        setState(() {
                          currentIndex = i;
                        });
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.green.withOpacity(0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: active
                              ? Border.all(color: Colors.green.withOpacity(0.4))
                              : null,
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons[i], size: 26, color: Colors.green),
                            const SizedBox(height: 3),
                            Text(
                              labels[i],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
