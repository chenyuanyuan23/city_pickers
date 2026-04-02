import 'package:city_pickers/modal/point.dart';
import 'package:lpinyin/lpinyin.dart';

import '../meta/province.dart';
import '../src/util.dart';

/// tree point

class CityTree {
  /// build cityTrees's meta, it can be changed bu developers
  Map<String, dynamic> metaInfo;

  /// provData user self-defining data
  Map<String, String>? provincesInfo;
  final Cache _cache = Cache();

  Point? tree;

  /// @param metaInfo city and areas meta describe
  CityTree({this.metaInfo = citiesData, this.provincesInfo});

  Map<String, String> get _provincesData => provincesInfo ?? provincesData;

  /// build tree by int provinceId,
  /// @param provinceId this is province id
  /// @return tree
  Point? initTree(int provinceId) {
    String cacheKey = provinceId.toString();

    String? name = _provincesData[provinceId.toString()];
    String letter = PinyinHelper.getFirstWordPinyin(name!).substring(0, 1);
    var root = Point(code: provinceId, letter: letter, child: [], name: name);
    tree = _buildTree(root, metaInfo[provinceId.toString()], metaInfo);
    _cache.set(cacheKey, tree);
    return tree;
  }

  /// @param code one of province city or area id;
  /// @return provinceId return id which province's child contain code
  int? _getProvinceByCode(int code) {
    String codeStr = code.toString();
    List<String> keys = metaInfo.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      Map<String, dynamic> child = metaInfo[key];
      if (child.containsKey(codeStr)) {
        // 当前元素的父key在省份内
        if (_provincesData.containsKey(key)) {
          return int.parse(key);
        }
        return _getProvinceByCode(int.parse(key));
      }
    }
    return null;
  }

  /// build tree by any code provinceId or cityCode or areaCode
  /// @param code build a tree
  /// @return Point a province with its cities and areas tree
  Point? initTreeByCode(int code) {
    String codeStr = code.toString();
    if (_provincesData[codeStr] != null) {
      return initTree(code);
    }
    int? provinceId = _getProvinceByCode(code);
    if (provinceId != null) {
      return initTree(provinceId);
    }
    return Point().nullPoint;
  }

  /// private function
  /// recursion to build tree
  Point? _buildTree(Point target, Map? citys, Map meta) {
    if (citys == null || citys.isEmpty) {
      return target;
    } else {
      List<dynamic> keys = citys.keys.toList();

      for (int i = 0; i < keys.length; i++) {
        String key = keys[i];
        Map value = citys[key];
        Point point = Point(
          code: int.parse(key),
          letter: value['alpha'],
          child: [],
          name: value['name'],
        );

        if (citys.keys.length == 1) {
          if (target.code.toString() == citys.keys.first) {
            continue;
          }
        }

        point = _buildTree(point, meta[key], meta)!;
        target.addChild(point);
      }
    }
    return target;
  }
}

/// Province Class
class Provinces {
  Map<String, String> metaInfo;

  // 是否将省份排序, 进行排序
  bool? sort = true;
  Provinces({this.metaInfo = provincesData, this.sort});

  // 获取省份数据
  List<Point> get provinces {
    List<Point> provList = [];
    List<String> keys = metaInfo.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      String name = metaInfo[keys[i]]!;
      provList.add(Point(
          code: int.parse(keys[i]),
          letter: PinyinHelper.getFirstWordPinyin(name).substring(0, 1),
          name: name));
    }
    if (sort == true) {
      provList.sort((Point a, Point b) {
        return a.letter!.compareTo(b.letter!);
      });
    }

    return provList;
  }
}
