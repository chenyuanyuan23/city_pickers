import 'package:city_pickers/modal/point.dart';
import 'package:city_pickers/modal/result.dart';
import 'package:city_pickers/src/util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Point', () {
    test('nullPoint', () {
      final p = Point().nullPoint;
      expect(p.isNull, true);
      expect(p.code, isNull);
      expect(p.child, isEmpty);
    });

    test('isNull', () {
      expect(Point(code: null).isNull, true);
      expect(Point(code: 1).isNull, false);
    });

    test('addChild', () {
      final root = Point(code: 1, child: []);
      final child = Point(code: 2);
      root.addChild(child);
      expect(root.child.length, 1);
      expect(root.child.first.code, 2);
    });

    test('toString', () {
      final p = Point(code: 110000, name: '北京', letter: 'B');
      expect(p.toString(), contains('110000'));
      expect(p.toString(), contains('北京'));
    });
  });

  group('Result', () {
    test('toString 序列化', () {
      final r = Result(
        provinceId: '11',
        provinceName: '北京',
        cityId: '1101',
        cityName: '东城区',
      );
      final s = r.toString();
      expect(s, contains('北京'));
      expect(s, contains('东城区'));
    });

    test('toString 移除 null', () {
      final r = Result(provinceId: '11', provinceName: '北京');
      final s = r.toString();
      expect(s, isNot(contains('cityId')));
    });
  });

  group('Cache', () {
    tearDown(() {
      Cache.instance.remove('k1');
      Cache.instance.remove('k2');
    });

    test('set get has remove', () {
      final c = Cache();
      expect(c.has('k1'), false);
      c.set('k1', 'v1');
      expect(c.has('k1'), true);
      expect(c.get('k1'), 'v1');
      c.remove('k1');
      expect(c.has('k1'), false);
    });

    test('get 不存在的 key 返回 null', () {
      expect(Cache.instance.get('nonexistent'), isNull);
    });
  });
}
