import 'dart:async';

import 'package:city_pickers/src/base/base.dart';
import 'package:city_pickers/src/cities_selector/cities_selector.dart';
import 'package:city_pickers/src/cities_selector/utils.dart';
import 'package:city_pickers/src/full_page/full_page.dart';
import 'package:city_pickers/src/utils/index.dart';
import 'package:flutter/material.dart';

import './util.dart';
import '../meta/province.dart' as meta;
import 'mod/picker_popup_route.dart';
import 'show_types.dart';

class CityPickers {
  /// static original city data for this plugin
  static Map<String, dynamic> metaCities = meta.citiesData;

  /// static original province data for this plugin
  static Map<String, String> metaProvinces = meta.provincesData;

  static CityPickerUtil utils(
      {Map<String, String>? provinceData, Map<String, dynamic>? citiesData}) {
    debugPrint("CityPickers.metaProvinces::: ${CityPickers.metaCities}");
    return CityPickerUtil(
      provincesData: provinceData ?? CityPickers.metaProvinces,
      citiesData: citiesData ?? CityPickers.metaCities,
    );
  }

  static Future<dynamic> showCityPicker(
      {required BuildContext? context,
      showType = ShowType.pca,
      double height = 400.0,
      String locationCode = '110000',
      ThemeData? theme,
      Map<String, dynamic>? citiesData,
      Map<String, String>? provincesData,
      // CityPickerRoute params
      bool barrierDismissible = true,
      double barrierOpacity = 0.6,
      ItemWidgetBuilder? itemBuilder,
      double? itemExtent,
      Widget? cancelWidget,
      Widget? confirmWidget,
      Widget? titleWidget,
      bool isSort = false,
      String area = ""}) {
    return Navigator.of(context!, rootNavigator: true).push(
      CityPickerRoute(
          theme: theme ?? Theme.of(context),
          canBarrierDismiss: barrierDismissible,
          barrierOpacity: barrierOpacity,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          child: BaseView(
            isSort: isSort,
            showType: showType,
            height: height,
            itemExtent: itemExtent,
            itemBuilder: itemBuilder,
            cancelWidget: cancelWidget,
            confirmWidget: confirmWidget,
            titleWidget: titleWidget,
            citiesData: citiesData ?? meta.citiesData,
            provincesData: provincesData ?? meta.provincesData,
            locationCode: locationCode,
            area: area,
          )),
    );
  }

  /// @theme Theme used it's primaryColor
  static Future<dynamic> showFullPageCityPicker({
    required BuildContext? context,
    ThemeData? theme,
    ShowType showType = ShowType.pca,
    String locationCode = '110000',
    Map<String, dynamic>? citiesData,
    Map<String, String>? provincesData,
  }) {
    return Navigator.push(
        context!,
        PageRouteBuilder(
          settings: RouteSettings(name: 'fullPageCityPicker'),
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, _, __) => Theme(
              data: theme ?? Theme.of(context),
              child: FullPage(
                showType: showType,
                locationCode: locationCode,
                citiesData: citiesData ?? meta.citiesData,
                provincesData: provincesData ?? meta.provincesData,
              )),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) =>
                  SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.0, 1.0),
                        end: Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child),
        ));
  }

  static Future<dynamic> showCitiesSelector({
    required BuildContext? context,
    ThemeData? theme,
    bool? showAlpha,
    String? locationCode,
    String title = '城市选择器',
    Map<String, dynamic> citiesData = meta.citiesData,
    Map<String, String> provincesData = meta.provincesData,
    List<HotCity>? hotCities,
    BaseStyle? sideBarStyle,
    BaseStyle? cityItemStyle,
    BaseStyle? topStickStyle,
  }) {
    BaseStyle sideBarStyleResolved = BaseStyle(
        fontSize: 14,
        color: defaultTagFontColor,
        activeColor: defaultTagActiveBgColor,
        backgroundColor: defaultTagBgColor,
        backgroundActiveColor: defaultTagActiveBgColor);
    sideBarStyleResolved = sideBarStyleResolved.merge(sideBarStyle!);

    BaseStyle cityItemStyleResolved = BaseStyle(
      fontSize: 12,
      color: Colors.black,
      activeColor: Colors.red,
    );
    cityItemStyleResolved = cityItemStyleResolved.merge(cityItemStyle!);

    BaseStyle topStickStyleResolved = BaseStyle(
        fontSize: 16,
        height: 40,
        color: defaultTopIndexFontColor,
        backgroundColor: defaultTopIndexBgColor);

    topStickStyleResolved = topStickStyleResolved.merge(topStickStyle!);
    return Navigator.push(
        context!,
        PageRouteBuilder(
          settings: RouteSettings(name: 'CitiesPicker'),
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, _, __) => Theme(
              data: theme ?? Theme.of(context),
              child: CitiesSelector(
                  title: title,
                  provincesData: provincesData,
                  citiesData: citiesData,
                  hotCities: hotCities,
                  locationCode: locationCode,
                  tagBarActiveColor: sideBarStyleResolved.backgroundActiveColor!,
                  tagBarFontActiveColor: sideBarStyleResolved.activeColor!,
                  tagBarBgColor: sideBarStyleResolved.backgroundColor!,
                  tagBarFontColor: sideBarStyleResolved.color!,
                  tagBarFontSize: sideBarStyleResolved.fontSize!,
                  topIndexFontSize: topStickStyleResolved.fontSize!,
                  topIndexHeight: topStickStyleResolved.height!,
                  topIndexFontColor: topStickStyleResolved.color!,
                  topIndexBgColor: topStickStyleResolved.backgroundColor!,
                  itemFontColor: cityItemStyleResolved.color!,
                  cityItemFontSize: cityItemStyleResolved.fontSize!,
                  itemSelectFontColor: cityItemStyleResolved.activeColor!)),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) =>
                  SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.0, 1.0),
                        end: Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child),
        ));
  }
}
