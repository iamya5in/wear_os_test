// Importing necessary libraries
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:http/http.dart' as http;

// Replace with your actual API key and location
const String apiKey = "1ba4a507e18648a4b4694743240908";
const List<String> cities = ["Bengaluru", "Mumbai", "Goa"];
final _random = Random();
String city = cities[0];

void main() {
  // Entry point of the application
  runApp(const MyApp());
}

// The main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'What is Weather Today?'),
    );
  }
}

// Widget for the main screen of the application
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State class for the main screen
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.lightBlue.shade500, Colors.blue.shade200],
            ),
          ),
          child: WatchShape(
            builder: (context, shape, child) {
              return Center(
                child: FutureBuilder<WeatherData>(
                  // Fetching weather data asynchronously
                  future: fetchWeather(city, apiKey),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // Display weather information if data is available
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Display weather icon
                            Image.network(
                              snapshot.data!.iconUrl,
                              height: 52,
                              width: 52,
                            ),
                            // Display weather condition
                            Text(
                              snapshot.data!.condition ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            // Display city name
                            Text(
                              city ?? "",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            // Display temperature
                            Text(
                              'Temperature: ${snapshot.data!.temperature}°C',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            // Button to refresh data with a random city
                            IconButton(
                              onPressed: () {
                                city = cities[_random.nextInt(cities.length)];
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.refresh,
                                size: 32,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      // Display an error message if data fetching fails
                      return Text("Error: ${snapshot.error}");
                    }
                    // Display a loading indicator while fetching data
                    return const CircularProgressIndicator();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Data model for storing weather information
class WeatherData {
  final String temperature;
  final String condition;
  final String iconUrl;

  WeatherData(this.temperature, this.condition, this.iconUrl);
}

// Function to fetch weather data from the API
Future<WeatherData> fetchWeather(String city, String apiKey) async {
  final response = await http.get(Uri.parse(
      "http://api.weatherapi.com/v1/current.json?q=$city&key=$apiKey"));
  print("YASIN --"+response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return WeatherData(
        data["current"]["temp_c"].toString(),
        data["current"]["condition"]["text"].toString(),
        "https:${data["current"]["condition"]["icon"].toString()}");
  } else {
    // Throw an exception if data fetching fails
    throw Exception("Failed to fetch weather data");
  }
}
