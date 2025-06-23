import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../router/nav.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';

class ProfileImageFullScreenWidget extends ConsumerStatefulWidget {
  final String imageURL;

  const ProfileImageFullScreenWidget({
    super.key,
    required this.imageURL,
  });

  @override
  ConsumerState<ProfileImageFullScreenWidget> createState() => _ProfileImageFullScreenWidgetState();
}

class _ProfileImageFullScreenWidgetState extends ConsumerState<ProfileImageFullScreenWidget> {
  late ValueNotifier<int> _imageKeyNotifier;

  @override
  void initState() {
    super.initState();
    _imageKeyNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _imageKeyNotifier.dispose();
    super.dispose();
  }

  void _retryImage(String imageUrl) {
    CachedNetworkImageProvider(imageUrl).evict();
    _imageKeyNotifier.value++;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageURL;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(

            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: _imageKeyNotifier,
                builder: (context, keyValue, child) {
                  return CachedNetworkImage(
                    key: ValueKey('$imageUrl-$keyValue'),
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gradientGreen,
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              _retryImage(imageUrl);
                            },
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil.scaleHeight(context, 40),
            left: ScreenUtil.scaleWidth(context, 16),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                AppNavigation.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}