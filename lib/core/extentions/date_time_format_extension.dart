import 'package:intl/intl.dart';


extension DateTimeFormatExtension on DateTime {
  String get formattedDate {
    return DateFormat('yyyy/MM/dd').format(this);
  }


  String get formattedTime {
    return DateFormat('HH:mm').format(this);
  }

}

extension DateTimeFormatExtension1 on String {
  String get formattedDate {
    return DateFormat('yyyy/MM/dd').format(DateTime.parse(this));
  }

  String get formattedTime {
    return DateFormat('HH:mm').format(DateTime.parse(this));
  }

}
extension StringToDateTime on String {
  DateTime toDateTime({String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).parse(this);
  }
}
