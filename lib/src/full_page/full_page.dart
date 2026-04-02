import 'package:city_pickers/modal/base_citys.dart';
import 'package:city_pickers/modal/point.dart';
import 'package:city_pickers/modal/result.dart';
import 'package:city_pickers/src/show_types.dart';
import 'package:city_pickers/src/util.dart';
import 'package:flutter/material.dart';

class FullPage extends StatefulWidget {
  final String? locationCode;
  final ShowType? showType;
  final Map<String, String>? provincesData;
  final Map<String, dynamic>? citiesData;

  const FullPage(
      {super.key, this.locationCode, this.showType, this.provincesData, this.citiesData});

  @override
  State<FullPage> createState() => _FullPageState();
}

// 界面状态
enum Status {
  province,
  city,
  area,
  over,
}

class HistoryPageInfo {
  Status? status;
  List<Point>? itemList;

  HistoryPageInfo({this.status, this.itemList});
}

class _FullPageState extends State<FullPage> {
  /// list scroll control
  ScrollController? scrollController;

  /// provinces object [Point]
  List<Point>? provinces;

  /// cityTree modal ,for building tree that root is province
  CityTree? cityTree;

  /// page current statue, show p or a or c or over
  Status? pageStatus;

  List<Point>? itemList;

  /// body history, the max length is three
  final List<HistoryPageInfo> _history = [];

  /// the target province user selected
  Point? targetProvince;

  /// the target city user selected
  Point? targetCity;

  /// the target area user selected
  Point? targetArea;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    provinces = Provinces(metaInfo: widget.provincesData!).provinces;
    cityTree = CityTree(
        metaInfo: widget.citiesData!, provincesInfo: widget.provincesData!);
    itemList = provinces;
    pageStatus = Status.province;
    try {
      _initLocation(widget.locationCode!);
    } catch (e) {
      debugPrint('Exception details:\n 初始化地理位置信息失败, 请检查省分城市数据 \n $e');
    }
  }

  void back(bool v, Object? _) {
    if (v) {
      return;
    }
    HistoryPageInfo? last = _history.isNotEmpty ? _history.last : null;
    if (last != null && mounted) {
      setState(() {
        pageStatus = last.status;
        itemList = last.itemList;
      });
      _history.removeLast();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _initLocation(String locationCode) {
    int locationCodeInt;
    try {
      locationCodeInt = int.parse(locationCode);
    } catch (e) {
      debugPrint(ArgumentError(
              "The Argument locationCode must be valid like: '100000' but get '$locationCode' ")
          .toString());
      return;
    }

    targetProvince = cityTree!.initTreeByCode(locationCodeInt);
    if (targetProvince!.isNull) {
      targetProvince = cityTree!.initTreeByCode(provinces!.first.code!);
    }
    for (Point city in targetProvince!.child) {
      if (city.code == locationCodeInt) {
        targetCity = city;
        targetArea = _getTargetChildFirst(city);
      }
      for (Point area in city.child) {
        if (area.code == locationCodeInt) {
          targetCity = city;
          targetArea = area;
        }
      }
    }

    targetCity ??= _getTargetChildFirst(targetProvince!);
    targetArea ??= _getTargetChildFirst(targetCity!);
  }

  Result _buildResult() {
    Result result = Result();
    ShowType showType = widget.showType!;
    try {
      if (showType.contain(ShowType.p)) {
        result.provinceId = targetProvince!.code.toString();
        result.provinceName = targetProvince!.name;
      }
      if (showType.contain(ShowType.c)) {
        result.provinceId = targetProvince!.code.toString();
        result.provinceName = targetProvince!.name;
        result.cityId = targetCity?.code.toString();
        result.cityName = targetCity?.name;
      }
      if (showType.contain(ShowType.a)) {
        result.provinceId = targetProvince!.code.toString();
        result.provinceName = targetProvince!.name;
        result.cityId = targetCity?.code.toString();
        result.cityName = targetCity?.name;
        result.areaId = targetArea?.code.toString();
        result.areaName = targetArea?.name;
      }
    } catch (e) {
      // 此处兼容, 部分城市下无地区信息的情况
    }

    // 台湾异常数据. 需要过滤
    if (result.provinceId == "710000") {
      result.cityId = null;
      result.cityName = null;
      result.areaId = null;
      result.areaName = null;
    }
    return result;
  }

  Point? _getTargetChildFirst(Point target) {
    if (target.child.isNotEmpty) {
      return target.child.first;
    }
    return null;
  }

  void popHome() {
    Navigator.of(context).pop(_buildResult());
  }

  void _onProvinceSelect(Point province) {
    setState(() {
      targetProvince = cityTree!.initTree(province.code!);
    });
  }

  void _onAreaSelect(Point area) {
    setState(() {
      targetArea = area;
    });
  }

  void _onCitySelect(Point city) {
    setState(() {
      targetCity = city;
    });
  }

  int? _getSelectedId() {
    int? selectId;
    switch (pageStatus!) {
      case Status.province:
        selectId = targetProvince!.code;
        break;
      case Status.city:
        selectId = targetCity!.code;
        break;
      case Status.area:
        selectId = targetArea!.code;
        break;
      case Status.over:
        break;
    }
    return selectId;
  }

  /// 所有选项的点击事件入口
  /// @param targetPoint 被点击对象的point对象
  void _onItemSelect(Point targetPoint) {
    _history.add(HistoryPageInfo(itemList: itemList, status: pageStatus));
    Status? nextStatus;
    List<Point>? nextItemList;
    switch (pageStatus!) {
      case Status.province:
        _onProvinceSelect(targetPoint);
        nextStatus = Status.city;
        nextItemList = targetProvince!.child;
        if (!widget.showType!.contain(ShowType.c)) {
          nextStatus = Status.over;
        }
        if (nextItemList.isEmpty) {
          targetCity = null;
          targetArea = null;
          nextStatus = Status.over;
        }
        break;
      case Status.city:
        _onCitySelect(targetPoint);
        nextStatus = Status.area;
        nextItemList = targetCity!.child;
        if (!widget.showType!.contain(ShowType.a)) {
          nextStatus = Status.over;
        }
        if (nextItemList.isEmpty) {
          targetArea = null;
          nextStatus = Status.over;
        }
        break;
      case Status.area:
        nextStatus = Status.over;
        _onAreaSelect(targetPoint);
        break;
      case Status.over:
        break;
    }

    setTimeout(
        milliseconds: 300,
        callback: () {
          if (nextItemList == null || nextStatus == Status.over) {
            return popHome();
          }
          if (mounted) {
            setState(() {
              itemList = nextItemList;
              pageStatus = nextStatus;
            });
            if (scrollController!.hasClients) {
              scrollController!.jumpTo(0.0);
            }
          }
        });
  }

  Widget _buildHead() {
    String title = '请选择城市';
    switch (pageStatus!) {
      case Status.province:
        break;
      case Status.city:
        title = targetProvince!.name!;
        break;
      case Status.area:
        title = targetCity!.name!;
        break;
      case Status.over:
        break;
    }
    return Text(title);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: back,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: _buildHead(),
          ),
          body: SafeArea(
              bottom: true,
              child: ListWidget(
                itemList: itemList!,
                controller: scrollController!,
                onSelect: _onItemSelect,
                selectedId: _getSelectedId(),
              ))),
    );
  }
}

class ListWidget extends StatelessWidget {
  final List<Point>? itemList;
  final ScrollController? controller;
  final int? selectedId;
  final ValueChanged<Point>? onSelect;

  const ListWidget({super.key, this.itemList, this.onSelect, this.controller, this.selectedId});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ListView.builder(
      controller: controller,
      itemBuilder: (BuildContext context, int index) {
        Point item = itemList![index];
        return Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 1.0))),
          child: ListTileTheme(
            child: ListTile(
              title: Text(item.name!),
              // item 标题
              dense: true,
              // item 直观感受是整体大小
              trailing: selectedId == item.code
                  ? Icon(Icons.check, color: theme.primaryColor)
                  : null,
              contentPadding: EdgeInsets.fromLTRB(24.0, .0, 24.0, 3.0),
              // item 内容内边距
              enabled: true,
              onTap: () {
                onSelect!(itemList![index]);
              },
              // item onTap 点击事件
              onLongPress: () {},
              // item onLongPress 长按事件
              selected: selectedId == item.code, // item 是否选中状态
            ),
          ),
        );
      },
      itemCount: itemList!.length,
    );
  }
}
