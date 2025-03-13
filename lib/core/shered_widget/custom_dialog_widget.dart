import 'package:tadhkir_app/core/styles/Colors.dart';
import 'package:tadhkir_app/core/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDialogWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final bool? isWarning;
  final bool? isLoading;
  final Widget? iconPath;
  const CustomDialogWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
    this.iconPath,
    this.isWarning = true,
    this.isLoading = false,
    this.confirmText,
    this.cancelText,
  });

  @override
  State<CustomDialogWidget> createState() => _CustomDialogWidgetState();
}

class _CustomDialogWidgetState extends State<CustomDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: 382.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.cancel_sharp,
                  color: Colors.grey,
                  size: 24.sp,
                ),
              ),
            ),
            const SizedBox(height: 16),
            widget.isWarning == true
                ? CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.redOpacity,
                    child: widget.iconPath,
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.greenOpacity,
                    child: widget.iconPath),
            const SizedBox(height: 16),
            // Title
            Text(
              widget.title,
              style: KTextStyle.textStyle18.copyWith(
                color: AppColors.blackDark,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              widget.subtitle,
              style: KTextStyle.textStyle16.copyWith(
                color: AppColors.greyLight,
              ),
            ),
            const SizedBox(height: 25),
            // Action Buttons
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Confirm Button
                  InkWell(
                      onTap: widget.onConfirm,
                      child: Container(
                        alignment: Alignment.center,
                        height: 40.h,
                        width: 130.w,
                        decoration: BoxDecoration(
                            color: widget.isWarning == true
                                ? AppColors.redOpacity
                                : AppColors.greenOpacity,
                            borderRadius: BorderRadius.circular(10)),
                        child: widget.isLoading == false
                            ? Text(widget.confirmText ?? 'نعم , متابعة الحذف',
                                style: KTextStyle.textStyle13.copyWith(
                                  color: widget.isWarning == true
                                      ? AppColors.redDark
                                      : Colors.green,
                                ))
                            : CircleAvatar(
                                backgroundColor: AppColors.transparent,
                                child: CircularProgressIndicator(
                                  strokeAlign: -2,
                                  color: widget.isWarning == true
                                      ? AppColors.redDark
                                      : Colors.green,
                                )),
                      )),
                  // Cancel Button
                  InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                          alignment: Alignment.center,
                          height: 40.h,
                          width: 130.w,
                          decoration: BoxDecoration(
                              color: AppColors.blueOpacity,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(widget.cancelText ?? 'لا , إلغاء العملية',
                              style: KTextStyle.textStyle13.copyWith(
                                color: AppColors.blueDark,
                              )))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
