import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends TableCalendar {
  static final _defaultFirstDay = DateTime.utc(2020, 1, 1);

  static get _defaultLastDay => DateTime.now().add(const Duration(days: 365));

  static getHeaderStyle() => const HeaderStyle(formatButtonVisible: false);

  static getCalendarStyle(BuildContext context) => CalendarStyle(
        selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
            shape: BoxShape.circle),
      );

  Calendar(
      {
      required super.focusedDay,
      super.key,
      super.selectedDayPredicate,
      super.onDaySelected,
      super.onPageChanged,
      super.headerStyle,
      super.calendarStyle})
      : super(
          firstDay: _defaultFirstDay,
          lastDay: _defaultLastDay,
        );
}
