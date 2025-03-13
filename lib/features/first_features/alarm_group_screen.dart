import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tadhkir_app/core/shered_widget/action_button_widget.dart';
import 'package:tadhkir_app/core/shered_widget/custom_app_bar.dart';
import 'package:tadhkir_app/core/styles/Colors.dart';
import 'package:tadhkir_app/core/styles/text_style.dart';
import 'package:tadhkir_app/core/utils/route.dart';
import 'package:tadhkir_app/sqldb.dart';
import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlarmGroupScreen extends StatefulWidget {
  const AlarmGroupScreen({super.key});

  @override
  State<AlarmGroupScreen> createState() => _AlarmGroupScreenState();
}

class _AlarmGroupScreenState extends State<AlarmGroupScreen> {
  SqlDb sqlDb = SqlDb();
  bool isLoading = true;
  List list = [];
  Time _time = Time(hour: 00, minute: 00, second: 00);
  String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  String selectedTime = '';

  @override
  void initState() {
    super.initState();
    readData();
    startTimer();
  }

  void startTimer() {
    Timer.run(() => print('timer count'));
    Timer(const Duration(seconds: 10), handleTimeout);
  }

  void handleTimeout() async {
    for (var i = 0; i < list.length; i++) {
      debugPrint('we wait 12 hours');
      if (currentTime == list[i]['time']) {
        int response = await sqlDb.updateData('''
          UPDATE Groups SET active = 0
          WHERE id = ${list[i]['id']} AND active = 1
      ''');
        if (response > 0) {
          readData();
          debugPrint('we wait 12 hours');
          scheduleReactivation(list[i]['id']);
        }
      }
    }
    startTimer();
  }

  void scheduleReactivation(int id) {
    debugPrint('we will wait 12 hours');
    Future.delayed(Duration(hours: 12), () async {
      int response = await sqlDb.updateData('''
        UPDATE Groups SET active = 1 
        WHERE id = $id AND active = 0
    ''');

      if (response > 0) {
        readData();
      }
    });
  }

  Future readData() async {
    list.clear();
    List<Map> response =
        await sqlDb.readData("SELECT * FROM Groups ORDER BY time ASC");
    debugPrint('response: $response');
    list.addAll(response);
    debugPrint('list: $list');
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future addData(Time newTime) async {
    DateTime now = DateTime.now();
    print('$newTime newTime');
    selectedTime = DateFormat('hh:mm a').format(DateTime(
      now.year,
      now.month,
      now.day,
      newTime.hour,
      newTime.minute,
      newTime.second,
    ));
    currentTime = DateFormat('hh:mm a').format(DateTime.now());
    print('$currentTime currentTime');
    print(selectedTime);

    list.clear;
    int response = await sqlDb.insertData('''
        INSERT INTO Groups (time , active)
        VALUES ("$selectedTime" , 1 )
                          ''');
    if (response > 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        'تم اضافة مجموعة تذكير بنجاح...',
      )));
      readData();
    }
  }

  Future updateData(Time newTime, int id) async {
    DateTime now = DateTime.now();
    selectedTime = DateFormat('hh:mm a').format(DateTime(
      now.year,
      now.month,
      now.day,
      newTime.hour,
      newTime.minute,
      newTime.second,
    ));
    list.clear;
    int response = await sqlDb.updateData('''
        UPDATE Groups SET
        time = "$selectedTime",
        active = 1
        WHERE id = $id
                            ''');
    if (response > 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        'تم تعديل مجموعة تذكير بنجاح...',
      )));
      readData();
    }
  }

  Future<void> deleteData(int id) async {
    list.clear(); // Fix: Call clear() as a function
    // Delete contacts first to avoid foreign key issues
    int responseContacts =
        await sqlDb.deleteData("DELETE FROM Contacts WHERE group_id = $id");
    int responseGroup =
        await sqlDb.deleteData("DELETE FROM Groups WHERE id = $id");

    // Check if any deletion was successful
    if (responseGroup > 0 || responseContacts > 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم حذف مجموعة تذكير بنجاح...'),
        ));
      }
      list.removeWhere((element) => element['id'] == id);
      readData();
    }
  }

  deleteAll() async {
    await sqlDb.deleteData("DELETE FROM Groups ");
    list.clear();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        color: AppColors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteName.ktest,
                );
              },
              child: const CustomAppBar(
                tital: 'مجموعات التذكير',
                isBack: false,
              ),
            ),
            SizedBox(height: 30.h),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: ActionButtonWidget(
                  title: 'إضافة مجموعة',
                  iconPath: 'assets/add.svg',
                  onTap: () {
                    Navigator.of(context).push(
                      showPicker(
                        iosStylePicker: true,
                        context: context,
                        value: _time,
                        onChange: (Time newTime) {
                          setState(() {
                            _time = newTime;
                          });
                          addData(newTime);
                          _time = Time(hour: 00, minute: 00, second: 00);
                        },
                        minuteInterval: TimePickerInterval.ONE,
                      ),
                    );
                  },
                )),
            SizedBox(height: 10.h),
            isLoading == true
                ? const Expanded(child: CircularProgressIndicator())
                : list.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            "لا توجد اي مجموعة تذكير حاليا...",
                            style: KTextStyle.textStyle18.copyWith(
                              color: AppColors.blackDark,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: list.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, RouteName.kcontact,
                                          arguments: {
                                            'time': list[i]['time'],
                                            'group_id': list[i]['id'],
                                            'active': list[i]['active'],
                                          });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: list[i]['active'] == 1
                                              ? AppColors.grey
                                              : AppColors.greyLight,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: AppColors.greyBorder,
                                          )),
                                      alignment: Alignment.center,
                                      height: 150,
                                      width: double.infinity,
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: InkWell(
                                                onTap: () {
                                                  deleteData(list[i]['id']);
                                                },
                                                child: const CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  child: Icon(
                                                    Icons.delete_forever,
                                                    color: AppColors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "مجموعة تذكير ساعة:",
                                                  style: KTextStyle.textStyle14
                                                      .copyWith(
                                                    color: AppColors.greyDark,
                                                  ),
                                                ),
                                                InkWell(
                                                    onDoubleTap: () {
                                                      DateTime parsedTime =
                                                          DateFormat('hh:mm a')
                                                              .parse(list[i]
                                                                  ['time']);
                                                      Time initTime = Time(
                                                        hour: parsedTime.hour,
                                                        minute:
                                                            parsedTime.minute,
                                                        second: 0,
                                                      );

                                                      Navigator.of(context)
                                                          .push(
                                                        showPicker(
                                                          iosStylePicker: true,
                                                          context: context,
                                                          value: initTime,
                                                          onChange:
                                                              (Time newTime) {
                                                            setState(() {
                                                              _time = newTime;
                                                            });
                                                            updateData(newTime,
                                                                list[i]['id']);
                                                          },
                                                          minuteInterval:
                                                              TimePickerInterval
                                                                  .ONE,
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: list[i]
                                                                  ['active'] ==
                                                              1
                                                          ? const BoxDecoration(
                                                              color: AppColors
                                                                  .white)
                                                          : null,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Text(
                                                          '${list[i]['time']}',
                                                          style: KTextStyle
                                                              .textStyle20
                                                              .copyWith(
                                                            color: AppColors
                                                                .blackDark,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
            SizedBox(height: 10.h),
            // ActionButtonWidget(
            //   width: 150,
            //   title: 'انتقال الى اختبار',
            //   iconPath: 'assets/add.svg',
            //   onTap: () {
            //     Navigator.pushNamed(context, RouteName.ktest);
            //   },
            // ),
            // SizedBox(height: 10.h),
          ],
        ),
      )),
    );
  }
}
