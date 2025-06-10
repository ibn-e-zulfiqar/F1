import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CircuitDetailsPage.dart';


class CircuitsPage extends StatefulWidget {
  @override
  _CircuitsPageState createState() => _CircuitsPageState();
}

class _CircuitsPageState extends State<CircuitsPage> {

  @override
  void initState() {
    super.initState();
  }


  Future<List<dynamic>> fetchCircuits() async {
    const String url = "https://securepayments.live/brd/circuit.json";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['response']
            .where((circuit) =>
        circuit['image'] != null &&
            circuit['name'] != null &&
            Uri.tryParse(circuit['image']) != null)
            .toList();
      } else {
        print("Error: Failed to load circuits.");
        return [];
      }
    } catch (e) {
      print("Error loading circuits");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Circuits"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF20303F),
      body: Column(
        children: [
          // Display Banner Ad if loaded and allowed
          // Circuit List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchCircuits(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Error Loading Circuits",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No circuits data available",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final circuits = snapshot.data!;
                return ListView.builder(
                  itemCount: circuits.length,
                  itemBuilder: (context, index) {
                    final circuit = circuits[index];
                    return CircuitCard(
                      circuit: circuit,
                      onTap: () {
                        // Show interstitial ad before navigating
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CircuitDetailsPage(circuit: circuit),
                            ),
                          );
                        };
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CircuitCard extends StatelessWidget {
  final Map<String, dynamic> circuit;
  final VoidCallback onTap;

  const CircuitCard({required this.circuit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.red, width: 2),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Image.network(circuit['image'], width: 50, errorBuilder: (_, __, ___) {
          return const Icon(Icons.broken_image, color: Colors.redAccent);
        }),
        title: Text(
          circuit['name'],
          style: const TextStyle(
              color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${circuit['competition']['name']}\n${circuit['competition']['location']['city']}, ${circuit['competition']['location']['country']}",
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
