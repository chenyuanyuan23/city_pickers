import 'package:city_pickers/modal/result.dart';

import 'location.dart';

class CityPickerUtil {
  Map<String, dynamic>? citiesData;
  Map<String, String>? provincesData;

  CityPickerUtil({this.citiesData, this.provincesData})
      : assert(citiesData != null),
        assert(provincesData != null);

  Result getAreaResultByCode(String code) {
    Location location =
        Location(citiesData: citiesData!, provincesData: provincesData!);
    return location.initLocation(code);
  }
}
