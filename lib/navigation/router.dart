import 'package:go_router/go_router.dart';
import 'package:yezer/screens/console_screen.dart';
import 'package:yezer/screens/error_screen.dart';
import 'package:yezer/screens/splash_screen.dart';

final GoRouter yezRouter = GoRouter(
  routes: [
    GoRoute(
      name: SplashScreen.name,
      path: SplashScreen.path,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: ConsoleScreen.name,
      path: ConsoleScreen.path,
      builder: (context, state) => const ConsoleScreen(),
    ),
  ],
  errorBuilder: (context, state) => const ErrorScreen(),
);
