import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../providers/settings_providers.dart';

class CustomToggleSwitchWidget extends ConsumerWidget {
  final String userId;
  final SwitchType switchType;
  final BuildContext context;

  const CustomToggleSwitchWidget({
    super.key,
    required this.userId,
    required this.switchType,
    required this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final switchState = ref.watch(
      switchType == SwitchType.chat
          ? chatSwitchProvider((userId: userId, context: context))
          : callSwitchProvider((userId: userId, context: context)),
    );

    return GestureDetector(
      onTap: switchState.isLoading
          ? null
          : () {
        ref
            .read(
          switchType == SwitchType.chat
              ? chatSwitchProvider((userId: userId, context: context)).notifier
              : callSwitchProvider((userId: userId, context: context)).notifier,
        )
            .toggle();
      },
      child: Container(
        width: ScreenUtil.scaleWidth(context, 50),
        height: ScreenUtil.scaleHeight(context,30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.gradientGreen,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: switchState.isEnabled ? 25 : 4,
                end: switchState.isEnabled ? 25 : 4,
              ),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Positioned(
                  left: value,
                  top: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: switchState.isEnabled
                          ? AppColors.black
                          : AppColors.gradientWhite,
                    ),
                    child: Center(
                      child: switchState.isLoading
                          ? const CupertinoActivityIndicator(
                        radius: 8,
                        color: AppColors.switchToggleIcColor,
                      )
                          : Icon(
                        switchType == SwitchType.chat
                            ? (switchState.isEnabled
                            ? Icons.chat
                            : Icons.chat_bubble_outline)
                            : (switchState.isEnabled
                            ? Icons.call
                            : Icons.call_outlined),
                        color: AppColors.switchToggleIcColor,
                        size: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}