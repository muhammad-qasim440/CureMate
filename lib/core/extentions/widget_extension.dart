import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension SizedBoxHelper on num {
  Widget get height => SizedBox(height: toDouble());

  Widget get width => SizedBox(width: toDouble());

  Widget get sliverHeight => height.wrapWithSliver;

  Widget get sliverWidth => width.wrapWithSliver;
}

extension SliverExtension on Widget {
  Widget get wrapWithSliver => SliverToBoxAdapter(child: this);
}

extension DateFormatExtension on String {
  /// Returns formatted date like: 30 Apr 2025, 01:45 PM
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(this);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Returns date like: 04\nMAY
  String get dayBYMonthDisplay {
    try {
      final dateTime = DateTime.parse(this);
      final day = DateFormat('dd').format(dateTime);
      final month = DateFormat('MMM').format(dateTime).toUpperCase();
      return '$day\n$month';
    } catch (e) {
      return 'Invalid\ndate';
    }
  }

  /// Returns date like: 04 MAY
  String get dayMonthDisplay {
    try {
      final dateTime = DateTime.parse(this);
      final day = DateFormat('dd').format(dateTime);
      final month = DateFormat('MMM').format(dateTime).toUpperCase();
      return '$day $month';
    } catch (e) {
      return 'Invalid date';
    }
  }

}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}