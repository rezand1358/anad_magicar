import 'package:anad_magicar/Routes.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/data/rxbus.dart';
import 'package:anad_magicar/firebase/message/firebase_message_handler.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/user/user_repo.dart';
import 'package:anad_magicar/service/locator.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/ui/screen/login/login_page.dart';
import 'package:anad_magicar/ui/screen/login/login_screen.dart';
import 'package:anad_magicar/utils/check_status_connection.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:anad_magicar/firebase/message/message_handler.dart' as msgHdlr;
import 'package:flutter/material.dart';
import 'package:anad_magicar/Routes.dart' as myApp;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

 Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async{
  if (message.containsKey('data')) {
    final dynamic data = message['data'];

    final title = data['title'];
    final body = data['body'];
    await _showNotificationWithDefaultSound(title, body);
  }

  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
  }


  return Future<void>.value();
}
showMessage(Map<String,dynamic> message) {
  String title=message['notification']['title'];
  String messageBody=message['notification']['body'];
  messageBody+='\n'+title;
  String data_title=message['data']['title'];
  String data=message['data']['body'];
  if(data!=null && data.isNotEmpty){
    if(data_title=='command') {
      String carid=message['data']['carId'];
      RxBus.post(new ChangeEvent(type: 'FCM_STATUS', message: data,id: int.tryParse(carid)));
    }
  }else {
    RxBus.post(new ChangeEvent(type: 'FCM', message: messageBody));
    _showNotificationWithDefaultSound(title,messageBody);

  }
}
Future _showNotificationWithDefaultSound(String title, String message) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'anad_60', 'anad_channel', 'channel_description',
      importance: Importance.None, priority: Priority.Low);
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    '$title',
    '$message',
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );
}

Future<void> main() async {
  final int checkStatusAlarmID = 0;
  final int checkParkGPSStatusAlarmID = 1;
  FireBaseMessageHandler messageHandler;
  setupLocator();
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  WidgetsFlutterBinding.ensureInitialized();

  //await AndroidAlarmManager.initialize();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =  FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload);
      },);


  messageHandler=new msgHdlr.MessageHandler(sendMessage:(message){ showMessage(message);}, );
  messageHandler.initMessageHandler();
  new Routes();
 /* await AndroidAlarmManager.periodic(const Duration(minutes: 1), checkStatusAlarmID, centerRepository.checkCarStatusPeriodic());
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), checkParkGPSStatusAlarmID, centerRepository.checkParkGPSStatusPeriodic());*/

}//=> runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        //backgroundColor: Color(0xff757575),
      ),
      home: LoginPage(userRepository: new UserRepository(),),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
