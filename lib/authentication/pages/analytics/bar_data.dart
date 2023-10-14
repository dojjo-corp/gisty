import 'individual_bar.dart';

class BarData {
  final Map<String, dynamic> rawDataMap;

  BarData({required this.rawDataMap});

  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = rawDataMap.values
        .map(
          (value) =>
              IndividualBar(x: value['x'], y: value['toY'], barColor: value['color']),
        )
        .toList();
  }
}
