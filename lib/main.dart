import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const NativeTextWidget(),
            const NativeTimer()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NativeTextWidget extends StatelessWidget {
  const NativeTextWidget({super.key});

  final MethodChannel channel = const MethodChannel("native_channel");

  Future<(String, String)> getDataFromNative() async {
    var nativeData = await channel.invokeMethod("getDataFromNative");
    var battery = await channel.invokeMethod("getBatteryLevel");
    return (nativeData.toString(), battery.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDataFromNative(),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapShot.hasData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(snapShot.data!.$1),
                Text(snapShot.data!.$2),
                if (Platform.isAndroid)
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: OutlinedButton(
                          onPressed: () async => await channel.invokeMethod(
                              "nativeNotification",
                              {"content": "Called Native Notification"}),
                          child: const Text("Invoke Native Notification")))
              ],
            );
          } else {
            return Center(child: Text(snapShot.error.toString()));
          }
        });
  }
}

class NativeTimer extends StatelessWidget {
  const NativeTimer({super.key});

  final event = const EventChannel("native_event");

  Stream<String> nativeStream() {
    return event.receiveBroadcastStream().map((event) => event);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: event.receiveBroadcastStream().map((event) => event),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasData) {
            return Center(child: Text(snapshot.data.toString()));
          } else {
            return Center(child: Text(snapshot.error.toString()));
          }
        });
  }
}
