import '../../modal/base_citys.dart';
import '../../modal/point.dart';

// 城市列表偏移量结构
class CityOffsetRange {
  double? start;
  double? end;
  String? tag;

  CityOffsetRange({this.start, this.end, this.tag});
}

class TagCount {
  int? count;
  String? letter;

  TagCount({this.count, this.letter});
}

class CitiesUtils {
  /// 获取城市选择器所有的数据
  static List<Point> getAllCitiesByMeta(
      Map<String, String> provinceMeta, Map<String, dynamic> citiesMeta) {
    List<Point> trees = [];
    List<Point> cities = [];
    CityTree citiesTreeBuilder =
        CityTree(metaInfo: citiesMeta, provincesInfo: provinceMeta);
    for (var entry in provinceMeta.entries) {
      trees.add(citiesTreeBuilder.initTree(int.parse(entry.key))!);
    }
    for (Point tree in trees) {
      cities.addAll(tree.child);
    }
    cities.sort((Point a, Point b) {
      return a.letter!.codeUnitAt(0) - b.letter!.codeUnitAt(0);
    });
    for (Point point in cities) {
      point.letter = point.letter!.toUpperCase();
    }
    return cities;
  }

  static List<String> getValidTagsByCityList(List<Point> citiesList) {
    List<String> validTags = [];

    /// 先分类
    String lastTag = '';
    for (Point item in citiesList) {
      if (item.letter != lastTag) {
        validTags.add(item.letter!);
        lastTag = item.letter!;
      }
    }
    return validTags;
  }

  static List<CityOffsetRange> getOffsetRangeByCitiesList(
      {required List<Point>? lists,
      required double? itemHeight,
      required double? tagHeight}) {
    List<TagCount> categoriesList = [];
    List<CityOffsetRange> result = [];

    /// 先分类
    String lastTag = '';
    for (Point item in lists!) {
      if (item.letter != lastTag) {
        categoriesList.add(TagCount(letter: item.letter, count: 0));
        lastTag = item.letter!;
      }
    }
    for (Point item in lists) {
      TagCount target = categoriesList.firstWhere((TagCount tagCount) {
        return tagCount.letter == item.letter;
      });
      target.count = target.count! + 1;
    }
    for (TagCount item in categoriesList) {
      double? start = result.isNotEmpty ? result.last.end : 0;
      result.add(CityOffsetRange(
          start: start,
          end: start! + item.count! * itemHeight! + tagHeight!,
          tag: item.letter!.toUpperCase()));
    }
    return result;
  }
}

// 热闹城市对象
class HotCity {
  final String? name;
  final int? id;
  final String tag;
  const HotCity({required this.name, required this.id, this.tag = "★"});
}
