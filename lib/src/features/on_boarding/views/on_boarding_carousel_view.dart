import 'dart:async';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_cloudy_color_effect_widget.dart';
import '../../../utils/screen_utils.dart';
import '../../splash/providers/splash_provider.dart';
import '../providers/on_boarding__carousel_view_provider.dart';
import '../widgets/build_on_boarding_page_widget.dart';

class OnBoardingCarouselView extends ConsumerStatefulWidget {
  const OnBoardingCarouselView({super.key});

  @override
  ConsumerState<OnBoardingCarouselView> createState() => _OnBoardingCarouselViewState();
}

class _OnBoardingCarouselViewState extends ConsumerState<OnBoardingCarouselView> {
  late PageController _pageController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!ref.read(isUserInteractingProvider)) {
        final pages = ref.read(onboardingPagesProvider);
        final currentPage = ref.read(currentOnboardingPageProvider);
        int nextPage = (currentPage + 1) % pages.length; // Loop back to 0
        print('Auto-scroll: currentPage=$currentPage, nextPage=$nextPage');
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _skipOnboarding() {
    ref.read(onBoardingViewsProvider.notifier).onBoardingViewShownORSkipped();
    ref.read(splashProvider.notifier).checkAuthUser();
  }

  void _nextPage() {
    final pages = ref.read(onboardingPagesProvider);
    final currentPage = ref.read(currentOnboardingPageProvider);

    if (currentPage < pages.length - 1) {
      print('Next button: Moving to page ${currentPage + 1}');
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      );
    } else {
      print('Next button: Finishing onboarding');
      _skipOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(onboardingPagesProvider);
    final currentPage = ref.watch(currentOnboardingPageProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.gradientWhite,
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  ref.read(isUserInteractingProvider.notifier).state = true;
                } else if (notification is ScrollEndNotification) {
                  ref.read(isUserInteractingProvider.notifier).state = false;
                  _startAutoScroll();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  print('Page changed to: $index');
                  ref.read(currentOnboardingPageProvider.notifier).state = index;
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: BuildOnBoardingPageWidget(data: pages[index]),
                  );
                },
              ),
            ),

            // Global cloudy effect
            CustomCloudyColorEffectWidget.bottomRight(
              color: AppColors.gradientGreen,
              size: 200,
              intensity: 1,
              spreadRadius: 1,
            ),

            // Bottom controls
            Positioned(
              left: 0,
              right: 0,
              bottom: ScreenUtil.scaleHeight(context, 40),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: pages.length,
                    effect: WormEffect(
                      dotWidth: 10,
                      dotHeight: 10,
                      activeDotColor: AppColors.btnBgColor,
                      dotColor: AppColors.detailsTextColor.withOpacity(0.3),
                      spacing: 8,
                    ),
                  ),
                  30.height,
                  // Skip and Next buttons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil.scaleWidth(context, 20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButtonWidget(
                          text: AppStrings.skipBtnText,
                          height: ScreenUtil.scaleHeight(context, 50),
                          width: ScreenUtil.scaleWidth(context, 80),
                          backgroundColor: Colors.transparent,
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size16,
                          fontWeight: FontWeight.w500,
                          textColor: AppColors.detailsTextColor,
                          shadowColor: Colors.transparent,
                          onPressed: _skipOnboarding,
                        ),
                        CustomButtonWidget(
                          text: currentPage == pages.length - 1
                              ? "Let's Start"
                              : "Next",
                          height: ScreenUtil.scaleHeight(context, 50),
                          width: ScreenUtil.scaleWidth(context, 120),
                          backgroundColor: AppColors.btnBgColor,
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size16,
                          fontWeight: FontWeight.w700,
                          textColor: AppColors.gradientWhite,
                          onPressed: _nextPage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnBoardingPageData {
  final String image;
  final String title;
  final String description;
  final bool isGradientLeft;

  OnBoardingPageData({
    required this.image,
    required this.title,
    required this.description,
    required this.isGradientLeft,
  });
}