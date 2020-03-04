
import 'package:anad_magicar/bloc/theme/change_theme_bloc.dart';
import 'package:anad_magicar/components/fancy_popup/main.dart';
import 'package:anad_magicar/model/viewmodel/car_page_vm.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/ui/screen/home/index.dart';
import 'package:anad_magicar/ui/screen/login/reset/fancy_login/src/models/login_data.dart';
import 'package:anad_magicar/ui/screen/login/reset/reset_password_form.dart';
import 'package:anad_magicar/ui/theme/app_themes.dart';
import 'package:anad_magicar/widgets/curved_navigation_bar.dart';
import 'package:anad_magicar/widgets/drawer/app_drawer.dart';
import 'package:anad_magicar/widgets/drawer/drawer.dart';
import 'package:anad_magicar/widgets/native_settings/src/settings_section.dart';
import 'package:anad_magicar/widgets/native_settings/src/settings_tile.dart';
import 'package:anad_magicar/widgets/native_settings/src/settings_list.dart';
import 'package:flutter/material.dart';


class SecuritySettingsForm extends StatefulWidget {
  bool fromMain=true;

  SecuritySettingsForm({
    @required this.fromMain,
  });
  @override
  SecuritySettingsFormState createState() => SecuritySettingsFormState();


}

class SecuritySettingsFormState extends State<SecuritySettingsForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static final route='/settings';
  String userName='';
  String imageUrl='';
  int userId;
  List<String> themeOptions = <String>[Translations.current.darkTheme(), Translations.current.lightTheme()];
  String selectedThemeOption = Translations.current.lightTheme();
  var itemAppTheme = AppTheme.values[4];

  bool lockInBackground = true;
  bool lightAppTheme=true;
  bool loginRequiered=false;
  bool useFinger=false;
  bool usePattern=false;
  bool usePassword=true;
  bool isDark=false;
  LoginType loginType;

  Future<bool> initLogindata;

   getUserInfo() async{
     userId=await prefRepository.getLoginedUserId();
   }
 getAppTheme() async{
    int dark=await changeThemeBloc.getOption();
    setState(() {
      if(dark==1)
        isDark=true;
      else
        isDark=false;
    });

  }


  Future<String>  _onSignUp(LoginData data)
  {
    return Future.delayed(new Duration(microseconds: 100)).then((_) {
      if (data.password!=null &&
          data.currentPassword!=null &&
          data.confrimPassword!=null &&
          data.password.isNotEmpty &&
          data.currentPassword.isNotEmpty &&
          data.confrimPassword.isNotEmpty) {
        return '';

      }
      return 'NOTOK';
    });
  }

  Future<String> _onReset(LoginData data){
    return Future.delayed(new Duration(microseconds: 100)).then((_) {
      if (data.password!=null &&
          data.currentPassword!=null &&
          data.confrimPassword!=null &&
          data.password.isNotEmpty &&
          data.currentPassword.isNotEmpty &&
          data.confrimPassword.isNotEmpty) {

    return '';
      }
      return 'NoOK';
    });
  }
  showPopUp(String message)
  {
    final popup = BeautifulPopup(
      context: context,
      template: TemplateAuthentication,
    );
    popup.show(
      title: Translations.current.resetPassword(),
      content: message,
      actions: [
        new Column(
          children: <Widget>[
            Container(
              height: 250.0,
              child:
              ResetPasswordForm(
                onCancel: _onSignUp,
                authUser: _onReset,
                onSubmit: () {},
                recoverPassword: null,
              ),
            ),
            popup.button(
              label: Translations.current.exit(),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        )
      ],
// bool barrierDismissible = false,
// Widget close,
    );
  }
  void _toggle() {
    selectedThemeOption=themeOptions[lightAppTheme ? 1 : 0];
    itemAppTheme=AppTheme.values[lightAppTheme ? 4 : 5];
  }
  onCarPageTap()
  {
    Navigator.of(context).pushNamed('/carpage',arguments: new CarPageVM(
        userId: userId,
        isSelf: true,
        carAddNoty: valueNotyModelBloc));
  }
  setAppLogin()
  {
    prefRepository.setLoginStatus(loginRequiered);
    prefRepository.setLoginTypeStatus(loginType);
  }

  _showResetPassword()
  {
    //showPopUp(Translations.current.resetPassword());
    Navigator.of(context).pushNamed('/reset');
  }

  setLoginType(LoginType loginType){
    if(loginType==LoginType.PASWWORD) {
      usePassword = true;
      usePattern=false;
      useFinger=false;
    }
    if(loginType==LoginType.PATTERN) {
      usePassword = false;
      usePattern=true;
      useFinger=false;
    }
    if(loginType==LoginType.FINGERPRINT) {
      usePassword = false;
      usePattern=false;
      useFinger=true;
    }
  }
 Future<bool> getLoginStatus() async {
    bool loginStatus=await prefRepository.getLoginStatusAtAppStarted();
      if(loginStatus!=null)
        loginRequiered = loginStatus;
      else
        loginRequiered = true;

    int loginType_temp = await prefRepository.getLoginStatusTypeAtAppStarted();
    if (loginType_temp != null) {
      if (loginType_temp == LoginType.PASWWORD.index) {
        loginType = LoginType.PASWWORD;
        setLoginType(loginType);
      }
      if (loginType_temp == LoginType.FINGERPRINT.index) {
        loginType = LoginType.FINGERPRINT;
        setLoginType(loginType);
      }
      if (loginType_temp == LoginType.PATTERN.index) {
        loginType = LoginType.PASWWORD;
        setLoginType(loginType);
      }
    }
    else {
      loginType = LoginType.PASWWORD;
    }
    return loginRequiered;

  }

  @override
  void initState() {
    super.initState();
   getUserInfo();
   getAppTheme();
   initLogindata= getLoginStatus();
   userName=centerRepository.getUserCached()!=null ?  centerRepository.getUserCached().userName : '';
   imageUrl=centerRepository.getUserCached()!=null ? centerRepository.getUserCached().imageUrl : '';
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(userName: userName,imageUrl: imageUrl,currentRoute: route,carPageTap: onCarPageTap,carId: CenterRepository.getCurrentCarId(),) ,//buildDrawer(context, route,userName,imageUrl,null,''),
      bottomNavigationBar: CurvedNavigationBar(
        index: 2,
        height: 60.0,
        color: centerRepository.getBackNavThemeColor(!isDark),
        backgroundColor: centerRepository.getBackNavThemeColor(isDark),
        items: <Widget>[
          Icon(Icons.build, size: 30,color: Colors.indigoAccent),
          Icon(Icons.pin_drop, size: 30,color: Colors.indigoAccent),
          Icon(Icons.directions_car , size: 30,color:  Colors.indigoAccent),
          Icon(Icons.message, size: 30,color: Colors.indigoAccent),
          Icon(Icons.payment, size: 30,color: Colors.indigoAccent,),
        ],
        onTap: (index) {
          //Handle button tap
          CenterRepository.onNavButtonTap(context, index,carId: CenterRepository.getCurrentCarId());
        },
      ),
      /*appBar: (widget.fromMain==null || !widget.fromMain) ?
      AppBar(title: Text(Translations.current.appSettings())) :
         null ,*/
      body: FutureBuilder<bool>(
        future: initLogindata,
        builder: (context,snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // loginRequiered=snapshot.data;

            return
              Stack(
                  alignment: Alignment.topCenter,
                  overflow: Overflow.visible,
                  children: <Widget>[
              Align(
              alignment: Alignment(1,-1),
          child:
          Container(
          height:60.0,
          child:
          AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_forward,color: Colors.indigoAccent,),
              onPressed: (){
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
          leading: IconButton(
          icon: Icon(Icons.menu,color: Colors.indigoAccent,),
          onPressed: (){
          _scaffoldKey.currentState.openDrawer();
          },
          ),
          ),
          ),
          ),
              Padding(
                padding: EdgeInsets.only(top: 70.0),
          child:
              SettingsList(
                sections: [

                 /* SettingsSection(
                    title: 'کاربری',
                    tiles: [
                      *//*SettingsTile(
                          title: 'شماره همراه', leading: Icon(Icons.phone)),*//*
                     // SettingsTile(title: 'ایمیل', leading: Icon(Icons.email)),
                      SettingsTile(title: 'خروج از حساب کاربری',
                        leading: Icon(Icons.exit_to_app),
                        onTap: () {
                          Navigator.of(context).pushNamed('/logout');
                        },),
                    ],
                  ),*/
                  SettingsSection(
                    title: 'امنیتی',
                    tiles: [

                      SettingsTile.switchTile(
                        leftPadding: 25.0,
                        rightPadding: 2.0,
                        title: Translations.current.useLogin(),
                        leading: Icon(Icons.phonelink_lock),
                        switchValue: loginRequiered,
                        onTap: () {
                          setState(() {
                            loginRequiered = !loginRequiered;
                            if (loginRequiered) {
                              usePattern = !loginRequiered;
                              usePassword = loginRequiered;
                              useFinger = !loginRequiered;
                            }
                            else {
                              usePattern = loginRequiered;
                              usePassword = loginRequiered;
                              useFinger = loginRequiered;
                            }
                            //if (loginRequiered)
                              setAppLogin();
                          });
                        },
                        onToggle: (bool value) {
                          setState(() {
                            loginRequiered = value;
                            if (value) {
                              usePattern = !value;
                              usePassword = value;
                              useFinger = !value;
                            }
                            else {
                              usePattern = value;
                              usePassword = value;
                              useFinger = value;
                            }
                            //if (value)
                              setAppLogin();
                          });
                        },
                      ),
                      SettingsTile.switchTile(
                          leftPadding: 25,
                          rightPadding: 2,
                          title: Translations.current.useFingerPrint(),
                          leading: Icon(Icons.fingerprint),
                          onTap: () {
                            setState(() {
                              useFinger = !useFinger;
                              if (useFinger) {
                                usePattern = !useFinger;
                                usePassword = !useFinger;
                                loginType = LoginType.FINGERPRINT;
                              }
                              setAppLogin();
                            });
                          },
                          onToggle: (bool value) {
                            setState(() {
                              useFinger = value;
                              if (value) {
                                usePattern = !value;
                                usePassword = !value;
                                loginType = LoginType.FINGERPRINT;
                              }
                              setAppLogin();
                            });
                          },
                          switchValue: useFinger),
                     /* SettingsTile.switchTile(
                          leftPadding: 25,
                          rightPadding: 2,
                          title: Translations.current.usePattern(),
                          leading: Icon(Icons.apps),
                          onTap: () {
                            setState(() {
                              usePattern = !usePattern;
                              if (usePattern) {
                                usePassword = !usePattern;
                                useFinger = !usePattern;
                                loginType = LoginType.PATTERN;
                              }
                              setAppLogin();
                            });
                          },
                          onToggle: (bool value) {
                            setState(() {
                              usePattern = value;
                              if (value) {
                                usePassword = !value;
                                useFinger = !value;
                                loginType = LoginType.PATTERN;
                              }
                              setAppLogin();
                            });
                          },
                          switchValue: usePattern),*/
                      SettingsTile.switchTile(
                          leftPadding: 25,
                          rightPadding: 2,
                          title: Translations.current.usePassword(),
                          leading: Icon(Icons.security),
                          onTap: () {
                            setState(() {
                              usePassword = !usePassword;
                              if (usePassword) {
                                usePattern = !usePassword;
                                useFinger = !usePassword;
                                loginType = LoginType.PASWWORD;
                              }
                              else {

                              }
                              setAppLogin();
                            });
                          },
                          onToggle: (bool value) {
                            setState(() {
                              usePassword = value;
                              if (value) {
                                usePattern = !value;
                                useFinger = !value;
                                loginType = LoginType.PASWWORD;
                              }
                              else {

                              }
                              setAppLogin();
                            });
                          },
                          switchValue: usePassword),
                      SettingsTile(
                        title: 'تغییر رمز عبور',
                        leading: Icon(Icons.lock),
                        onTap: () {
                          _showResetPassword();
                        },
                      ),
                    ],
                  ),
          ],
          ),
              ),
                ],
              );
          }
          else
            {
              return Container();
            }
        },

      ),
     // ),
    );
  }
}
