import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
// To perform an interaction with a widget in your test, use the WidgetTester
void main() { the flutter_test package. For example, you can send tap and scroll
  runApp(BluetoothApp()); use WidgetTester to find child widgets in the widget
}/ tree, read text, and verify that the values of widget properties are correct.

class BluetoothApp extends StatelessWidget {
  @overridekage:flutter_test/flutter_test.dart';
  Widget build(BuildContext context) {
    return MaterialApp(n.dart';
      debugShowCheckedModeBanner: false,
      home: BluetoothScreen(),
    );Widgets('Counter increments smoke test', (WidgetTester tester) async {
  } // Build our app and trigger a frame.
}   await tester.pumpWidget(const MyApp());

class BluetoothScreen extends StatefulWidget {
  @overridefind.text('0'), findsOneWidget);
  _BluetoothScreenState createState() => _BluetoothScreenState();
}
    // Tap the '+' icon and trigger a frame.
class _BluetoothScreenState extends State<BluetoothScreen> {
  final FlutterBluetoothBasic bluetooth = FlutterBluetoothBasic();
  List<BluetoothDevice> connectedDevices = [];
  final String targetMacAddress = "XX:XX:XX:XX:XX:XX"; // Replace with your device's MAC address    // Verify that our counter has incremented.
find.text('0'), findsNothing);
  @override('1'), findsOneWidget);
  void initState() {
    super.initState();
    getConnectedDevices();  }  Future<void> getConnectedDevices() async {    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();    setState(() {      connectedDevices = devices.where((device) => device.address == targetMacAddress).toList();    });    if (connectedDevices.isNotEmpty) {      for (var device in connectedDevices) {        print("Connected: ${device.name} - MAC: ${device.address}");      }    } else {      print("No connected devices found.");    }  }  @override  Widget build(BuildContext context) {    return Scaffold(      appBar: AppBar(title: Text("Connected Bluetooth Devices")),      body: Column(        children: [          ElevatedButton(            onPressed: getConnectedDevices,            child: Text("Refresh Devices"),          ),          Expanded(            child: ListView.builder(              itemCount: connectedDevices.length,              itemBuilder: (context, index) {                final device = connectedDevices[index];                return ListTile(                  title: Text(                      device.name.isNotEmpty ? device.name : "Unknown Device"),                  subtitle: Text("MAC: ${device.address}"),                  trailing: Icon(Icons.bluetooth_connected, color: Colors.blue),                );              },            ),          ),        ],      ),    );  }}
