import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:numberwale/src/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:numberwale/src/onboarding/presentation/widgets/page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.search,
      'title': 'Discover Premium Numbers',
      'description':
          'Browse thousands of VIP, fancy, and numerology-based mobile numbers tailored to your preferences.',
    },
    {
      'icon': Icons.star,
      'title': 'Advanced Search',
      'description':
          'Use powerful filters to find numbers with specific patterns, lucky digits, or numerology scores.',
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Easy Checkout',
      'description':
          'Secure payment options and seamless checkout process. Get your premium number delivered quickly.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    if (!mounted) return;

    // Navigate to login page
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          _pageController.animateToPage(
            state.currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // Skip Button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Skip'),
                    ),
                  ),

                  // Page View
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().goToPage(index);
                      },
                      itemBuilder: (context, index) {
                        return OnboardingPageWidget(
                          icon: _pages[index]['icon'] as IconData,
                          title: _pages[index]['title'] as String,
                          description: _pages[index]['description'] as String,
                        );
                      },
                    ),
                  ),

                  // Page Indicator
                  PageIndicator(
                    currentPage: state.currentPage,
                    totalPages: _pages.length,
                  ),
                  const SizedBox(height: 32),

                  // Bottom Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        if (state.currentPage > 0)
                          TextButton(
                            onPressed: () {
                              context.read<OnboardingCubit>().previousPage();
                            },
                            child: const Text('Back'),
                          )
                        else
                          const SizedBox(width: 60),

                        // Next/Get Started Button
                        ElevatedButton(
                          onPressed: () {
                            if (state.currentPage < _pages.length - 1) {
                              context.read<OnboardingCubit>().nextPage();
                            } else {
                              _completeOnboarding();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            state.currentPage < _pages.length - 1
                                ? 'Next'
                                : 'Get Started',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
