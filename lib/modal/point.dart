const List<Point> emptyArray = [];
const noName = "";

///  use National Bureau of Statistics's data, build tree, the [point] is trees's node
class Point {
  int? code;
  List<Point> child;
  int? depth;
  String? letter;
  String? name = noName;
  Point get nullPoint => Point(code: null, child: [], letter: null, name: null);
  bool get isNull => code == null;
  Point(
      {this.code = 0,
      this.child = emptyArray,
      this.depth,
      this.letter,
      this.name});

  /// add node for Point, the node's type must is [Point]
  void addChild(Point node) {
    child.add(node);
  }

  @override
  String toString() {
    return "{code: $code, name: $name, letter: $letter, child: Array & length = ${child.length}";
  }
}
