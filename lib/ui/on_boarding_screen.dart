import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byteai/controller/on_boarding_controller.dart';
import 'package:byteai/theam/constant_colors.dart';
import 'package:byteai/ui/auth/login_screen.dart';
import 'package:byteai/utils/Preferences.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<OnBoardingController>(
      init: OnBoardingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.background,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                AssetImage("assets/images/anotherbg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: PageView.builder(
                          controller: controller.pageController,
                          onPageChanged: controller.selectedPageIndex,
                          itemCount: controller.onBoardingList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
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
                                  height: 30,
                                ),
                                Text(
                                  controller.onBoardingList[index].title
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white, letterSpacing: 1),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Center(
                                    child: Image.asset(
                                      controller.onBoardingList[index].imageAsset
                                          .toString(),

                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: LinearGradient(

                                        begin: FractionalOffset.centerLeft,
                                        end: FractionalOffset.centerRight,

                                        colors: [
                                          Color(0xFF601A81),
                                          Color.fromRGBO(14, 111, 117, 0.479167),
                                          Color.fromRGBO(49, 26, 189, 0),
                                        ],
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Preferences.setBoolean(
                                            Preferences.isFinishOnBoardingKey, true);
                                        Get.off(const LoginScreen(
                                          redirectType: "",
                                        ));
                                      },

                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<OutlinedBorder>(

                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as desired
                                            side: BorderSide(color: Colors.purple, width: 2.0), // Set the border color and width
                                          ),

                                        ),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                         ),

                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 75.0, vertical: 20),
                                        child: Text('Skip'.tr,
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
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
                          width: controller.selectedPageIndex.value == index
                              ? 28
                              : 8,
                          height: 10,
                      ),
                    ),
                  ),



                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
