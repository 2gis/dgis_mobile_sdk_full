import 'package:flutter/material.dart';

import 'pages/add_objects.dart';
import 'pages/all_map_controls.dart';
import 'pages/benchmark.dart';
import 'pages/calc_position.dart';
import 'pages/camera_moves.dart';
import 'pages/clustering.dart';
import 'pages/copyright.dart';
import 'pages/download_territories_page.dart';
import 'pages/fps_page.dart';
import 'pages/indoor_widget.dart';
import 'pages/map_gestures.dart';
import 'pages/map_objects_identification.dart';
import 'pages/map_snapshot.dart';
import 'pages/route_editor.dart';
import 'pages/routes.dart';
import 'pages/search_page.dart';
import 'pages/stateless_screen_with_map.dart';
import 'pages/traffic_widget.dart';
import 'pages/common.dart';
import 'pages/navigator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SDK test app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter SDK test app Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Navigation'),
              Tab(text: 'Map'),
              Tab(text: 'Directory'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _navigationPages(),
            _mapPages(),
            _directoryPages(),
          ],
        ),
      ),
    );
  }

  Widget _navigationPages() {
    return ListView(
      children: [
        ListTile(
          title: buildPageTitle('Route editor'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RouteEditorPage(title: 'Route editor')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Routes list'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoutingPage(title: 'Routes list')),
          ),
        ),
        ListTile(
          title: buildPageTitle('Navigator Example'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NavigatorPage(title: 'Navigator Example')),
            );
          },
        ),
      ],
    );
  }

  Widget _mapPages() {
    return ListView(
      children: [
        ListTile(
          title: buildPageTitle('Add Objects'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddObjectsPage(title: 'Add Objects')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('All map widgets'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllMapControlsPage(title: 'All map widgets')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Benchmark'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BenchmarkPage(title: 'Benchmark')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Calc position'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalcPositionPage(title: 'Calc position')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Camera moves'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraMovesPage(title: 'Camera moves')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Clustering'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClusteringPage(title: 'Clustering')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Copyright'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CopyrightPage(title: 'Copyright')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Download territories'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DownloadTerritoriesPage(title: 'Download territories')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('FPS'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FpsPage(title: 'FPS')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Indoor Widget'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => IndoorWidgetPage(title: 'Indoor Widget')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Map gestures'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapGesturesPage(title: 'Map gestures')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Map objects identification'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapObjectsIdentificationPage(title: 'Map objects identification')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Map snapshot'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapSnapshotPage(title: 'Map snapshot')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Simple map screen (stateless widget)'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SimpleMapScreen(title: 'Simple map screen (stateless widget)')),
            );
          },
        ),
        ListTile(
          title: buildPageTitle('Traffic widget'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrafficWidgetPage(title: 'Traffic widget')),
            );
          },
        ),
      ],
    );
  }

  Widget _directoryPages() {
    return ListView(
      children: [
        ListTile(
          title: buildPageTitle('Search'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(title: 'Search'),
              ),
            );
          },
        ),
      ],
    );
  }
}
