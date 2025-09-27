import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/no_internet_animation.json',
                width: 260.w,
                fit: BoxFit.contain,
              ),
              24.verticalSpace,
              Text(
                'No Internet Connection',
                style: getBoldStyle(
                    fontSize: FontSize.s22, color: ColorManager.black),
                textAlign: TextAlign.center,
              ),
              12.verticalSpace,
              Text(
                'Please check your internet settings and try again.',
                style: getRegularStyle(
                  fontSize: FontSize.s16,
                  color: Colors.grey[700]!,
                ),
                textAlign: TextAlign.center,
              ),
              32.verticalSpace,
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: AppSize.s28),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
