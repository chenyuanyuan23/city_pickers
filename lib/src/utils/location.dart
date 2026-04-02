import 'package:flutter/foundation.dart';

import '../../modal/base_citys.dart';
import '../../modal/point.dart';
import '../../modal/result.dart';

class Location {
  Map<String, dynamic>? citiesData;

  Map<String, String>? provincesData;

  /// the target province user selected
  Point? provincePoint;

  /// the target city user selected
  Point? cityPoint;

  /// the target area user selected
  Point? areaPoint;

  // 没有一次性构建整个以国为根的树. 动态的构建以省为根的树, 效率高.
  List<Point>? provinces;

  Location({this.citiesData, this.provincesData});

  Result initLocation(String? locationCode) {
    CityTree cityTree =
        CityTree(metaInfo: citiesData!, provincesInfo: provincesData!);

    int? locationCodeInt;
    Result locationInfo = Result();
    if (locationCode != null) {
      try {
        locationCodeInt = int.parse(locationCode);
      } catch (e) {
        debugPrint(ArgumentError(
                "The Argument locationCode must be valid like: '100000' but get '$locationCode' ")
            .toString());
        return locationInfo;
      }
    }
    provincePoint = cityTree.initTreeByCode(locationCodeInt!);

    if (provincePoint == null || provincePoint!.isNull) {
      return locationInfo;
    }
    locationInfo.provinceName = provincePoint!.name;
    locationInfo.provinceId = provincePoint!.code.toString();

    for (Point city in provincePoint!.child) {
      if (city.code == locationCodeInt) {
        cityPoint = city;
      }

      /// 正常不应该在一个循环中, 如此操作, 但是考虑到地区码的唯一性, 可以在一次双层循环中完成操作. 避免第二层的循环查找
      for (Point area in city.child) {
        if (area.code == locationCodeInt) {
          cityPoint = city;
          areaPoint = area;
        }
      }
    }

    if (cityPoint != null && !cityPoint!.isNull) {
      locationInfo.cityName = cityPoint!.name;
      locationInfo.cityId = cityPoint!.code.toString();
    }

    if (areaPoint != null && !areaPoint!.isNull) {
      locationInfo.areaName = areaPoint!.name;
      locationInfo.areaId = areaPoint!.code.toString();
    }

    return locationInfo;
  }
}
