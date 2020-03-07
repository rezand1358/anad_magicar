
import 'dart:async';
import 'dart:io';

import 'package:anad_magicar/bloc/base_class/base_widget_state.dart';
import 'package:anad_magicar/bloc/theme/change_theme_bloc.dart';
import 'package:anad_magicar/bloc/theme/change_theme_state.dart';
import 'package:anad_magicar/bloc/theme/theme.dart';
import 'package:anad_magicar/components/flushbar/flushbar.dart';
import 'package:anad_magicar/components/loading_indicator.dart';
import 'package:anad_magicar/components/logout_form.dart';
import 'package:anad_magicar/components/pull_refresh/pull_to_refresh.dart';
import 'package:anad_magicar/components/pull_refresh/refresh_glowindicator.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/data/rxbus.dart';
import 'package:anad_magicar/firebase/message/firebase_message_handler.dart';
import 'package:anad_magicar/firebase/message/message_handler.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/model/message.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/repository/user/user_repo.dart';
import 'package:anad_magicar/ui/map/countries.dart';
import 'package:anad_magicar/ui/map/live/sidebar.dart';
import 'package:anad_magicar/ui/map/mapbox/main.dart';
import 'package:anad_magicar/ui/map/mapbox/map_ui.dart';
import 'package:anad_magicar/ui/map/openmapstreet/pages/home.dart';
import 'package:anad_magicar/ui/map/openmapstreet/pages/plugin_scalebar.dart';
import 'package:anad_magicar/ui/screen/AnimatedSplashScreen.dart';
import 'package:anad_magicar/ui/screen/car/car_page.dart';
import 'package:anad_magicar/ui/screen/car/register_car_screen.dart';
import 'package:anad_magicar/ui/screen/device/register_device.dart';
import 'package:anad_magicar/ui/screen/home/index.dart';
import 'package:anad_magicar/ui/screen/loading_screen.dart';
import 'package:anad_magicar/ui/screen/login/finger_print_auth.dart';
import 'package:anad_magicar/ui/screen/login/login2.dart';
import 'package:anad_magicar/ui/screen/login/login_page.dart';
import 'package:anad_magicar/ui/screen/login/reset/reset_screen.dart';
import 'package:anad_magicar/ui/screen/message/message_history_screen.dart';
import 'package:anad_magicar/ui/screen/message_app/message_app_page.dart';
import 'package:anad_magicar/ui/screen/message_app/new_message_item.dart';
import 'package:anad_magicar/ui/screen/payment/invoice_form.dart';
import 'package:anad_magicar/ui/screen/payment/plan_screen.dart';
import 'package:anad_magicar/ui/screen/profile/profile2.dart';
import 'package:anad_magicar/ui/screen/register/edit_profile.dart';
import 'package:anad_magicar/ui/screen/register/register_screen.dart';
import 'package:anad_magicar/ui/screen/service/register_service_page.dart';
import 'package:anad_magicar/ui/screen/service/service_page.dart';
import 'package:anad_magicar/ui/screen/service/service_type/register_service_type_page.dart';
import 'package:anad_magicar/ui/screen/service/service_type/service_type_page.dart';
import 'package:anad_magicar/ui/screen/setting/global_setting_page.dart';
import 'package:anad_magicar/ui/screen/setting/native_settings_screen.dart';
import 'package:anad_magicar/ui/screen/setting/security_screen.dart';
import 'package:anad_magicar/ui/screen/setting/setting_screen.dart';
import 'package:anad_magicar/ui/screen/user/user_access_detail.dart';
import 'package:anad_magicar/ui/screen/user/user_page.dart';
import 'package:anad_magicar/ui/screen/user/users_page.dart';
//import 'package:anad_magicar/ui/screen/user/users_page.dart';
import 'package:anad_magicar/utils/check_status_connection.dart';
import 'package:anad_magicar/widgets/flash_bar/flash.dart';
import 'package:anad_magicar/widgets/flash_bar/flash_helper.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:anad_magicar/ScopeModelWrapper.dart';
import 'package:anad_magicar/TranslationsDelegate.dart';
import 'package:anad_magicar/authentication/authentication.dart';
import 'package:anad_magicar/bloc/basic/global_bloc.dart';
import 'package:anad_magicar/common/common.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:anad_magicar/bloc/basic/bloc_provider.dart' as gbloc;

import 'package:anad_magicar/ui/screen/service/main_service_page.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
BehaviorSubject<String>();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification(
      {@required this.id,
        @required this.title,
        @required this.body,
        @required this.payload});
}

class Routes {

  void _enablePlatformOverrideForDesktop() {
    if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    }
  }

  Routes() {

    /*GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
    CatcherOptions debugOptions =
    CatcherOptions(DialogReportMode(), [ConsoleHandler(),HttpHandler(HttpRequestType.post, Uri.parse(RestDatasource.BASE_URL),
        printLogs: true)] ,
        localizationOptions: [
          LocalizationOptions("en", notificationReportModeTitle: Translations.current.reportModeTitle()),
          LocalizationOptions("fa", notificationReportModeTitle: Translations.current.reportModeTitle()),
        ]);
    CatcherOptions releaseOptions = CatcherOptions(DialogReportMode(), [
      EmailManualHandler(["anad@email.com"])
    ],
        localizationOptions: [
          LocalizationOptions("en", notificationReportModeTitle: Translations.current.reportModeTitle()),
          LocalizationOptions("fa", notificationReportModeTitle: Translations.current.reportModeTitle()),
        ]);
    CatcherOptions profileOptions = CatcherOptions(DialogReportMode(), [ConsoleHandler(), ToastHandler()],);
    Catcher(ScopeModelWrapperState(navigatorKey : navigatorKey), debugConfig: debugOptions, releaseConfig: releaseOptions, profileConfig: profileOptions, enableLogger: false, navigatorKey: navigatorKey);
*/

    _enablePlatformOverrideForDesktop();


    runApp(new ScopeModelWrapperState(userRepository: UserRepository(),));


  }
}


class MyApp extends StatefulWidget {
  //final GlobalKey<NavigatorState> navigatorKey;
  final UserRepository userRepository;

   MyApp({Key key, this.userRepository}) : super(key: key);

  @override
  _MyAppState createState() {

    return _MyAppState();
  }

}
class _MyAppState extends State<MyApp>
{
  final MethodChannel platform =
  MethodChannel('crossingthestreams.io/resourceResolver');

  //MyApp get _widget => widget as MyApp;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AuthenticationBloc _authenticationBloc;
  UserRepository get _userRepository => widget.userRepository;
  ThemeBloc _themeBloc;
  Future<Locale> local;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void _showTopFlash(String title,String message, {FlashStyle style = FlashStyle.floating}) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 2),
      persistent: true,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: Colors.redAccent,
          brightness: Brightness.light,
          boxShadows: [BoxShadow(blurRadius: 4)],
          barrierBlur: 3.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          style: style,
          position: FlashPosition.top,
          child: FlashBar(
            title: Text(title,style: TextStyle(color: Colors.amberAccent),),
            message: Text(message,style: TextStyle(color: Colors.amberAccent)),
            showProgressIndicator: true,
            primaryAction: FlatButton(
              onPressed: () => controller.dismiss(),
              child: Text(Translations.current.close(), style: TextStyle(color: Colors.amber)),
            ),
          ),
        );
      },
    );
  }

  showSnackLogin(BuildContext context,String message,bool isLoading)
  {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar( duration: new Duration(seconds: 6),
          backgroundColor: Colors.amber,
          elevation: 0.8,
          content:
          Container(
            height: MediaQuery.of(context).size.height/3.5,
            child:
            new Column(

              children: <Widget>[
                isLoading ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new CircularProgressIndicator() ,
                      // new Text(message,style: TextStyle(fontFamily: 'IranSans',fontSize: 20.0),)
                    ]) :
                new Icon(Icons.error_outline,color: Colors.black,),
                Expanded(
                  child:
                  new Text(message,style: TextStyle(fontFamily: 'IranSans',fontSize: 20.0),),),
              ],
            ),
          ),
        ));
  }

 /* checkConnection()
  {
    if(!isOnline)
    {
      showSnackLogin(context, Translations.current.noConnection(), false);
    }
  }*/

 /*showMessage(Map<String,dynamic> message)
 {
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
   }
 }*/
   @override
  void initState() {


    // messageHandler.initMessageHandler();

    _authenticationBloc = AuthenticationBloc(userRepository: _userRepository);
    _themeBloc=ThemeBloc();
   // _authenticationBloc.dispatch(AppStarted());
    super.initState();
   // checkConnection();
     ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
     connectionStatus.initialize();
    initConnectivity();
    //FlashHelper.init(context);
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    local= prefRepository.fetchLocale();


     didReceiveLocalNotificationSubject.stream
         .listen((ReceivedNotification receivedNotification) async {
       await showDialog(
         context: context,
         builder: (BuildContext context) => CupertinoAlertDialog(
           title: receivedNotification.title != null
               ? Text(receivedNotification.title)
               : null,
           content: receivedNotification.body != null
               ? Text(receivedNotification.body)
               : null,
           actions: [
             CupertinoDialogAction(
               isDefaultAction: true,
               child: Text('Ok'),
               onPressed: () async {
                 Navigator.of(context, rootNavigator: true).pop();
                 await Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) {
                       return Container(width: 0.0,height: 0.0,);
                     }
                       //  SecondScreen(receivedNotification.payload),
                   ),
                 );
               },
             )
           ],
         ),
       );
     });
     selectNotificationSubject.stream.listen((String payload) async {
       await Navigator.push(
         context,
         MaterialPageRoute(builder: (context) {
          return Container(width: 0.0,height: 0.0,); }
         ),
       );
     });


     FlashHelper.init(context);
  }


  @override
  void dispose() {
    _authenticationBloc.close();
    _connectivitySubscription.cancel();
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    FlashHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<Locale>(
        future: local,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            // Return some loading widget
              return CircularProgressIndicator();
            case ConnectionState.done:
              if (snapshot.hasError) {
                // Return some error widget
                return Text('Error: ${snapshot.error}');
              } else {
               // Locale fetchedLocale = snapshot.data;

                return
                  ScopedModelDescendant<AppModel>(
                      builder: (context, child, model) {
                        return
                          BlocProvider<AuthenticationBloc>(
                            create: (
                                BuildContext context) => _authenticationBloc,
                            child:
                            gbloc.BlocProvider<GlobalBloc>(
                              bloc: GlobalBloc(),
                              child:
                              BlocBuilder<ChangeThemeBloc,ChangeThemeState>(
                                  bloc: changeThemeBloc,
                                  builder: (BuildContext context,
                                      ChangeThemeState state) {
                                    return
                                      RefreshConfiguration(
                                        footerTriggerDistance: 15,
                                        dragSpeedRatio: 0.91,
                                        headerBuilder: () => MaterialClassicHeader(),
                                    footerBuilder: () => ClassicFooter(),
                                    enableLoadingWhenNoData: false,
                                    shouldFooterFollowWhenNotFull: (state) {
                                    // If you want load more with noMoreData state ,may be you should return false
                                    return false;
                                    },
                                    autoLoad: true,
                                    child:
                                      new MaterialApp(
                                        //navigatorKey: widget.navigatorKey,
                                       /* builder: (BuildContext context, Widget widget) {
                                          Catcher.addDefaultErrorWidget(
                                              showStacktrace: true,
                                              customTitle: Translations.current.errorInUIs(),
                                              customDescription: Translations.current.errorInUIsDescription());
                                          return widget;
                                        },*/
                                        builder: (context, child) {
                                      return  ScrollConfiguration(
                                        child: child,
                                        behavior: RefreshScrollBehavior()
                                        );
                                        },
                                        locale: model.appLocal,
                                        localizationsDelegates: [
                                          // _localeOverrideDelegate,
                                          const TranslationsDelegate(),
                                          GlobalMaterialLocalizations.delegate,
                                          GlobalWidgetsLocalizations.delegate,
                                        ],
                                        supportedLocales: [
                                          const Locale('fa', ''), // Farsi
                                          const Locale('en', ''), // English
                                        ],
                                        //supportedLocales: applic.supportedLocales(),
                                        onGenerateTitle: (
                                            BuildContext context) =>
                                            Translations.of(context).title(),
                                        debugShowCheckedModeBanner: false,
                                        theme: state.themeData,
                                        //ThemeData(fontFamily: 'IranSans'),
                                        home: BlocBuilder<
                                            AuthenticationBloc,
                                            AuthenticationState>(
                                          //builder:(BuildContext context)=> _authenticationBloc,
                                          bloc: _authenticationBloc,
                                          builder: (BuildContext context,
                                              AuthenticationState state) {
                                            if (state is AuthenticationUninitialized) {
                                              return new AnimatedSplashScreen(
                                                  _authenticationBloc); //LoginPage(userRepository: UserRepository());
                                            }
                                            if (state is AuthenticationAuthenticated) {
                                              //Navigator.pushReplacementNamed(context, '/home');
                                              // return HomeScreen();
                                              return new LoadingScreen(messageHandler: null,);
                                            }
                                            if (state is AuthenticationLoading) {
                                              return LoadingIndicator();
                                            }
                                            if (state is AuthenticationUnauthenticated) {
                                              return new LoginPage(messageHandler: null,loginType: state.loginType,
                                                userRepository: UserRepository(),);
                                            }
                                            return new AnimatedSplashScreen(
                                                _authenticationBloc);
                                          },
                                        ),
                                        onGenerateRoute: (
                                            RouteSettings settings) {
                                          switch (settings.name) {
                                            case '/login':
                                              return new MyCustomRoute(
                                                builder: (_) =>
                                                new LoginPage(
                                                  messageHandler: null,
                                                  userRepository: UserRepository(),loginType: settings.arguments,),
                                                settings: settings,
                                              );

                                            case '/home':
                                              return new MyCustomRoute(
                                                builder: (
                                                    _) => new HomeScreen(),
                                                settings: settings,
                                              );
                                            case '/register':
                                              return new MyCustomRoute(
                                                builder: (_) => new RegisterScreen(mobile: settings.arguments,),
                                                // new RegisterScreen(),
                                                settings: settings,
                                              );
                                            case '/editprofile':
                                              return new MyCustomRoute(
                                                builder: (_) => new EditProfileScreen(),
                                                // new RegisterScreen(),
                                                settings: settings,
                                              );
                                            case '/adduser':
                                              return new MyCustomRoute(
                                                builder: (_) => new RegisterScreen(),
                                                // new RegisterScreen(),
                                                settings: settings,
                                              );
                                            case '/myprofile':
                                              return new MyCustomRoute(
                                                builder: (_) =>
                                                new ProfileTwoPage( user: settings.arguments),
                                                settings: settings,
                                              );
                                            case '/addcar':
                                              return new MyCustomRoute(
                                                builder: (_) => new RegisterCarScreen(addCarVM: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/carpage':
                                              return new MyCustomRoute(
                                                builder: (_) => new CarPage(carPageVM: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/messages':
                                              return new MyCustomRoute(
                                                builder: (_) => new MessageHistoryScreen(carId: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/messageapp':
                                              return new MyCustomRoute(
                                                builder: (_) => new MessageAppPage(carId: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/messageappdetail':
                                              return new MyCustomRoute(
                                                builder: (_) => new NewMessageItem(detailVM: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/servicepage':
                                              return new MyCustomRoute(
                                                builder: (_) => new MainPageService(serviceVM: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/servicetypepage':
                                              return new MyCustomRoute(
                                                builder: (_) => new ServiceTypePage(carId: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/registerservicepage':
                                              return new MyCustomRoute(
                                                builder: (_) => new RegisterServicePage(serviceVM: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/registerservicetypepage':
                                              return new MyCustomRoute(
                                                builder: (_) => new RegisterServiceTypePage(regServiceTypeVM: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/adddevice':
                                              return new MyCustomRoute(
                                                builder: (_) => new RegisterDeviceScreen(hasConnection: true,
                                                  userId: CenterRepository.getUserId(),
                                                  changeFormNotyBloc: changeFormNotyBloc,
                                                  fromMainApp: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/mappage':
                                              return new MyCustomRoute(
                                                builder: (_) => new MapPage(mapVM: settings.arguments,), //MapUiPage(mapVM: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/fingerprint':
                                              return new MyCustomRoute(
                                                builder: (_) => new TouchID(),
                                                settings: settings,
                                              );
                                            case '/settings':
                                              return new MyCustomRoute(
                                                builder: (_) => new SecuritySettingsScreen(fromMain: settings.arguments,),
                                                settings: settings,
                                              );
                                            case '/appsettings':
                                              return new MyCustomRoute(
                                                builder: (
                                                    _) => new SettingsScreen()/*PreferencePage()*/,
                                                settings: settings,
                                              );
                                            case '/loadingscreen':
                                              return new MyCustomRoute(
                                                builder: (_) => new LoadingScreen(messageHandler: null,),
                                                settings: settings,
                                              );
                                            case '/showusers':
                                              return new MyCustomRoute(
                                                builder: (_) => new UsersPage(),
                                                settings: settings,
                                              ); case '/showuser':
                                            return new MyCustomRoute(
                                              builder: (_) => new UserAccessPage(accessableActionVM: settings.arguments,),
                                              settings: settings,
                                            );
                                            case '/logout':
                                              return new MyCustomRoute(
                                                builder: (_) => new LogoutForm(),
                                                settings: settings,
                                              );
                                            case '/plans':
                                              return new MyCustomRoute(
                                                builder: (_) => new InvoiceForm(),
                                                settings: settings,
                                              );
                                            case '/reset':
                                              return new MyCustomRoute(
                                                builder: (_) => new ResetScreen(),
                                                settings: settings,
                                              );

                                          case '/plugin_scalebar':
                                          return new MyCustomRoute(
                                          builder: (_) => new PluginScaleBar(),
                                          settings: settings,
                                          );
                                          }
                                          return new MyCustomRoute(
                                            builder: (_) =>
                                            new LoginPage(
                                              messageHandler: null,
                                              loginType: settings.arguments,
                                              userRepository: UserRepository(),),
                                            settings: settings,
                                          );
                                        },

                                        // },
                                      ),
                                      );
                                  },
                                ),
                              ),
                           // ),
                          );
                        //}
                        //)
                      });
              }
              break;
            case ConnectionState.active:
              // TODO: Handle this case.
              break;
          }
          return CircularProgressIndicator();
        }
    );
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }



  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        RxBus.post(new ChangeEvent(type: 'INTERNET',message: 'NO_INTERNET'));
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

}


class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);


  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {

    var begin = Offset(0.0, 1.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    //if (settings.isInitialRoute) return child;

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
