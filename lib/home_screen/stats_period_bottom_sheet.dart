import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/home_screen/overview/bloc/statistic_bloc.dart';

class StatsPeriodBottomSheet extends StatefulWidget {
  final StatsTimePeriod selectedItem;

  StatsPeriodBottomSheet({this.selectedItem = StatsTimePeriod.Last7Days});

  @override
  _StatsPeriodBottomSheetState createState() => _StatsPeriodBottomSheetState();
}

class _StatsPeriodBottomSheetState extends State<StatsPeriodBottomSheet> {
  final Color watermelon = Color.fromRGBO(253, 68, 104, 1);
  StatsTimePeriod selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = this.widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    var height20 = hp(20);
    var height56 = hp(56);
    var width20 = wp(20);

    return XedSheets.bottomSheet(
        context,
        core.Config.getString("msg_ask_time_period"),
        SafeArea(
          child: Container(
            margin:
                EdgeInsets.symmetric(vertical: height20, horizontal: width20),
            child: Wrap(
              children: <Widget>[
                RadioListTile<StatsTimePeriod>(
                  groupValue: selectedItem,
                  value: StatsTimePeriod.Today,
                  onChanged: (StatsTimePeriod value) => XError.f0(() {
                    setState(() {
                      selectedItem = value;
                    });
                  }),
                  title: Text(
                    "Today",
                    style: SemiBoldTextStyle(14).copyWith(
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  activeColor: Colors.black,
                ),
                RadioListTile<StatsTimePeriod>(
                  groupValue: selectedItem,
                  value: StatsTimePeriod.Last3Days,
                  onChanged: (StatsTimePeriod value) => XError.f0(() {
                    setState(() {
                      selectedItem = value;
                    });
                  }),
                  title: Text(
                    "Last 3 days",
                    style: SemiBoldTextStyle(14).copyWith(
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  activeColor: Colors.black,
                ),
                RadioListTile(
                  groupValue: selectedItem,
                  value: StatsTimePeriod.Last7Days,
                  onChanged: (StatsTimePeriod value) => XError.f0(() {
                    setState(() {
                      selectedItem = value;
                    });
                  }),
                  activeColor: Colors.black,
                  title: Text(
                    "Last 7 days",
                    style: SemiBoldTextStyle(14).copyWith(
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
                RadioListTile(
                  groupValue: selectedItem,
                  value: StatsTimePeriod.Last30Days,
                  onChanged: (StatsTimePeriod value) => XError.f0(() {
                    setState(() {
                      selectedItem = value;
                    });
                  }),
                  title: Text(
                    "Last 30 days",
                    style: SemiBoldTextStyle(14).copyWith(
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  activeColor: Colors.black,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  )),
                  height: height56,
                  child: XedButtons.watermelonButton(
                    "Ok",
                    10,
                    18,
                    _onOkPressed,
                    width: wp(335),
                    height: hp(56),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void _onOkPressed() {
    if (selectedItem != null)
      Navigator.pop(context, selectedItem);
    else
      Navigator.pop(context);
  }
}
