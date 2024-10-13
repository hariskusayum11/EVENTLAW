import 'package:flutter/material.dart';
import 'package:frontend/controllers/event_service.dart';
import 'package:frontend/models/event_model.dart';

class WarnEvent extends StatefulWidget {
  @override
  _WarnEventState createState() => _WarnEventState();
}

class _WarnEventState extends State<WarnEvent> {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventService.getEvents();
      setState(() {
        _events = events;
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  List<EventModel> _getUpcomingEvents() {
    final now = DateTime.now();
    final oneMonthLater = now.add(Duration(days: 30));
    final oneWeekLater = now.add(Duration(days: 7));
    final oneDayLater = now.add(Duration(days: 1));

    return _events.where((event) {
      final eventDate = event.eventDate;
      return eventDate.isBefore(oneMonthLater) && 
             (eventDate.isAfter(oneWeekLater) || eventDate.isAfter(oneDayLater));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = _getUpcomingEvents();

    return Scaffold(
      appBar: AppBar(
        title: Text('การแจ้งเตือนกิจกรรม', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: upcomingEvents.length,
          itemBuilder: (context, index) {
            final event = upcomingEvents[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.warning, color: Colors.red, size: 40),
                title: Text(
                  event.eventName.isNotEmpty ? event.eventName : 'ไม่มีชื่อกิจกรรม',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                ),
                subtitle: Text(
                  'วันที่: ${event.eventDate.toLocal()}\nเวลา: ${event.startTime} - ${event.endTime}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Notifications page is selected
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'กิจกรรม'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'การแจ้งเตือน'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/events');
              break;
            case 2:
              // Current page (do nothing)
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
