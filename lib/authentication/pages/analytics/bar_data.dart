import 'individual_bar.dart';

class BarData {
  final Map<String, dynamic> rawDataMap;

  BarData({required this.rawDataMap});

  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = rawDataMap.values
        .map(
          (value) =>
              IndividualBar(x: 0, y: value['toY'], barColor: value['color']),
        )
        .toList();
  }
}
