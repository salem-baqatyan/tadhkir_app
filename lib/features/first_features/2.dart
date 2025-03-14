// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tadhkir_app/core/shered_widget/action_button_widget.dart';
// import 'package:tadhkir_app/core/shered_widget/custom_app_bar.dart';
// import 'package:tadhkir_app/core/styles/Colors.dart';
// import 'package:tadhkir_app/core/styles/text_style.dart';
// import 'package:tadhkir_app/core/utils/route.dart';
// import 'package:tadhkir_app/core/providers/alarm_group_provider.dart';
// import 'package:day_night_time_picker/day_night_time_picker.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:tadhkir_app/notification_service.dart';

// class AlarmGroupScreen extends StatelessWidget {
//   const AlarmGroupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             const CustomAppBar(
//               tital: 'مجموعات التذكير',
//               isBack: false,
//             ),
//             SizedBox(height: 30.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 30.w),
//               child: ActionButtonWidget(
//                 title: 'إضافة مجموعة',
//                 iconPath: 'assets/add.svg',
//                 onTap: () {
//                   Time _time = Time(hour: 00, minute: 00, second: 00);
//                   Navigator.of(context).push(
//                     showPicker(
//                       iosStylePicker: true,
//                       context: context,
//                       value: _time,
//                       onChange: (Time newTime) async {
//                         String formattedTime = DateFormat('hh:mm a').format(
//                           DateTime(0, 0, 0, newTime.hour, newTime.minute),
//                         );

//                         int groupId = await Provider.of<AlarmGroupProvider>(
//                           context,
//                           listen: false,
//                         ).sqlDb.insertData('''
//                           INSERT INTO Groups (time, active) VALUES ('$formattedTime', 1)
//                         ''');

//                         NotificationService.scheduleNotification(
//                           groupId,
//                           newTime.hour,
//                           newTime.minute,
//                           context,
//                         );
//                         Provider.of<AlarmGroupProvider>(context, listen: false)
//                             .loadGroups();
//                       },
//                       minuteInterval: TimePickerInterval.ONE,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 10.h),
//             Expanded(
//               child: Consumer<AlarmGroupProvider>(
//                 builder: (context, provider, child) {
//                   if (provider.isLoading) {
//                     return const CircularProgressIndicator();
//                   }

//                   if (provider.groups.isEmpty) {
//                     return Center(
//                       child: Text(
//                         "لا توجد أي مجموعة تذكير حاليًا...",
//                         style: KTextStyle.textStyle18.copyWith(
//                           color: AppColors.blackDark,
//                         ),
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     itemCount: provider.groups.length,
//                     itemBuilder: (context, i) {
//                       return Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 30.w),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: provider.groups[i]['active'] == 1
//                                 ? AppColors.grey
//                                 : AppColors.greyLight,
//                             borderRadius: BorderRadius.circular(5),
//                             border: Border.all(color: AppColors.greyBorder),
//                           ),
//                           height: 150,
//                           child: Center(
//                             child: Text(
//                               provider.groups[i]['time'],
//                               style: KTextStyle.textStyle20.copyWith(
//                                 color: AppColors.blackDark,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
