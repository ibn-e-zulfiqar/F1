import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RaceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> race;

  RaceDetailsPage({required this.race});

  // Function to calculate and format time remaining
  String _calculateTimeRemaining(DateTime raceDate) {
    final now = DateTime.now();

    if (raceDate.isBefore(now)) return '';

    final difference = raceDate.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    return '$days days, $hours hours, $minutes minutes';
  }

  // Function to get formatted local time
  String _getLocalTimeDetails(DateTime raceDate) {
    // Format for date
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    // Format for time with timezone
    final timeFormatter = DateFormat('h:mm a z');

    return '${dateFormatter.format(raceDate)}\n${timeFormatter.format(raceDate)}';
  }

  @override
  Widget build(BuildContext context) {
    // Parse the race date
    final raceDate = DateTime.parse(race['date']);

    return Scaffold(
      appBar: AppBar(
        title: Text(race['competition']['name']),
        backgroundColor: Color(0xFF20303F),
      ),
      backgroundColor: Color(0xFF20303F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (race['circuit'] != null && race['circuit']['name'] != null)
              Text(
                'Circuit: ${race['circuit']['name']}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            const SizedBox(height: 10),
            if (race['circuit'] != null && race['circuit']['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  race['circuit']['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            if (race['competition'] != null && race['competition']['location'] != null)
              Text(
                'Location: ${race['competition']['location']['city']}, ${race['competition']['location']['country']}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            if (race['laps'] != null && race['laps']['total'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Total Laps: ${race['laps']['total']}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            if (race['distance'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Distance: ${race['distance']}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),

            if (race['status'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Status: ${race['status']}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),


            // Local Time and Time Remaining section
            Builder(
              builder: (context) {
                final timeRemaining = _calculateTimeRemaining(raceDate);
                final localTimeDetails = _getLocalTimeDetails(raceDate);

                if (timeRemaining.isNotEmpty)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Race Time Details:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Local Time:\n$localTimeDetails',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Time Remaining:\n$timeRemaining',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}