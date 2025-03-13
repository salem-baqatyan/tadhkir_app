import 'package:tadhkir_app/core/styles/Colors.dart';
import 'package:tadhkir_app/core/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget {
  final String tital;
  final void Function()? onBackPressed;
  final bool? isBack;
  final void Function()? onSearchPressed;
  final bool? isSearch;
  const CustomAppBar({
    super.key,
    required this.tital,
    this.onBackPressed,
    this.onSearchPressed,
    this.isBack = true,
    this.isSearch = true,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      height: 75.h,
      width: double.infinity.w,
      child: Stack(
        children: [
          isBack == true
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: InkWell(
                        onTap:
                            onBackPressed ?? () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.arrow_back_ios_sharp,
                          size: 25.w,
                        ),
                      )),
                )
              : const SizedBox.shrink(),
          Center(
            child: Text(
              tital,
              style: KTextStyle.textStyle20.copyWith(
                color: AppColors.blackDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
