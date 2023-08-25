import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'responsive.dart';

class ButtonThem {
  const ButtonThem({Key? key});

  static buildButton(
    BuildContext context, {
    required String title,
    required Color btnColor,
    required Color txtColor,
    double btnHeight = 50,
    double txtSize = 16,
    double btnWidthRatio = 0.9,
    required Function() onPress,
    bool isVisible = true,
  }) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: Responsive.width(100, context) * btnWidthRatio,
        child: MaterialButton(
          onPressed: onPress,
          height: btnHeight,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: btnColor,
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: txtColor,
                fontSize: txtSize,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  static buildBorderButton(
    BuildContext context, {
    required String title,
    required Color btnColor,
    required Color btnBorderColor,
    required Color txtColor,
    double btnHeight = 50,
    double txtSize = 14,
    double btnWidthRatio = 0.9,
    required Function() onPress,
    bool isVisible = true,
    bool iconVisibility = false,
    String iconAssetImage = '',
  }) {
    return Visibility(
      visible: isVisible,
      child: Container(
        width: 100.w,
        height: btnHeight,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                // border of the button
                borderRadius: BorderRadius.circular(10.0),
                // Adjust border radius as needed
                side: BorderSide(
                  color: btnColor, // Border color
                  width: 2.0, // Border width
                ),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all(btnColor),
            foregroundColor:
                MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: onPress,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: iconVisibility,
                child: Stack(children: [
                  Container(
                    width: 40, // Adjust container width as needed
                    height: 30, // Adjust container height as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Circular white background
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 30,
                    child: Image.asset(iconAssetImage,
                        fit: BoxFit.cover, width: 32),
                  ),
                ]),
              ),
              FittedBox(
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                      color: txtColor,
                      fontSize: txtSize,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static buildIconButton(
    BuildContext context, {
    required String title,
    required Color btnColor,
    required Color txtColor,
    required Color iconColor,
    required IconData icon,
    double btnHeight = 50,
    double txtSize = 20,
    double btnWidthRatio = 0.9,
    iconSize = 18.0,
    required Function() onPress,
    bool isVisible = true,
  }) {
    return Visibility(
      visible: isVisible,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: SizedBox(
          width: Responsive.width(90, context) * btnWidthRatio,
          height: btnHeight,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: btnColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            onPressed: onPress,
            label: Text(
              title,
              style: TextStyle(color: txtColor, fontSize: txtSize),
            ),
            icon: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
