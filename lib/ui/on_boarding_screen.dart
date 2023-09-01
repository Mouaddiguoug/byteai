import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byteai/controller/on_boarding_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/ui/auth/login_screen.dart';
import 'package:byteai/utils/Preferences.dart';
import 'package:sizer/sizer.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<OnBoardingController>(
      init: OnBoardingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.background,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.selectedPageIndex,
                      itemCount: controller.onBoardingList.length,
                      itemBuilder: (context, index) {
                        return Stack(

                          children: [
                            Positioned(

                              left: -40.w,
                              right: -40.w,
                              bottom: 0,
                              top: 6.h,
                              child: Image.asset(
                                controller.onBoardingList[index].imageAsset
                                    .toString(),
                                width: 200.w,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.sp),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        controller.onBoardingList[index].heading
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Text(
                                        controller.onBoardingList[index].title
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white, letterSpacing: 1),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF060C18),
                                            blurRadius: 4,
                                            offset: Offset(4, 4),
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color: Color(0x7F3A445D),
                                            blurRadius: 4,
                                            offset: Offset(-4, -4),
                                            spreadRadius: 0,
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ElevatedButton(

                                        onPressed: () {
                                          Preferences.setBoolean(
                                              Preferences.isFinishOnBoardingKey,
                                              true);
                                          Get.off(const LoginScreen(
                                            redirectType: "",
                                          ));
                                        },
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              // the border color and width
                                            ),
                                          ),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color(0xff060A33)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 75.0, vertical: 20),
                                          child: Text('Skip'.tr,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                      width: 80.w,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.onBoardingList.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width:
                        controller.selectedPageIndex.value == index ? 28 : 8,
                    height: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
