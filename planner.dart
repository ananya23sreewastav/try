import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlannerPage extends StatefulWidget {
  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};

  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString('events') ?? '{}';

    // Debugging: Print loaded events
    print('Loaded events string: $eventsString');

    final Map<String, dynamic> decodedEvents = json.decode(eventsString);
    setState(() {
      _events = decodedEvents.map((key, value) {
        final dateTime = DateTime.parse(key);
        final eventList = List<String>.from(value);
        return MapEntry(dateTime, eventList);
      });
    });

    // Debugging: Print loaded events map
    print('Loaded events map: $_events');
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = json.encode(_events.map((key, value) {
      return MapEntry(key.toIso8601String(), value);
    }));

    // Debugging: Print saved events
    print('Saved events string: $eventsString');

    await prefs.setString('events', eventsString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Planner'),
        ),
        body: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
                    // If the selected day is before today, don't allow selection
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You can't select a past date."),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                enabledDayPredicate: (day) {
                  return !day.isBefore(DateTime.now().subtract(Duration(days: 1)));
                },
                eventLoader: (day) {
                  if (_events.containsKey(day)) {
                    return _events[day]!; // Use "!" to assert non-null value
                  } else {
                    return [];
                  }
                },
              ),
              ...(_events[_selectedDay] ?? []).map((event) => ListTile(
                title: Text(event),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _eventController,
                  decoration: InputDecoration(
                    labelText: 'Add Event',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_eventController.text.isEmpty) {
                    return;
                  }
                  setState(() {
                    if (_events[_selectedDay] != null) {
                      _events[_selectedDay]?.add(_eventController.text);
                    } else {
                      _events[_selectedDay] = [_eventController.text];
                    }
                    _eventController.clear();
                    _saveEvents(); // Save events to local storage
                  });
                },
                child: Text('Add Event'),
              ),
            ],
            ),
    );
    }
}