import 'package:tadhkir_app/core/styles/Colors.dart';
import 'package:tadhkir_app/core/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButtonWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final bool? isSolid;
  final double? width;
  final double? height;
  final void Function()? onTap;
  const ActionButtonWidget({
    super.key,
    required this.iconPath,
    required this.title,
    this.isSolid = true,
    this.onTap,
    this.width,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height!.h,
        width: width ?? double.infinity,
        decoration: isSolid == true
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: AppColors.primary,
                )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_alarm,
              color: isSolid == false ? AppColors.primary : AppColors.white,
              size: 25.w,
            ),
            SizedBox(
              width: 10.w,
            ),
            Text(
              title,
              style: isSolid == true
                  ? KTextStyle.textStyle13.copyWith(
                      color: AppColors.white,
                    )
                  : KTextStyle.textStyle12.copyWith(
                      color: AppColors.greyLight,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
