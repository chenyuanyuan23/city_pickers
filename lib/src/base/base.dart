import 'dart:async';

import 'package:city_pickers/modal/base_citys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../modal/point.dart';
import '../../modal/result.dart';
import '../mod/inherit_process.dart';
import '../show_types.dart';
import '../util.dart';

class BaseView extends StatefulWidget {
  final double? progress;
  final String? locationCode;
  final ShowType? showType;
  final Map<String, String>? provincesData;
  final Map<String, dynamic>? citiesData;
  final ItemWidgetBuilder? itemBuilder;

  /// 是否对数据进行排序
  final bool? isSort;

  /// ios选择框的高度. 配合 itemBuilder中的字体使用.
  final double? itemExtent;

  /// 容器高度
  final double? height;

  /// 取消按钮的Widget
  final Widget? cancelWidget;

  /// 确认按钮的widget
  final Widget? confirmWidget;

  final Widget? titleWidget;

  final String? area;
  const BaseView(
      {super.key,
      this.progress,
      this.showType,
      this.height,
      this.locationCode,
      this.citiesData,
      this.provincesData,
      this.itemBuilder,
      this.itemExtent,
      this.cancelWidget,
      this.confirmWidget,
      this.titleWidget,
      this.isSort,
      this.area = ""})
      : assert(!(itemBuilder != null && itemExtent == null),
            "\ritemExtent could't be null if itemBuilder exits");

  @override
  State<BaseView> createState() => _BaseView();
}

class _BaseView extends State<BaseView> {
  Timer? _changeTimer;
  bool _resetControllerOnce = false;
  FixedExtentScrollController? provinceController;
  FixedExtentScrollController? cityController;
  FixedExtentScrollController? areaController;

  List<Point>? provinces;
  CityTree? cityTree;

  Point? targetProvince;
  Point? targetCity;
  Point? targetArea;

  @override
  void initState() {
    super.initState();

    provinces =
        Provinces(metaInfo: widget.provincesData!, sort: widget.isSort!)
            .provinces;

    cityTree = CityTree(
        metaInfo: widget.citiesData!, provincesInfo: widget.provincesData!);

    try {
      _initLocation(widget.locationCode);
    } catch (e) {
      // print('Exception details:\n 初始化地理位置信息失败, 请检查省分城市数据 \n $e');
    }
    _initController();
  }

  @override
  void dispose() {
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    provinceController?.dispose();
    cityController?.dispose();
    areaController?.dispose();
    super.dispose();
  }

  // 初始化controller, 为了使给定的默认值, 在选框的中心位置
  void _initController() {
    provinceController = FixedExtentScrollController(
        initialItem: provinces!
            .indexWhere((Point? p) => p?.code == targetProvince?.code));

    cityController = FixedExtentScrollController(
        initialItem: targetProvince!.child
            .indexWhere((Point? p) => p?.code == targetCity?.code));

    areaController = FixedExtentScrollController(
        initialItem: targetCity!.child
            .indexWhere((Point? p) => p?.code == targetArea?.code));
  }

  void _resetController() {
    if (_resetControllerOnce) return;
    provinceController?.dispose();
    provinceController = FixedExtentScrollController(initialItem: 0);

    cityController?.dispose();
    cityController = FixedExtentScrollController(initialItem: 0);
    areaController?.dispose();
    areaController = FixedExtentScrollController(initialItem: 0);
    _resetControllerOnce = true;
  }

  // initialize tree by locationCode
  void _initLocation(String? locationCode) {
    int locationCodeInt;
    if (locationCode != null) {
      try {
        locationCodeInt = int.parse(locationCode);
      } catch (e) {
        debugPrint(ArgumentError(
                "The Argument locationCode must be valid like: '100000' but get '$locationCode' ")
            .toString());
        return;
      }

      targetProvince = cityTree!.initTreeByCode(locationCodeInt);

      /// 为用户给出的locationCode不正确做一个容错
      targetProvince ??= cityTree!.initTreeByCode(provinces!.first.code!);
      for (Point city in targetProvince?.child ?? []) {
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
    } else {
      /// 本来默认想定在北京, 但是由于有可能出现用户的省份数据为不包含北京, 所以采用第一个省份做为初始
      targetProvince =
          cityTree!.initTreeByCode(int.parse(widget.provincesData!.keys.first));
    }
    // 尝试试图匹配到下一个级别的第一个,
    targetCity ??= _getTargetChildFirst(targetProvince!);
    // 尝试试图匹配到下一个级别的第一个,
    targetArea ??= _getTargetChildFirst(targetCity!);
  }

  Point? _getTargetChildFirst(Point target) {
    if (target.child.isNotEmpty) {
      return target.child.first;
    }
    return null;
  }

  // 通过选中的省份, 构建以省份为根节点的树型结构
  List<String> getCityItemList() {
    List<String> result = [];
    if (targetProvince != null) {
      result
          .addAll(targetProvince!.child.toList().map((p) => p.name!).toList());
    }
    return result;
  }

  List<String> getAreaItemList() {
    List<String> result = [];

    if (targetCity != null) {
      result.addAll(targetCity!.child.toList().map((p) => p.name!).toList());
    }
    return result;
  }

  // province change handle
  // 加入延时处理, 减少构建树的消耗
  void _onProvinceChange(Point province) {
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    _changeTimer = Timer(Duration(milliseconds: 500), () {
      Point provinceTree =
          cityTree!.initTree(int.parse(province.code.toString()))!;
      if (!mounted) {
        return;
      }
      if (cityController != null && cityController!.hasClients) {
        cityController!.animateToItem(0,
            duration: Duration(milliseconds: 100), curve: Curves.linear);
      }
      setState(() {
        targetProvince = provinceTree;
        targetCity = _getTargetChildFirst(provinceTree);
        targetArea = _getTargetChildFirst(targetCity!);
        _resetController();
      });
    });
  }

  void _onCityChange(Point targetCityParam) {
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    _changeTimer = Timer(Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        targetCity = targetCityParam;
        targetArea = _getTargetChildFirst(targetCity!);
        _resetController();
      });
    });
  }

  void _onAreaChange(Point targetAreaParam) {
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    _changeTimer = Timer(Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        targetArea = targetAreaParam;
      });
    });
  }

  Result _buildResult() {
    Result result = Result();
    ShowType showType = widget.showType!;
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
    return result;
  }

  String getAreaTitle() {
    String title = '';
    if (targetProvince != null) {
      title = '${targetProvince!.name}-';
    }
    if (targetCity != null) {
      title = '$title${targetCity!.name}';
    }
    return title;
  }

  Widget _bottomBuild() {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        child: Container(
            width: double.infinity,
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    color: Colors.white,
                    height: 60,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CupertinoButton(
                          pressedOpacity: 0.3,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: widget.cancelWidget ??
                              Text(
                                '取消',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF303233),
                                ),
                              ),
                        ),
                        if (widget.area != "")
                          Row(children: [
                            Icon(
                              Icons.room,
                              color: Color(0xFF333333),
                              size: 20.0,
                            ),
                            Text(
                              getAreaTitle(),
                              textAlign: TextAlign.center,
                            )
                          ]),
                        if (widget.titleWidget != null) widget.titleWidget!,
                        CupertinoButton(
                          pressedOpacity: 0.3,
                          onPressed: () {
                            Navigator.pop(context, _buildResult());
                          },
                          child: widget.confirmWidget ??
                              Text(
                                '确定',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF303233),
                                ),
                              ),
                        ),
                      ],
                    )),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      _MyCityPicker(
                        isShow: widget.showType!.contain(ShowType.p),
                        height: widget.height!,
                        controller: provinceController!,
                        itemBuilder: widget.itemBuilder,
                        itemExtent: widget.itemExtent,
                        value: targetProvince!.name,
                        itemList:
                            provinces!.toList().map((v) => v.name!).toList(),
                        changed: (index) {
                          if (provinces != null) {
                            if (index < provinces!.length) {
                              _onProvinceChange(provinces![index]);
                            }
                          }
                        },
                      ),
                      _MyCityPicker(
                        isShow: widget.showType!.contain(ShowType.c),
                        controller: cityController!,
                        itemBuilder: widget.itemBuilder,
                        itemExtent: widget.itemExtent,
                        height: widget.height!,
                        value: targetCity?.name,
                        itemList: getCityItemList(),
                        changed: (index) {
                          if (targetProvince != null) {
                            if (index < targetProvince!.child.length) {
                              _onCityChange(targetProvince!.child[index]);
                            }
                          }
                        },
                      ),
                      _MyCityPicker(
                        isShow: widget.showType!.contain(ShowType.a),
                        controller: areaController!,
                        itemBuilder: widget.itemBuilder,
                        itemExtent: widget.itemExtent,
                        value: targetArea?.name,
                        height: widget.height!,
                        itemList: getAreaItemList(),
                        changed: (index) {
                          if (targetCity != null) {
                            if (index < targetCity!.child.length) {
                              _onAreaChange(targetCity!.child[index]);
                            }
                          }
                        },
                      )
                    ],
                  ),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    final route = InheritRouteWidget.of(context)!.router;
    return AnimatedBuilder(
      animation: route!.animation!,
      builder: (BuildContext context, Widget? child) {
        return CustomSingleChildLayout(
          delegate: _WrapLayout(
              progress: route.animation!.value, height: widget.height!),
          child: GestureDetector(
              child: Material(
              color: Colors.transparent,
              child:
                  SizedBox(width: double.infinity, child: _bottomBuild()),
            ),
          ),
        );
      },
    );
  }
}

class _MyCityPicker extends StatefulWidget {
  final List<String>? itemList;
  final String? value;
  final bool? isShow;
  final FixedExtentScrollController? controller;
  final ValueChanged<int>? changed;
  final double? height;
  final ItemWidgetBuilder? itemBuilder;

  // ios选择框的高度. 配合 itemBuilder中的字体使用.
  final double? itemExtent;

  const _MyCityPicker(
      {this.controller,
      this.isShow = false,
      this.changed,
      this.height,
      this.itemList,
      this.itemExtent,
      this.itemBuilder,
      this.value});

  @override
  State<_MyCityPicker> createState() {
    return _MyCityPickerState();
  }
}

class _MyCityPickerState extends State<_MyCityPicker> {
  List<Widget>? children;
  int select = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isShow!) {
      return SizedBox.shrink();
    }
    if (widget.itemList == null || widget.itemList!.isEmpty) {
      return Expanded(
        child: SizedBox.shrink(),
      );
    }
    return Expanded(
      flex: 1,
      child: Container(
          color: Color(0xFFF6F6F6),
          padding: const EdgeInsets.only(bottom: 10),
          alignment: Alignment.center,
          child: CupertinoPicker.builder(
              magnification: 1.0,
              diameterRatio: 1.5,
              itemExtent: widget.itemExtent ?? 40.0,
              backgroundColor: Color(0xFFF6F6F6),
              scrollController: widget.controller,
              selectionOverlay: Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          top: BorderSide(width: 1, color: Color(0xFFE6E8ED)),
                          bottom:
                              BorderSide(width: 1, color: Color(0xFFE6E8ED))))),
              onSelectedItemChanged: (index) {
                widget.changed!(index);
                select = index;
              },
              itemBuilder: (context, index) {
                if (widget.itemBuilder != null) {
                  return widget.itemBuilder!(
                      widget.itemList![index], widget.itemList!, index);
                }
                return Center(
                  child: Text(
                    widget.itemList![index],
                    style: index == select
                        ? TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          )
                        : TextStyle(
                            color: Color(0xFF8F9BB2),
                          ),
                    maxLines: 1,
                  ),
                );
              },
              childCount: widget.itemList!.length)),
    );
  }
}

class _WrapLayout extends SingleChildLayoutDelegate {
  _WrapLayout({
    this.progress,
    this.height,
  });

  final double? progress;
  final double? height;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = height!;

    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress!;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_WrapLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
