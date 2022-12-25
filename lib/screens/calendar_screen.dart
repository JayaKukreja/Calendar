import 'package:flutter/material.dart';
// import 'package:googleapis/analytics/v3.dart';

import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart' as gac;
import 'package:googleapis/versionhistory/v1.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<dynamic>> _events = {};
  static const _scopes = [gac.CalendarApi.calendarScope];
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  var _credentials;

  gac.Event event = gac.Event(); // Create object of event
  // event.summary = "abc";

  gac.EventDateTime start = gac.EventDateTime(); //Setting start time
  // start.dateTime = startTime;
  // start.timeZone = "GMT+05:00";
  // event.start = start;

  gac.EventDateTime end = gac.EventDateTime(); //setting end time
  // end.timeZone = "GMT+05:00";
  // end.dateTime = endTime;
  // event.end = end;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _loadPreviousEvents();
    // if (Platform.isAndroid) {
    //   _credentials = new ClientId(
    //       "YOUR_CLIENT_ID_FOR_ANDROID_APP_RETRIEVED_FROM_Google_Console_Project_EARLIER",
    //       "");
    // } else if (Platform.isIOS) {
    //   _credentials = new ClientId(
    //       "YOUR_CLIENT_ID_FOR_IOS_APP_RETRIEVED_FROM_Google_Console_Project_EARLIER",
    //       "");
    // }
  }

  _loadPreviousEvents() {
    //events added in _events will be listed all here from database which 
    //you can see when you add events from print statement below
    //for now i have listed 2 events
    _events = {
      "2022-12-25": [
        {"eventTitle": "111", "eventDesc": "abc"}
      ],
      "2022-12-27": [
        {"eventTitle": "1230", "eventDesc": "123456789"}
      ]
    };
  }

  List _listOfEvents(DateTime dateTime) {
    if (_events[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return _events[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  _showAddEventdialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                "Add Event",
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: "Label"),
                    controller: titleController,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Description"),
                    controller: descController,
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      if (titleController.text.isEmpty &&
                          descController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Required Title and Description"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        setState(() {
                          if (_events[DateFormat('yyyy-MM-dd')
                                  .format(_selectedDay!)] !=
                              null) {
                            _events[DateFormat('yyyy-MM-dd')
                                    .format(_selectedDay!)]
                                ?.add({
                              "eventTitle": titleController.text,
                              "eventDesc": descController.text
                            });
                          } else {
                            _events[DateFormat('yyyy-MM-dd')
                                .format(_selectedDay!)] = [
                              {
                                "eventTitle": titleController.text,
                                "eventDesc": descController.text
                              }
                            ];
                          }
                          print(_events);
                          titleController.clear();
                          descController.clear();
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text("Add"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios),
        backgroundColor: Colors.black,
        title: const Text(
          "Calendar",
          style: TextStyle(color: Colors.white, fontSize: 40),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[600],
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.purple[100],
        ),
        onPressed: () => _showAddEventdialog(),
      ),
      body: TableCalendar(
        eventLoader: _listOfEvents,
        calendarBuilders: CalendarBuilders(
          // singleMarkerBuilder: (context, _selectedDay, _events) {
          //   return Container(
          //     color: Colors.green,
          //   );
          // },
          selectedBuilder: (context, date, events) => Container(
              width: MediaQuery.of(context).size.width * 1 / 14,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 2 / 14),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.black38, shape: BoxShape.circle),
              child: Text(
                date.day.toString(),
                style: const TextStyle(color: Colors.white),
              )),
          todayBuilder: (context, date, events) => Container(
              width: MediaQuery.of(context).size.width * 1 / 14,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 2 / 14),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.orange, shape: BoxShape.circle),
              child: Text(
                date.day.toString(),
                style: const TextStyle(color: Colors.black),
              )),
        ),
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        shouldFillViewport: true,
        weekendDays: const [DateTime.sunday],
        firstDay: DateTime(2021),
        lastDay: DateTime.utc(2023, 12, 31),
        focusedDay: _focusedDay,
        // calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        daysOfWeekHeight: 60,
        headerStyle: const HeaderStyle(
          headerPadding: EdgeInsets.only(left: 30, top: 50, bottom: 20),
          leftChevronVisible: false,
          rightChevronVisible: false,
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
            dowTextFormatter: (date, locale) =>
                DateFormat.E(locale).format(date)[0],
            weekendStyle: const TextStyle(color: Colors.red),
            weekdayStyle: const TextStyle(color: Colors.white)),
        calendarStyle: CalendarStyle(
          cellAlignment: Alignment.topCenter,
          canMarkersOverflow: true,
          outsideDaysVisible: false,
          tableBorder: TableBorder.symmetric(
              inside: const BorderSide(color: Colors.grey)),
          defaultTextStyle: const TextStyle(color: Colors.grey, fontSize: 17),
          weekendTextStyle: const TextStyle(color: Colors.red, fontSize: 17),
          todayDecoration: const BoxDecoration(color: Colors.pinkAccent),
          selectedDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        // onFormatChanged: (format) {
        //   if (_calendarFormat != format) {
        //     // Call `setState()` when updating calendar format
        //     setState(() {
        //       _calendarFormat = format;
        //     });
        //   }
        // },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
