import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_2_graphs/config/routes/route_names.dart';
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
                onTap: () {
                  GoRouter.of(context).go(RouteNames.home);
                },
                child: Column(
                  children: [
                    TitlePanel(
                      title: "Graphs",
                      nameAuthor: "Edward",
                      version: "0.0.1",
                      height: availableHeight,
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
