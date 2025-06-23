import 'package:flutter/material.dart';
import 'package:project_2_graphs/presentation/pages/splash/widgets/animated_panel.dart';
import 'package:project_2_graphs/presentation/pages/splash/widgets/title_panel.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final availableWidth = constraints.maxWidth;
              return GestureDetector(
                onTap: () {},
                child: Column(
                  children: [
                    AnimatedColorPanel(
                      height: availableHeight * 0.6,
                      width: availableWidth,
                      duration: Duration(milliseconds: 2000),
                      circleCount: 20,
                    ),
                    TitlePanel(
                      title: "Graphs",
                      nameAuthor: "Edward",
                      version: "0.0.1",
                      height: availableHeight * 0.4,
                      width: availableWidth,
                      duration: Duration(milliseconds: 600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
