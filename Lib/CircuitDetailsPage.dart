import 'package:flutter/material.dart';

class CircuitDetailsPage extends StatefulWidget {
  final Map<String, dynamic> circuit;

  const CircuitDetailsPage({Key? key, required this.circuit}) : super(key: key);

  @override
  _CircuitDetailsPageState createState() => _CircuitDetailsPageState();
}

class _CircuitDetailsPageState extends State<CircuitDetailsPage> {
  @override
  void initState() {
    super.initState();

  }

  @override


  @override
  Widget build(BuildContext context) {
    final circuit = widget.circuit;

    return Scaffold(
      appBar: AppBar(
        title: Text(circuit['name'] ?? "Circuit Details"),
        backgroundColor: const Color(0xFF20303F),
      ),
      backgroundColor: const Color(0xFF20303F),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCircuitImage(circuit),
                  const SizedBox(height: 16),
                  _buildCircuitLocation(circuit),
                  const SizedBox(height: 16),
                  _buildCircuitDetailsCard(circuit),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildCircuitImage(Map<String, dynamic> circuit) {
    return Container(
      color: Colors.black, // Background color for better readability.
      child: Image.network(
        circuit['image'] ?? '',
        width: double.infinity,
        //height: 300, // Fixed height for consistency.
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            alignment: Alignment.center,
            color: Colors.grey[800],
            child: const Text(
              'Image Not Available',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircuitLocation(Map<String, dynamic> circuit) {
    if (circuit['competition'] == null ||
        circuit['competition']['location'] == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        "Location: ${circuit['competition']['location']['city']}, ${circuit['competition']['location']['country']}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildCircuitDetailsCard(Map<String, dynamic> circuit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (circuit['first_grand_prix'] != null)
                _buildDetailRow("First Grand Prix", circuit['first_grand_prix']),
              if (circuit['laps'] != null) _buildDetailRow("Laps", circuit['laps']),
              if (circuit['length'] != null) _buildDetailRow("Length", circuit['length']),
              if (circuit['race_distance'] != null)
                _buildDetailRow("Race Distance", circuit['race_distance']),
              if (circuit['lap_record'] != null) ..._buildLapRecord(circuit['lap_record']),
              if (circuit['capacity'] != null || circuit['opened'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  "Other Information",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (circuit['capacity'] != null)
                  _buildDetailRow("Capacity", circuit['capacity']),
                if (circuit['opened'] != null)
                  _buildDetailRow("Opened", circuit['opened']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLapRecord(Map<String, dynamic> lapRecord) {
    return [
      const SizedBox(height: 16),
      const Text(
        "Lap Record",
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      _buildDetailRow("Time", lapRecord['time']),
      _buildDetailRow("Driver", lapRecord['driver']),
      _buildDetailRow("Year", lapRecord['year']),
    ];
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
