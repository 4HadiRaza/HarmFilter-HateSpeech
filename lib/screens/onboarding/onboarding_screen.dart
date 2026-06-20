import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<Map<String, dynamic>> _features = [
    {
      'icon': LucideIcons.shield,
      'title': 'Real-time Protection',
      'description':
          'Get instant feedback before posting to prevent harmful content',
    },
    {
      'icon': LucideIcons.heart,
      'title': 'Compassion Coach',
      'description': 'Learn to communicate with empathy and respect',
    },
    {
      'icon': LucideIcons.trendingUp,
      'title': 'Track Progress',
      'description': 'See your growth journey with detailed analytics',
    },
    {
      'icon': LucideIcons.sparkles,
      'title': 'Gamified Learning',
      'description': 'Earn points, complete lessons, and climb the leaderboard',
    },
  ];

  void _handleComplete() {
    // In a real app, we would save the user data here
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D9488).withOpacity(0.15), // Teal 600
              Theme.of(context).colorScheme.surface,
              const Color(0xFF5EEAD4).withOpacity(0.1), // Teal 300
              const Color(0xFFF59E0B).withOpacity(0.05), // Amber accent
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            elevation: 8,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _buildStepContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildFeaturesStep();
      case 2:
        return _buildProfileStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.shield,
            size: 40,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to HarmFilter',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Making online spaces safer, one post at a time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'HarmFilter helps you identify and prevent harmful content before it spreads, while learning to communicate with compassion.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Get Started'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'How HarmFilter Works',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Four powerful features to help you build a better online presence',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _features.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final feature = _features[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            feature['description'] as String,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Back'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Create Your Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us a bit about yourself to get started',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'This is a demo app. Your information is stored locally and not sent anywhere.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Back'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  _nameController,
                  _emailController,
                ]),
                builder: (context, _) {
                  return FilledButton(
                    onPressed:
                        _nameController.text.isNotEmpty &&
                            _emailController.text.isNotEmpty
                        ? _handleComplete
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Complete Setup'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
