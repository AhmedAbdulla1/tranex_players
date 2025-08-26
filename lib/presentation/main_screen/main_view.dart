import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'main_view_model.dart';
import 'screens/dashboard/view.dart';
import 'screens/training/view.dart';
import 'screens/profile/view.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final MainViewModel _viewModel = instance<MainViewModel>();

  @override
  void initState() {
    _viewModel.start();
    super.initState();
  }

  final List<Widget> screens = <Widget>[
    const DashboardView(),
    const TrainingView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          // Portrait Mode: استخدام BottomNavigationBar
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: StreamBuilder<int>(
                stream: _viewModel.outIndex,
                builder: (context, snapshot) => screens[snapshot.data ?? 0],
              ),
            ),
            bottomNavigationBar: StreamBuilder<int>(
              stream: _viewModel.outIndex,
              builder: (context, snapshot) => CurvedNavigationBar(
                iconPadding: AppPadding.p14.h,
                backgroundColor: Colors.transparent,
                color: ColorManager.simiBlack,
                buttonBackgroundColor: ColorManager.simiBlack,
                height: AppSize.s65,
                index: snapshot.data ?? 0,
                onTap: (index) {
                  _viewModel.setIndex(index);
                },
                animationDuration: const Duration(
                  milliseconds: 500,
                ),
                items: [
                  CurvedNavigationBarItem(
                    child: Icon(
                      Icons.dashboard_sharp,
                      color: ColorManager.white,
                    ),
                    label: "DashBoard",
                    labelStyle: TextStyle(
                      color: ColorManager.white,
                    ),
                  ),
                  CurvedNavigationBarItem(
                    child: Icon(
                      Icons.model_training_outlined,
                      color: ColorManager.white,
                    ),
                    label: "Training",
                    labelStyle: TextStyle(
                      color: ColorManager.white,
                    ),
                  ),
                  CurvedNavigationBarItem(
                    child: Icon(
                      Icons.person_2_rounded,
                      color: ColorManager.white,
                    ),
                    label: "Profile",
                    labelStyle: TextStyle(
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Landscape Mode: استخدام Row مع Navigation على الشمال
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              right: false,
              left: false,
              child: Row(
                children: [
                  // Navigation على الجانب الأيسر
                  Container(
                    width: 100, // عرض ثابت للـ Navigation
                    color: ColorManager.simiBlack,
                    child: StreamBuilder<int>(
                      stream: _viewModel.outIndex,
                      builder: (context, snapshot) {
                        final currentIndex = snapshot.data ?? 0;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildNavItem(
                              icon: Icons.dashboard_sharp,
                              label: "DashBoard",
                              index: 0,
                              isSelected: currentIndex == 0,
                            ),
                            _buildNavItem(
                              icon: Icons.model_training_outlined,
                              label: "Training",
                              index: 1,
                              isSelected: currentIndex == 1,
                            ),
                            _buildNavItem(
                              icon: Icons.person_2_rounded,
                              label: "Profile",
                              index: 2,
                              isSelected: currentIndex == 2,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // الشاشة الرئيسية على اليمين
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: _viewModel.outIndex,
                      builder: (context, snapshot) =>
                      screens[snapshot.data ?? 0],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // ويدجت مخصصة لعنصر الـ Navigation في الـ Landscape Mode
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        _viewModel.setIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        margin: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? ColorManager.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: ColorManager.white,
              size: 24,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: ColorManager.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}