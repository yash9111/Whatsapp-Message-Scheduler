// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  String choosenTime = "12:00:00";
  TextEditingController phoneController = TextEditingController();
  TextEditingController msgController = TextEditingController();
  late TimeOfDay pickedTime;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> scheduleMethodCall(
      TimeOfDay time, String msg, String phNo) async {
    TimeOfDay scheduledTime = time;

    // Get the current time
    DateTime now = DateTime.now();
    TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

    // Calculate the duration until the scheduled time
    Duration duration = Duration(
      hours: scheduledTime.hour - currentTime.hour,
      minutes: scheduledTime.minute - currentTime.minute,
    );

    if (duration.isNegative) {
      // If the scheduled time is earlier than the current time, add a day to the duration
      duration += Duration(days: 1);
    }

    // Schedule the method call using a delayed task
    Timer(duration, () {
      // Call your method here (sendMessage() in this case)
      sendMessage(msg, phNo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: phoneController,
                decoration: InputDecoration(
                    labelText: "Enter recivers Whatsapp number"),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: msgController,
                decoration: InputDecoration(labelText: "Enter your Message"),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    choosenTime,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  OutlinedButton(
                      onPressed: () async {
                        pickedTime = (await showTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context, //context of current state
                        ))!;
                        choosenTime = pickedTime!.format(context);

                        print(pickedTime);
                        setState(() {});
                      },
                      child: Text(
                        "Choose time",
                        style: TextStyle(fontSize: 20),
                      ))
                ],
              ),
            ),
            ElevatedButton(
              child: Text("Schedule Message"),
              onPressed: () => {
                Fluttertoast.showToast(
                    msg: "Message has been scheduled",
                    toastLength: Toast.LENGTH_LONG),
                scheduleMethodCall(pickedTime, msgController.text.toString(),
                    phoneController.text.toString()),
              },
            )
          ],
        ),
      ),
    );
  }

  Future<String> getTime() async {
    TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    return pickedTime.toString();
  }

  sendMessage(String msg, String phNo) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST',
        Uri.parse('REPLACE_WITH_YOUR_CUSTOM_ULTRAMSG_URL'));
    request.body = json
        .encode({"token": "REPLACE_WITH_YOUR_PRIVATE_TOKEN", "to": "+91$phNo", "body": msg});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
