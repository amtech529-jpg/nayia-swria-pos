import 'package:csv/csv.dart';
void main() {
  final csv = const CsvEncoder().convert([['a','b']]);
  print(csv);
}
