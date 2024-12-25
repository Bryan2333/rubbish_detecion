import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAddressPicker extends StatefulWidget {
  final ValueChanged<Map<String, String>>? onAddressSelected;
  final Map<String, String>? initialAddress;

  const CustomAddressPicker(
      {super.key, this.onAddressSelected, this.initialAddress});

  @override
  State<CustomAddressPicker> createState() => _CustomAddressPickerState();
}

class _CustomAddressPickerState extends State<CustomAddressPicker> {
  final _addressData = <String, Map<String, List<String>?>>{};
  String _selectedProvince = "";
  String _selectedCity = "";
  String _selectedDistrict = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAddressData();
    });
  }

  Future<void> _loadAddressData() async {
    final data = await rootBundle.loadString('assets/cn-district.json');

    final map = jsonDecode(data);

    final provincesMap = map["86"] as Map<String, dynamic>;

    _addressData.addAll(provincesMap.map((provinceCode, provinceName) {
      final citiesMap = map[provinceCode] as Map<String, dynamic>;
      return MapEntry(provinceName as String,
          citiesMap.map((cityCode, cityName) {
        final areasMap = map[cityCode] as Map<String, dynamic>;
        final areas = areasMap.values
            .where((item) => item != "市辖区")
            .map((item) => item as String)
            .toList();
        return MapEntry(cityName as String, areas);
      }));
    }));

    setState(() {
      _isLoading = false;
    });
  }

  void _setInitialAddress() {
    final initProvince = widget.initialAddress?["province"] ?? "";
    final initCity = widget.initialAddress?["city"] ?? "";
    final initDistrict = widget.initialAddress?["district"] ?? "";

    setState(() {
      _selectedProvince =
          initProvince.isEmpty ? _addressData.keys.first : initProvince;

      _selectedCity = initCity.isEmpty
          ? _addressData[_selectedProvince]!.keys.first
          : initCity;

      _selectedDistrict = initDistrict.isEmpty
          ? _addressData[_selectedProvince]![_selectedCity]!.first
          : initDistrict;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_addressData.isNotEmpty) {
      _setInitialAddress();
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final cities = _addressData[_selectedProvince] ?? {};
        final districts = cities[_selectedCity] ?? [];

        return Container(
          height: 350.h,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("取消"),
                        ),
                        Text(
                          "选择地址",
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onAddressSelected?.call({
                              'province': _selectedProvince,
                              'city': _selectedCity,
                              'district': _selectedDistrict,
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("确定"),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: Row(
                        children: [
                          // 省
                          Expanded(
                            child: buildListWheelScrollView(
                              items: _addressData.keys.toList(),
                              selectedIndex: _addressData.keys
                                  .toList()
                                  .indexOf(_selectedProvince),
                              onChanged: (index) {
                                setState(() {
                                  _selectedProvince =
                                      _addressData.keys.toList()[index];
                                  _selectedCity =
                                      (_addressData[_selectedProvince] ?? {})
                                          .keys
                                          .first;
                                  _selectedDistrict =
                                      (_addressData[_selectedProvince] ??
                                              {})[_selectedCity]!
                                          .first;
                                });
                              },
                            ),
                          ),
                          // 市
                          Expanded(
                            child: buildListWheelScrollView(
                              items: cities.keys.toList(),
                              selectedIndex:
                                  cities.keys.toList().indexOf(_selectedCity),
                              onChanged: (index) {
                                setState(() {
                                  _selectedCity = cities.keys.toList()[index];
                                  _selectedDistrict =
                                      (_addressData[_selectedProvince] ??
                                              {})[_selectedCity]!
                                          .first;
                                });
                              },
                            ),
                          ),
                          // 区
                          Expanded(
                            child: buildListWheelScrollView(
                              items: districts,
                              selectedIndex:
                                  districts.indexOf(_selectedDistrict),
                              onChanged: (index) {
                                setState(() {
                                  _selectedDistrict = districts[index];
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget buildListWheelScrollView({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    final scrollController = FixedExtentScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (items.length > selectedIndex && selectedIndex >= 0) {
        scrollController.jumpToItem(selectedIndex);
      }
    });

    return ListWheelScrollView.useDelegate(
      controller: scrollController,
      itemExtent: 45.h,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                items[index],
                softWrap: true,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: index == selectedIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: index == selectedIndex ? Colors.blue : Colors.black,
                ),
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}
