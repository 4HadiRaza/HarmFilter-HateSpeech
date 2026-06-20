import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmfilter_flutter/screens/auth/login_screen.dart';
import 'package:harmfilter_flutter/screens/auth/signup_screen.dart';
import 'package:harmfilter_flutter/screens/auth/forgot_password_screen.dart';
import 'package:harmfilter_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:harmfilter_flutter/screens/analyze/analyze_screen.dart';
import 'package:harmfilter_flutter/screens/leaderboard/leaderboard_screen.dart';
import 'package:harmfilter_flutter/screens/learn/learn_screen.dart';
import 'package:harmfilter_flutter/screens/learn/quiz_detail_screen.dart';
import 'package:harmfilter_flutter/screens/settings/settings_screen.dart';
import 'package:harmfilter_flutter/screens/profile/profile_screen.dart';
import 'package:harmfilter_flutter/screens/profile/edit_profile_screen.dart';
import 'package:harmfilter_flutter/screens/post_detail/post_detail_screen.dart';
import 'package:harmfilter_flutter/screens/not_found/not_found_screen.dart';
import 'package:harmfilter_flutter/widgets/layout_scaffold.dart';
import 'package:harmfilter_flutter/screens/splash/splash_screen.dart';
import 'package:harmfilter_flutter/screens/chat/chat_screen.dart';
import 'package:harmfilter_flutter/screens/onboarding/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EditProfileScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return LayoutScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/analyze',
          builder: (context, state) => const AnalyzeScreen(),
        ),
        GoRoute(
          path: '/leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: '/learn',
          builder: (context, state) => const LearnScreen(),
        ),
        GoRoute(
          path: '/learn/quiz/:quizId',
          builder: (context, state) {
            final quizId = state.pathParameters['quizId']!;
            final extra = state.extra;
            final onQuizComplete = extra is Future<void> Function(String, int, int)
                ? extra
                : null;
            return QuizDetailScreen(
              quizId: quizId,
              onQuizComplete: onQuizComplete,
            );
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
        GoRoute(
          path: '/post-detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PostDetailScreen(postId: id);
          },
        ),
      ],
    ),
  ],
);
