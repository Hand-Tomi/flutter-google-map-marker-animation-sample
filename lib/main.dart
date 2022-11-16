import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: _Map(),
    );
  }
}

class _Map extends StatefulWidget {
  const _Map();

  @override
  State<_Map> createState() => _MapState();
}

class _MapState extends State<_Map> with TickerProviderStateMixin {
  final double _startLat = 35.678019077018654;
  final double _startLng = 139.7634313346291;
  final double _endLat = 35.68478142268492;
  final double _endLng = 139.76562826597757;

  Animation<double>? _animation;

  final _markerStreamController = StreamController<Marker>();
  StreamSink<Marker> get _markerSink => _markerStreamController.sink;
  Stream<Marker> get _markerStream => _markerStreamController.stream;

  static const CameraPosition _tokyoStation = CameraPosition(
    target: LatLng(35.68165450744266, 139.76708188461404),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Marker>(
        stream: _markerStream,
        builder: (context, snapshot) {
          final maker = snapshot.data;
          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _tokyoStation,
            markers: <Marker>{if (maker != null) maker},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _run,
        child: const Text('Start'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _run() async {
    final animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        final v = _animation!.value;
        double lng = v * _endLng + (1 - v) * _startLng;
        double lat = v * _endLat + (1 - v) * _startLat;
        newPosition(lat, lng);
      });

    animationController.forward();
  }

  void newPosition(double lat, double lng) {
    _markerSink.add(
      Marker(
        markerId: const MarkerId("driverMarker"),
        position: LatLng(lat, lng),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        draggable: false,
      ),
    );
  }
}
