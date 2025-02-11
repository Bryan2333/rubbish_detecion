import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CustomTimePicker extends StatefulWidget {
  final ValueChanged<String>? onTimeSelected;
  final String? initialDateTime;

  const CustomTimePicker(
      {super.key, this.onTimeSelected, this.initialDateTime});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  int _selectedDayIndex = 0;
  int _selectedTimeSlotIndex = 0;

  late FixedExtentScrollController _timeSlotScrollController;

  final timeSlots = [
    "09:00~11:00",
    "11:00~13:00",
    "13:00~15:00",
    "15:00~17:00",
    "17:00~19:00",
  ];

  List<DateTime> _availableDays = [];

  @override
  void initState() {
    super.initState();
    _initializeAvailableDays();
    _parseInitialDateTime();
    _timeSlotScrollController =
        FixedExtentScrollController(initialItem: _selectedTimeSlotIndex);
  }

  @override
  void dispose() {
    _timeSlotScrollController.dispose();
    super.dispose();
  }

  void _initializeAvailableDays() {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 19);
    final startDayOffset = now.isAfter(todayEnd) ? 1 : 0;

    // 如果当前时间超过服务时间范围，从第二天开始
    _availableDays = List.generate(3,
        (index) => DateTime.now().add(Duration(days: index + startDayOffset)));
  }

  List<String> _getTodaySlot() {
    final regex = RegExp(r'(\d+):(\d+)~(\d+):(\d+)');
    final now = DateTime.now();
    return timeSlots.where((slot) {
      final match = regex.firstMatch(slot);
      final slotStartHour = int.parse(match!.group(1)!);
      final slotEndHour = int.parse(match.group(3)!);
      return (slotStartHour < now.hour && now.hour < slotEndHour) ||
          now.hour <= slotStartHour;
    }).toList();
  }

  void _parseInitialDateTime() {
    if (widget.initialDateTime == null) {
      return;
    }

    final regex = RegExp(r"(\d{2})月(\d{2})日 (\d{2}:\d{2}~\d{2}:\d{2})");
    final match = regex.firstMatch(widget.initialDateTime!);

    if (match == null) {
      return;
    }

    final initialMonth = int.parse(match.group(1)!);
    final initialDay = int.parse(match.group(2)!);
    final initialTimeSlot = match.group(3)!;

    final initialDate = _availableDays.firstWhereOrNull(
        (date) => date.month == initialMonth && date.day == initialDay);

    if (initialDate == null) {
      return;
    }

    _selectedDayIndex = _availableDays.indexOf(initialDate);

    final availableTimeSlots =
        (_selectedDayIndex == 0 && _availableDays[0].day == DateTime.now().day)
            ? _getTodaySlot()
            : timeSlots;

    _selectedTimeSlotIndex = availableTimeSlots.indexOf(initialTimeSlot);
  }

  @override
  Widget build(BuildContext context) {
    final availableTimeSlots =
        (_selectedDayIndex == 0 && _availableDays[0].day == DateTime.now().day)
            ? _getTodaySlot()
            : timeSlots;

    return Container(
      height: 350.h,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Column(
        children: [
          _buildHeader(availableTimeSlots),
          const Divider(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 日期选择
                _buildDatePicker(),
                SizedBox(width: 10.w),
                // 时间段选择
                _buildTimeSlotPicker(availableTimeSlots),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<String> availableTimeSlots) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("取消"),
        ),
        Text(
          "请选择时间",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        TextButton(
          onPressed: () {
            final selectedDate = _availableDays[_selectedDayIndex];
            final selectedSlot = availableTimeSlots[_selectedTimeSlotIndex];

            final formattedDate =
                DateFormat("MM月dd日", "zh_CN").format(selectedDate);
            final selectedDateTime = "$formattedDate $selectedSlot";

            widget.onTimeSelected?.call(selectedDateTime);
            Navigator.pop(context);
          },
          child: const Text("确定"),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Expanded(
      child: buildListWheelScrollView(
        items: _availableDays
            .map((date) => DateFormat('MM月dd日(EEE)', 'zh_CN').format(date))
            .toList(),
        selectedIndex: _selectedDayIndex,
        onChanged: (index) {
          setState(() {
            _selectedDayIndex = index;
            _selectedTimeSlotIndex = 0;
            _timeSlotScrollController.jumpToItem(0);
          });
        },
      ),
    );
  }

  Widget _buildTimeSlotPicker(List<String> availableTimeSlots) {
    return Expanded(
      child: buildListWheelScrollView(
        items: availableTimeSlots,
        selectedIndex: _selectedTimeSlotIndex,
        onChanged: (index) {
          setState(() {
            _selectedTimeSlotIndex = index;
          });
        },
      ),
    );
  }

  Widget buildListWheelScrollView({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    final scrollController = items == timeSlots || items == _getTodaySlot()
        ? _timeSlotScrollController
        : FixedExtentScrollController(initialItem: selectedIndex);

    return ListWheelScrollView.useDelegate(
      controller: scrollController,
      itemExtent: 40.h,
      onSelectedItemChanged: onChanged,
      physics: const FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          return Center(
            child: Text(
              items[index],
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: index == selectedIndex
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: index == selectedIndex ? Colors.blue : Colors.black,
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}
