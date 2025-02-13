import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';

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

  Map<String, List<String>?> _currentCities = {};
  List<String> _currentDistricts = [];

  late final FixedExtentScrollController _provinceScrollController;
  late final FixedExtentScrollController _cityScrollController;
  late final FixedExtentScrollController _districtScrollController;

  @override
  void initState() {
    super.initState();
    _provinceScrollController = FixedExtentScrollController();
    _cityScrollController = FixedExtentScrollController();
    _districtScrollController = FixedExtentScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAddressData();
    });
  }

  @override
  void dispose() {
    _provinceScrollController.dispose();
    _cityScrollController.dispose();
    _districtScrollController.dispose();
    super.dispose();
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
      _setInitialAddress();
    });
  }

  void _setInitialAddress() {
    final initProvince = widget.initialAddress?["province"] ?? "";
    final initCity = widget.initialAddress?["city"] ?? "";
    final initDistrict = widget.initialAddress?["district"] ?? "";

    final provinces = _addressData.keys.toList();
    final initialProvinceIndex =
        initProvince.isEmpty ? 0 : provinces.indexOf(initProvince);

    setState(() {
      _selectedProvince = provinces[initialProvinceIndex];
      _currentCities = _addressData[_selectedProvince] ?? {};

      final cities = _currentCities.keys.toList();
      final initialCityIndex = initCity.isEmpty ? 0 : cities.indexOf(initCity);
      _selectedCity = cities.isEmpty ? "" : cities[initialCityIndex];

      _currentDistricts = _currentCities[_selectedCity] ?? [];
      final initialDistrictIndex =
          initDistrict.isEmpty ? 0 : _currentDistricts.indexOf(initDistrict);
      _selectedDistrict = _currentDistricts.isEmpty
          ? ""
          : _currentDistricts[initialDistrictIndex];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provinceScrollController.jumpToItem(initialProvinceIndex);
      if (_currentCities.isNotEmpty) {
        _cityScrollController.jumpToItem(initCity.isEmpty
            ? 0
            : _currentCities.keys.toList().indexOf(initCity));
      }
      if (_currentDistricts.isNotEmpty) {
        _districtScrollController.jumpToItem(
            initDistrict.isEmpty ? 0 : _currentDistricts.indexOf(initDistrict));
      }
    });
  }

  void _updateSelection(String selected, bool isProvince) {
    if (isProvince) {
      final newCities = _addressData[selected] ?? {};
      final firstCity = newCities.keys.firstOrNull ?? "";
      final newDistricts = newCities[firstCity] ?? [];

      setState(() {
        _currentCities = newCities;
        _selectedCity = firstCity;
        _currentDistricts = newDistricts;
        _selectedDistrict = newDistricts.firstOrNull ?? "";
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cityScrollController.jumpToItem(0);
        _districtScrollController.jumpToItem(0);
      });
    } else {
      final newDistricts = _currentCities[selected] ?? [];
      setState(() {
        _currentDistricts = newDistricts;
        _selectedDistrict = newDistricts.firstOrNull ?? "";
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _districtScrollController.jumpToItem(0);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350.h,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: _isLoading
          ? CustomHelper.progressIndicator
          : Column(
              children: [
                _buildHeader(),
                const Divider(),
                Expanded(child: _buildPickerRow()),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("取消"),
        ),
        Text(
          "选择地址",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        TextButton(
          onPressed: _handleConfirm,
          child: const Text("确定"),
        ),
      ],
    );
  }

  void _handleConfirm() {
    widget.onAddressSelected?.call({
      'province': _selectedProvince,
      'city': _selectedCity,
      'district': _selectedDistrict,
    });
    Navigator.pop(context);
  }

  Widget _buildPickerRow() {
    return Row(
      children: [
        Expanded(child: _buildProvincesPicker()),
        Expanded(child: _buildCitiesPicker()),
        Expanded(child: _buildAreaPicker()),
      ],
    );
  }

  Widget _buildProvincesPicker() {
    final provinces = _addressData.keys.toList();
    return _buildListWheelScrollView(
      items: provinces,
      selectedIndex: provinces.indexOf(_selectedProvince),
      onChanged: (index) {
        final newProvince = provinces[index];
        if (newProvince != _selectedProvince) {
          setState(() {
            _selectedProvince = newProvince;
          });
          _updateSelection(newProvince, true);
        }
      },
      scrollController: _provinceScrollController,
    );
  }

  Widget _buildCitiesPicker() {
    final cityList = _currentCities.keys.toList();
    return _buildListWheelScrollView(
      items: cityList,
      selectedIndex: cityList.indexOf(_selectedCity),
      onChanged: (index) {
        final newCity = cityList[index];
        if (newCity != _selectedCity) {
          setState(() {
            _selectedCity = newCity;
          });
          _updateSelection(newCity, false);
        }
      },
      scrollController: _cityScrollController,
    );
  }

  Widget _buildAreaPicker() {
    return _buildListWheelScrollView(
      items: _currentDistricts,
      selectedIndex: _currentDistricts.indexOf(_selectedDistrict),
      onChanged: (index) {
        setState(() {
          _selectedDistrict = _currentDistricts[index];
        });
      },
      scrollController: _districtScrollController,
    );
  }

  Widget _buildListWheelScrollView({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    required FixedExtentScrollController scrollController,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: scrollController,
      itemExtent: 45.h,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                items[index],
                softWrap: true,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: index == selectedIndex
                      ? FontWeight.w600
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
