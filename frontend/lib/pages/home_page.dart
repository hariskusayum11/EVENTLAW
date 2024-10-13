import 'package:flutter/material.dart';
import 'package:frontend/pages/event_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/controllers/event_service.dart';
import '../models/event_model.dart';
import 'add_event.dart';
import 'edit_event.dart';
import 'profile_page.dart';
import 'warn_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<EventModel>> _events = {};
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      List<EventModel> events = await EventService().getEvents();
      setState(() {
        _events = _groupEventsByDate(events);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดกิจกรรมได้')),
      );
    }
  }

  Map<DateTime, List<EventModel>> _groupEventsByDate(List<EventModel> events) {
    final Map<DateTime, List<EventModel>> data = {};
    for (var event in events) {
      final DateTime eventDate = _convertToLocalTime(event.eventDate);

      data.putIfAbsent(eventDate, () => []).add(event);
    }
    return data;
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    final DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  DateTime _convertToLocalTime(DateTime utcDate) {
    return utcDate.toLocal();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = EventPage();
        break;
      case 2:
        page = WarnEvent();
        break;
      case 3:
        page = ProfilePage();
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _deleteEvent(EventModel event) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณแน่ใจหรือว่าต้องการลบกิจกรรม "${event.eventName}" นี้?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await EventService().deleteEvent(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบกิจกรรม "${event.eventName}" สำเร็จ')),
        );
        setState(() {
          _events = _groupEventsByDate(
            _events.values.expand((e) => e).where((e) => e.id != event.id).toList(),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบกิจกรรม "${event.eventName}" ล้มเหลว')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ปฏิทิน'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.pink[200],
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue[200],
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.blueGrey,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: const TextStyle(color: Colors.blueGrey),
                    weekendStyle: const TextStyle(color: Colors.redAccent),
                  ),
                  eventLoader: _getEventsForDay,
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventPage(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, size: 30),
        shape: const CircleBorder(),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                BottomNavigationBarItemWidget(
                  icon: Icons.home,
                  label: 'หน้าแรก',
                  index: 0,
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
                BottomNavigationBarItemWidget(
                  icon: Icons.event,
                  label: 'กิจกรรม',
                  index: 1,
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              ],
            ),
            Row(
              children: [
                BottomNavigationBarItemWidget(
                  icon: Icons.notifications,
                  label: 'การแจ้งเตือน',
                  index: 2,
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
                BottomNavigationBarItemWidget(
                  icon: Icons.person,
                  label: 'โปรไฟล์',
                  index: 3,
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    final events = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    if (events.isEmpty) {
      return const Center(child: Text('ไม่มีกิจกรรมในวันที่เลือก'));
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 3.0,
          child: ListTile(
            leading: Icon(Icons.event, color: Colors.blueAccent),
            title: Text(
              event.eventName.isNotEmpty ? event.eventName : 'ไม่มีชื่อกิจกรรม',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'วันที่: ${_convertToLocalTime(event.eventDate).toLocal().toString().split(' ')[0]}\nเวลา: ${event.startTime} - ${event.endTime}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteEvent(event),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEvent(event: event),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class BottomNavigationBarItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigationBarItemWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selectedIndex == index ? Colors.blueAccent : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: selectedIndex == index ? Colors.blueAccent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
