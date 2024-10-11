import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Home',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _weatherCondition = '';
  String _temperature = '';
  String _location = '';
  bool _isLoading = false;
  final List<String> _cities = ['New York', 'London', 'Tokyo', 'Paris', 'Sydney'];

  Future<void> _getWeatherForLocation(String location) async {
    setState(() {
      _isLoading = true;
      _weatherCondition = '';
      _temperature = '';
    });

    final apiKey = 'd0a4cf8e6175f25df9a07e27f2d2df9b'; // Make sure this is correct
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _location = data['name'];
          _weatherCondition = data['weather'][0]['main'];
          _temperature = '${data['main']['temp'].round()}°C';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _location = location;
        _weatherCondition = 'Error';
        _temperature = 'N/A';
        _isLoading = false;
      });
      print('Error fetching weather data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load weather data. Please check your API key and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Forecast',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _location.isEmpty ? null : _location,
                      hint: Text('Select a city', style: TextStyle(color: Colors.white)),
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      dropdownColor: Colors.blue.shade700,
                      items: _cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _getWeatherForLocation(newValue);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 50),
                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: Colors.white))
                else if (_location.isNotEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _location,
                          style: GoogleFonts.montserrat(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        Icon(
                          _getWeatherIcon(_weatherCondition),
                          size: 120,
                          color: Colors.white,
                        ),
                        SizedBox(height: 20),
                        Text(
                          _weatherCondition,
                          style: GoogleFonts.montserrat(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _temperature,
                          style: GoogleFonts.montserrat(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.beach_access;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Colors.orange;
      case 'clouds':
        return Colors.grey;
      case 'rain':
        return Colors.blue;
      case 'snow':
        return Colors.lightBlue;
      case 'thunderstorm':
        return Colors.deepPurple;
      default:
        return Colors.orange;
    }
  }
}