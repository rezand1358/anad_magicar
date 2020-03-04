import 'package:anad_magicar/bloc/theme/change_theme_bloc.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/model/apis/api_user_model.dart';
import 'package:anad_magicar/model/user/user.dart';
import 'package:anad_magicar/model/viewmodel/car_page_vm.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/ui/screen/home/index.dart';
import 'package:anad_magicar/widgets/curved_navigation_bar.dart';
import 'package:anad_magicar/widgets/drawer/app_drawer.dart';
import 'package:flutter/material.dart';

abstract class MainPage<T extends StatefulWidget> extends State<T> {


  Widget pageContent();
  String getCurrentRoute();
  int setCurrentTab();
  FloatingActionButton getFab();
  List<Widget> actionIcons();
  initialize();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String imageUrl = 'assets/images/user_profile.png';
  int userId=0;
  int _currentCarId;

  String userName='';
  bool isDark=false;

  getUserName() async {
    userName=await prefRepository.getLoginedUserName();
    userId=await prefRepository.getLoginedUserId();

    centerRepository.setUserCached(new User(userName: userName,
        imageUrl: imageUrl,id: userId),);

  }

  loadLoginedUserInfo(int userId) async {
    List<SaveUserModel> result=await restDatasource.getUserInfo( userId.toString());
    if(result!=null && result.length>0)
    {
      SaveUserModel user=result.first;
      prefRepository.setLoginedPassword(user.Password);
      prefRepository.setLoginedFirstName(user.FirstName);
      prefRepository.setLoginedLastName(user.LastName);
      prefRepository.setLoginedMobile(user.MobileNo);
      prefRepository.setLoginedUserName(user.UserName);

    }
  }

  Future<bool> getAppTheme() async{
    int dark=await changeThemeBloc.getOption();
    setState(() {
      if(dark==1)
        isDark=true;
      else
        isDark=false;
    });

  }



  onCarPageTap()
  {
    Navigator.of(context).pushNamed('/carpage',arguments: new CarPageVM(
        userId: userId,
        isSelf: true,
        carAddNoty: valueNotyModelBloc));
  }

  @override
  void initState() {

    getAppTheme();
    getUserName();
    initialize();
    loadLoginedUserInfo(userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return new WillPopScope(
        onWillPop: () async {
      return false;
    },
    child:
      Scaffold(
      key: _scaffoldKey,
      floatingActionButton: getFab()!=null ? getFab() : null,
      drawer: AppDrawer(carPageTap: onCarPageTap,userName: userName,imageUrl: imageUrl,currentRoute: getCurrentRoute(),carId: CenterRepository.getCurrentCarId(),),
      bottomNavigationBar: CurvedNavigationBar(
        index: setCurrentTab()!=null ? setCurrentTab() : 2,
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
      body:
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
          //automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: actionIcons()!=null ? actionIcons() :
          <Widget>[
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
            pageContent()
    ],
    ),
      ),
    );
  }
}
