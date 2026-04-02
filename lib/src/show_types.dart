// 显示类型
enum Mods {
  province,
  area,
  city,
}

abstract class ShowTypeGeometry {
  const ShowTypeGeometry();
}

class ShowType extends ShowTypeGeometry {
  final List<Mods> typesList;

  const ShowType(this.typesList);

  static const ShowType p = ShowType([Mods.province]);
  static const ShowType c = ShowType([Mods.city]);
  static const ShowType a = ShowType([Mods.area]);
  static const ShowType pc = ShowType([Mods.province, Mods.city]);
  static const ShowType pca = ShowType([Mods.province, Mods.city, Mods.area]);
  static const ShowType ca = ShowType([Mods.area, Mods.city]);

  ShowType operator +(ShowType others) {
    typesList.addAll(others.typesList);
    return ShowType(typesList);
  }

  bool contain(ShowType other) {
    for (Mods m in other.typesList) {
      if (!typesList.contains(m)) {
        return false;
      }
    }
    return true;
  }
}
