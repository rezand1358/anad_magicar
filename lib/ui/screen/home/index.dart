import 'dart:convert';
import 'dart:typed_data';

import 'package:anad_magicar/bloc/basic/bloc_provider.dart';
import 'package:anad_magicar/bloc/basic/global_bloc.dart';
import 'package:anad_magicar/bloc/shopcart/cart.dart';
import 'package:anad_magicar/bloc/shopcart/shoppingcart.dart';
import 'package:anad_magicar/bloc/theme/change_theme_bloc.dart';
import 'package:anad_magicar/bloc/values/notify_value.dart';
import 'package:anad_magicar/common/actions_constants.dart';
import 'package:anad_magicar/common/constants.dart';
import 'package:anad_magicar/components/CircleImage.dart';
import 'package:anad_magicar/components/bottomsheet/bottom_sheet_animated.dart';
import 'package:anad_magicar/components/circle_badge.dart';
import 'package:anad_magicar/components/engine_status.dart';
import 'package:anad_magicar/components/flushbar/flushbar_helper.dart';
import 'package:anad_magicar/components/intervalprogressbar.dart';
import 'package:anad_magicar/components/pull_refresh/pull_to_refresh.dart';
import 'package:anad_magicar/data/database_helper.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/data/rxbus.dart';
import 'package:anad_magicar/data/server.dart';
import 'package:anad_magicar/model/apis/api_related_user_model.dart';
import 'package:anad_magicar/model/apis/api_user_model.dart';
import 'package:anad_magicar/model/cars/car.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/model/message.dart';
import 'package:anad_magicar/model/send_command_model.dart';
import 'package:anad_magicar/model/send_command_vm.dart';
import 'package:anad_magicar/model/user/admin_car.dart';
import 'package:anad_magicar/model/user/user.dart';
import 'package:anad_magicar/model/viewmodel/accessable_action_vm.dart';
import 'package:anad_magicar/model/viewmodel/car_page_vm.dart';
import 'package:anad_magicar/model/viewmodel/car_state.dart';
import 'package:anad_magicar/model/viewmodel/map_vm.dart';
import 'package:anad_magicar/model/viewmodel/service_vm.dart';
import 'package:anad_magicar/model/viewmodel/status_noti_vm.dart';
import 'package:anad_magicar/notifiers/opacity.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/service/noti_analyze.dart';
import 'package:anad_magicar/translation_strings.dart';

import 'package:anad_magicar/ui/hiddendrawer/hidden_drawer/hidden_drawer_menu.dart';
import 'package:anad_magicar/ui/hiddendrawer/hidden_drawer/screen_hidden_drawer.dart';
import 'package:anad_magicar/ui/hiddendrawer/simple_hidden_drawer/provider/simple_hidden_drawer_provider.dart';
import 'package:anad_magicar/ui/screen/car/car_page.dart';
import 'package:anad_magicar/ui/screen/car/register_car_screen.dart';
import 'package:anad_magicar/ui/screen/home/home.dart';
import 'package:anad_magicar/ui/screen/home/home.dart' as prefix0;
import 'package:anad_magicar/ui/screen/login/login2.dart';
import 'package:anad_magicar/ui/screen/login/logout_dialog.dart';
import 'package:anad_magicar/ui/screen/message_app/message_app_page.dart';
import 'package:anad_magicar/ui/screen/profile/profile2.dart';
import 'package:anad_magicar/ui/screen/register/register_screen.dart';
import 'package:anad_magicar/ui/screen/setting/global_setting_page.dart';
import 'package:anad_magicar/ui/screen/setting/native_settings_screen.dart';
import 'package:anad_magicar/ui/screen/setting/security_screen.dart';
import 'package:anad_magicar/ui/screen/setting/setting_screen.dart';
import 'package:anad_magicar/ui/screen/user/user_access_detail.dart';
import 'package:anad_magicar/utils/dart_helper.dart';
import 'package:anad_magicar/widgets/appbar_collapse.dart';
import 'package:anad_magicar/widgets/bottom_sheet_custom.dart';
import 'package:anad_magicar/widgets/curved_navigation_bar.dart';
import 'package:anad_magicar/widgets/drawer/app_drawer.dart';
import 'package:anad_magicar/widgets/drawer/circular_image.dart';
import 'package:anad_magicar/widgets/drawer/drawer.dart';
import 'package:anad_magicar/widgets/flash_bar/flash.dart';
import 'package:anad_magicar/widgets/flash_bar/flash_helper.dart';
import 'package:anad_magicar/widgets/flutter_offline/flutter_offline.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:sqflite/utils/utils.dart';
import 'styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:after_layout/after_layout.dart';
import 'dart:math' as math;
import 'dart:convert' as hx;
//import 'package:assets_audio_player/assets_audio_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() =>
  new HomeScreenState();
}

enum MaterialColor {RED,BLUE,YELLOW,GREEN,BLACK,WHITE}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin ,
    AfterLayoutMixin<HomeScreen>{

  static const String route='/home';

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName='';
  int userId;
  bool hasInternet=true;
  static bool sendingCommand=false;
  static bool sentCommand=false;
  static bool sentCommandHasError=false;

  static int currentCarIndex=0;
  int commandProgressValue=0;
  CarStateVM currentCarState;
  SolidController _solidBottomSheetController = SolidController();
  List<ScreenHiddenDrawer> itens = new List();

  Animation<double> containerGrowAnimation;
  AnimationController _screenController;
  AnimationController _buttonController;
  AnimationController animController;
  AnimationController animProgressController;
  Animation<double> buttonGrowAnimation;
  Animation<double> listTileWidth;
  Animation<Alignment> listSlideAnimation;
  Animation<Alignment> buttonSwingAnimation;
  Animation<EdgeInsets> listSlidePosition;
  Animation<Color> fadeScreenAnimation;
  var animateStatus = 0;
  static Size screenSize;
  ScrollController _controller;

  Animation animation, transformationAnim;
  AnimationController animationController;
  AnimationController rotationController;

  CurvedAnimation _progressAnimation;
   Animation<Color> progressIndicatorValueColor;
   Color progressIndicatorBackgroundColor;
   AnimationController progressIndicatorController;

  int carCount=0;
  int maxCarCounts=Constants.MAX_CAR_COUNTS;
  final String imageUrl = 'assets/images/user_profile.png';
  String startImagePath='assets/images/car_start_3_1.png';
  final int registerId=0;
  final int helpId=10;
  final int searchId=20;
  final int shopId=30;
  final int basketId=40;
  final int myProgramsId=50;


  OpacityNotifier opacityNotifier;
  Server server=new Server();
  StreamSubscription<String> _subscription;
  String message='';
  String bottomSheetMessage='';

  bool isLoginned=true;
  bool isAdmin;
  int _counter=0;
  int messageCounts=0;
  User user;
  bool engineStatus=false;
  bool lockStatus=true;
  bool trunkStatus=false;
  bool caputStatus=false;
  bool isDark=false;
  Future<List<AdminCarModel>> refreshedCars;
  List<AdminCarModel> newCarsList;
  int currentBottomNaviSelected=2;
  var startEnginChangedNoty=new NotyBloc<Message>();
  //var statusChangedNoty=new NotyBloc<CarStateVM>();
  var carPageChangedNoty=new NotyBloc<Message>();
  var carLockPanelNoty=new NotyBloc<Message>();
  var sendCommandNoty=new NotyBloc<SendingCommandVM>();
  var messageCountNoty=new NotyBloc<Message>();
  //var valueNotyModelBloc=new NotyBloc<ChangeEvent>();

  var _currentColor=Colors.redAccent;
  int _currentCarId=0;
  //cars
  final double _initFabHeight = 30.0;
  double _fabHeight;
  double _panelHeightOpen =320.0;
  double _panelHeightClosed = 35.0;
  bool panelIsOpen=false;
  //AssetsAudioPlayer _assetsAudioPlayer;

   AudioCache player = AudioCache();
  AudioPlayer advancedPlayer;

  play()  {
     player.play('car_door_lock.mp3');
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

  getAdminCarsToUser() async {
    List<AdminCarModel> cars=new List();
    List<AdminCarModel> carsInWaiting=new List();

    RestDatasource restDS=new RestDatasource();
    cars=await restDS.getAllCarsToAdmin(userId);
    if(cars!=null &&
    cars.length>0)
      {
          carsInWaiting=cars.where((c)=> c.CarToUserStatusConstId==Constants.CAR_TO_USER_STATUS_WAITING_TAG).toList();
          if(carsInWaiting!=null &&
          carsInWaiting.length>0)
            {
              Navigator.pushNamed(context, '/carpage',arguments: new CarPageVM(
                  userId: userId, isSelf: false, carAddNoty: null));

            }
      }
  }

  getCarCounts() async {
     prefRepository.getCarsCount().then((value) {
       setState(() {
         carCount=value;
         if(carCount > maxCarCounts)
           carCount=maxCarCounts;

         centerRepository.setInitCarStateVMMap(carCount);
       });
     });
  }

  getUserName() async {
   userName=await prefRepository.getLoginedUserName();
   userId=await prefRepository.getLoginedUserId();
   CenterRepository.setUserId(userId);
   centerRepository.setUserCached(new User(userName: userName,
   imageUrl: imageUrl,id: userId),);

  }

  onCarPageTap()
  {
    Navigator.of(context).pushNamed('/carpage',arguments: new CarPageVM(
        userId: userId,
        isSelf: true,
        carAddNoty: valueNotyModelBloc));
  }
  animateEngineStatus()
  {
    animationController =
        AnimationController(duration: Duration(seconds: 8), vsync: this);

    animation = Tween(begin: 10.0, end: 200.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.ease));

    transformationAnim = BorderRadiusTween(
        begin: BorderRadius.circular(150.0),
        end: BorderRadius.circular(0.0))
        .animate(
        CurvedAnimation(parent: animationController, curve: Curves.ease));
    //animationController.forward();
  }

  updateItemCounts(bool increment)
  {
   //setState(() {
     if(increment)
       this._counter=this._counter+1;
     else
     if(this._counter > 0)
       this._counter=this._counter-1;
   //});
  }



  Container createHomeCarPage(List menus,int carIndex)
  {
       return
         Container(
           child: ChangeNotifierProvider<OpacityNotifier>(
             create: (context) => OpacityNotifier(0.0),
           child:
           Material(
             child:
             Consumer<OpacityNotifier> (
                 builder: (context,opacity,child) {
  return
  Stack(
  alignment: Alignment.bottomCenter,
  children: <Widget>[
  SlidingUpPanel(
  renderPanelSheet: false,
  maxHeight: _panelHeightOpen,
  minHeight: _panelHeightClosed,
  parallaxEnabled: true,
  parallaxOffset: 0.05,
  defaultPanelState: PanelState.OPEN,
  body: _carBody(menus, carIndex),

  panel: _carPanel(menus),
  collapsed: _floatingCollapsed(),
  // padding: EdgeInsets.all(0.0),
  // margin: EdgeInsets.all(0.0),
  panelSnapping: true,
  onPanelOpened: () {
  panelIsOpen = true;
  opacity.decrement();
  },
  onPanelClosed: () {
  panelIsOpen = false;
  opacity.increment();
  },
  //collapsed: Icon(Icons.open_with),
  //borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
  onPanelSlide: (double pos) =>
  setState(() {
  _fabHeight =
  pos * (_panelHeightOpen - _panelHeightClosed) +
  _initFabHeight;

  //panelIsOpen ? opacityNotifier.decrement() : opacityNotifier.increment();
  }),
  ),

  ],
           );
       //  ),
     },
               ),
    ),
           ),
     );
  }
  Widget _floatingCollapsed(){
    return Container(
     // height: 260.0,
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
      ),
      margin: const EdgeInsets.fromLTRB(50.0, 2.0, 50.0, 1.0),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
           // width: 68.0,
           // height: 68.0,
            child:
              Image.asset('assets/images/up.png',fit: BoxFit.cover,width: 28.0,height: 28.0,),
          ),
        ],
      ),
    );
  }

  _carPanel(List menus){
    return Container(
      //height: MediaQuery.of(context).size.height/2.0,
      decoration: BoxDecoration(
          //color: Colors.greenAccent,
        border: Border.all(color: Colors.white10,width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2.0,
              color: Colors.transparent,
            ),
          ]
      ),
      //margin: const EdgeInsets.all(10.0),
      margin: EdgeInsets.only(top: 2.0,left: 10.0,right: 10.0,bottom: 5.0),
      //color: Color(0xffffffff),
      child: Column(
        children: <Widget>[
          SizedBox(height: 1.0,),
          _buildRows(menus, context, 4),
        ],
      ),
    );
  }
  _carBody(List menus,int carIndex)
  {
    return

    Container(
      margin: EdgeInsets.only(bottom: 6.0),
      alignment: Alignment.bottomCenter,
      //color: Color(0xff757575),
      height: MediaQuery
          .of(context)
          .size
          .height-1.0,
      child:
     Stack (
       children: <Widget>[
         _buildRows(menus, context, 3),

      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[



      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          _buildRows(menus, context, 2),
          _buildRows(menus, context, 0),
          _buildRows(menus, context, 1),
          //buildArrowRow(context,carIndex,true),

        ],
      ),

      ],
      ),
       ],
     ),
    );
  }


  List createHomeAllCarPages(int carCounts,List pages)
  {
     List finalPages=new List();
     finalPages=pages;
     return finalPages;
  }
  Widget _buildRows(List menues, BuildContext context,int pos)
  {
    screenSize = MediaQuery
        .of(context)
        .size;
    List scrollList=menues;//createScrollContents(context);
    return  scrollList[pos];

  }
  List  createHomeScrollList(String startImg,int carIndex,bool left)
    {
      return createScrollContents(context,startImg,carIndex,left);
    }

  List createScrollContents(BuildContext context,String startImg,int carIndex,bool left) {

    CarStateVM carStateVM=centerRepository.getCarStateVMByCarIndex(carIndex);
   // int carId=centerRepository.getCarIdByIndex(carIndex);
    final List scrollContents = [


    buildCarRow(context,
      carPageChangedNoty,
        statusChangedNoty,
      carIndex,
        carStateVM,
      rotationController,
      _counter),
      //),
      buildStatusRow(context,
          carPageChangedNoty,
          statusChangedNoty,
          carStateVM,
          lockStatus,
          false,
          engineStatus,
          animController),
      buildMapRow(context,
          carStateVM,
          carPageChangedNoty,
      statusChangedNoty,
          animController),
      buildArrowRow(context,
          carIndex,
          carStateVM,
          left,
          carPageChangedNoty,
      opacityNotifier),

     new EngineStatus(engineStatus: engineStatus,
         lockStatus: lockStatus,
         color: _currentColor,
         carPageNoty: carPageChangedNoty,
         carStateVM: carStateVM,
         carStateNoty: statusChangedNoty,
         sendCommandNoty: sendCommandNoty,),
    ];
    return scrollContents;
  }


  Color clr = Colors.lightBlueAccent;
  _scrollListener() {
    if (_controller.offset > _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        clr = Colors.blueAccent;
      });
    }

    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        clr = Colors.lightBlueAccent;
      });
    }

  }

   getEngineStatus() async {
    engineStatus=await prefRepository.getStartEngineStatus();
    if(engineStatus==null)
      engineStatus=false;
   }

   setEngineStatus(bool status) async {
   await prefRepository.setEngineStatus(status);
   }

  getLockStatus() async {
    lockStatus=await prefRepository.getLockStatus();
    if(lockStatus==null)
      lockStatus=false;
  }

  setLockStatus(bool status) async {
    await prefRepository.setLockStatus(status);
  }

  List<Container> createCarPages()
  {
    centerRepository.setInitCarStateVMMap(carCount);
    _currentCarId=centerRepository.getCarIdByIndex(0);
    CenterRepository.setCurrentCarId(_currentCarId);
    /*CarPageHolder.startEnginChangedNoty=startEnginChangedNoty;
    CarPageHolder.carLockPanelNoty=carLockPanelNoty;
    CarPageHolder.carPageChangedNoty=carPageChangedNoty;
    CarPageHolder.statusChangedNoty=statusChangedNoty;
    CarPageHolder.sendCommandNoty=sendCommandNoty;
    CarPageHolder.valueNotyModelBloc=valueNotyModelBloc;
    CarPageHolder.currentCarIndex=0;*/
    final List<Container> pages=[];
      for(int i=0;i<carCount;i++)
        pages..add(createHomeCarPage(createHomeScrollList(startImagePath,i,true),i));



   return pages;
  }

 Container createSingleCarPage()
 {
   centerRepository.addInitCarStateVMMap(carCount);
   Container newPage=createHomeCarPage(createHomeScrollList(startImagePath,carCount,true), carCount);
    carCount++;
    return newPage;
 }

 Future<List<AdminCarModel>> refreshCars() async
  {
    RestDatasource restDatasource=new RestDatasource();
    List<AdminCarModel> cars=await restDatasource.getAllCarsByUserId(userId);
    if(cars!=null &&
    cars.length>0)
      {
        centerRepository.setCarsToAdmin(cars);
        newCarsList=cars;
        int actionId=ActionsCommand.actionCommandsMap[ActionsCommand.STATUS_CAR_TAG];
      var result= await restDatasource.sendCommand(new SendCommandModel(UserId: userId,
            ActionId: actionId, CarId: _currentCarId, Command: null));
      if(result!=null){

      }
        return cars;
      }
    return null;
  }

 void initLists()
  {
   isAdmin=true;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _screenController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    _buttonController = new AnimationController(
        duration: new Duration(milliseconds: 1500), vsync: this);

    fadeScreenAnimation = new ColorTween(
      begin: const Color.fromRGBO(247, 64, 106, 1.0),
      end: const Color.fromRGBO(247, 64, 106, 0.0),
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: Curves.ease,
      ),
    );
    containerGrowAnimation = new CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeIn,
    );

    buttonGrowAnimation = new CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeOut,
    );
    containerGrowAnimation.addListener(() {
      this.setState(() {});
    });
    containerGrowAnimation.addStatusListener((AnimationStatus status) {});

    listTileWidth = new Tween<double>(
      begin: 1000.0,
      end: 600.0,
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: new Interval(
          0.225,
          0.600,
          curve: Curves.bounceIn,
        ),
      ),
    );

    listSlideAnimation = new AlignmentTween(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: new Interval(
          0.325,
          0.700,
          curve: Curves.ease,
        ),
      ),
    );
    buttonSwingAnimation = new AlignmentTween(
      begin: Alignment.topCenter,
      end: Alignment.bottomRight,
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: new Interval(
          0.225,
          0.600,
          curve: Curves.ease,
        ),
      ),
    );
    listSlidePosition = new EdgeInsetsTween(
      begin: const EdgeInsets.only(bottom: 16.0),
      end: const EdgeInsets.only(bottom: 80.0),
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: new Interval(
          0.325,
          0.800,
          curve: Curves.ease,
        ),
      ),
    );
    _screenController.forward();


 //createMenuContent(context);
}

initCustomer() async
{
   user=await databaseHelper.getUserInfo();

  if(user!=null)
  {

    isLoginned=true;
    if(user.owner<=0) {

      isAdmin = true;
    }
    else
      {
        isAdmin=false;
      }
    setState(() {

    });
  }
  else{
    isLoginned=false;
    isAdmin=false;

  }

}


  _showBottomSheetAccessableActions(BuildContext cntext,AccessableActionVM vm)
  {
     showModalBottomSheetCustom(context: cntext ,
        builder: (BuildContext context) {
          return new UserAccessPage(
            accessableActionVM: vm,
          );
        });
  }

  void _showCarControl() {
    showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return new BS();
    });
  }


  _showMenu(String message)
  {
    return SolidBottomSheet(
      controller: _solidBottomSheetController,
      draggableBody: true,
      maxHeight: 50.0,
      smoothness: Smoothness.high,
      canUserSwipe: true,
      autoSwiped: true,
      showOnAppear: true,
      headerBar: Container(
        color: Theme.of(context).primaryColor,
        height: 20,
        child: Center(
          child: Text("close me"),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // _controller.isOpened ? _controller.hide() : _controller.show();
        },
        child:
        Container(
          color: Colors.white,
          height: 30,
          child: Center(
            child: Text(
              message,
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ),
      ),
    );

  }

void registerBus() {
    RxBus.register<ChangeEvent>().listen((ChangeEvent event)  {

      if(event.type=='CAR_ADDED')
      {
        _handleRefresh();
        getCarCounts();
      }
         if(event.message=='USER_LOADED')
         {

         }
         if(event.message=='USER_LOADED_ERROR')
         {

         }
         if(event.message=='MAP_PAGE')
         {
           // Navigator.of(context).pushReplacementNamed('/map');
         }
         if(event.type=='LOGIN_FAIED') {
             bottomSheetMessage=event.message;
             if(_solidBottomSheetController.isOpened)
               _solidBottomSheetController.hide();
             _solidBottomSheetController.show();
           }

         if(event.type=='FCM_STATUS') {
           String msg=event.message;
           int carId=event.id;
           String commandCode=msg.substring(0,2);
           if(commandCode!=ActionsCommand.Check_Status_Car) {
             /*sendCommandNoty.updateValue(
                 new SendingCommandVM(sending: false,
                     sent: true, hasError: false));*/
             RxBus.post(new ChangeEvent(type: 'COMMAND_SUCCESS',id: int.tryParse(commandCode)));
           }
           String newFCM=msg.substring(2,msg.length);
           Uint8List fcmBody=base64Decode(newFCM);//.toString();

           NotiAnalyze notiAnalyze=new NotiAnalyze(noti: null, carId: carId,data: fcmBody);
           StatusNotiVM status= notiAnalyze.analyzeStatusNoti();
           if(status!=null){
                CarStateVM carStateVMForThisCarId=centerRepository.getCarStateVMByCarId(carId);
                if(carStateVMForThisCarId!=null){
                  carStateVMForThisCarId.fillStatusNotiData(status,statusChangedNoty);
                }
           }
         }
         else if(event.type=='FCM') {
                FlashHelper.successBar(context, message: event.message);
              int carId=NotiAnalyze.getCarIdFromNoty(event.message);
              CarStateVM carStateVM=centerRepository.getCarStateVMByCarId(carId);
              if(carStateVM!=null)
                carStateVM.fillNotiData(event.message,carId);
           }

    });
  }


  void _showTopFlash(String title,String message, {FlashStyle style = FlashStyle.floating}) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 2),
      persistent: false,
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

  @override
  void initState() {

    getAppTheme();

    centerRepository.initCarColorsMap();
    getEngineStatus();
    getLockStatus();
    centerRepository.initCarMinMaxSpeed();
    getCarCounts();
    getUserName();
    registerBus();
    loadLoginedUserInfo(userId);
    isAdmin=true;
    isLoginned=true;
    initLists();

    opacityNotifier=new OpacityNotifier(1.0);
    startEnginChangedNoty=new NotyBloc<Message>();
    carPageChangedNoty=new NotyBloc<Message>();
    carLockPanelNoty=new NotyBloc<Message>();
    messageCountNoty=new NotyBloc<Message>();
    //statusChangedNoty=new NotyBloc<CarStateVM>();
    sendCommandNoty=new NotyBloc<SendingCommandVM>();
    valueNotyModelBloc=new NotyBloc<ChangeEvent>();
    _solidBottomSheetController=new SolidController();
    player = AudioCache();
    advancedPlayer=new AudioPlayer();

    rotationController = AnimationController(duration: const Duration(milliseconds: 7000), vsync: this);
    rotationController.addListener(() {

    });


    progressIndicatorBackgroundColor=Colors.indigoAccent;

    animController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
   // animController.repeat(reverse: true);
    animProgressController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    animProgressController.addListener((){
      setState(() {
        if(commandProgressValue>3)
          {
            animProgressController.reverse();
          }
        if(commandProgressValue<0)
          {
            animProgressController.forward();
          }
        if(commandProgressValue<3) {
          commandProgressValue++;
        }
        else if(commandProgressValue>0) {
          commandProgressValue--;
        }
      });
    });

    centerRepository.checkCarStatusPeriodic(5);
    centerRepository.checkParkGPSStatusPeriodic(6);

    super.initState();
    messageCountNoty.updateValue(new Message(index:CenterRepository.messageCounts));

  }

  @override
  void dispose() {
    _screenController.dispose();
    _buttonController.dispose();
    carLockPanelNoty.dispose();
    carPageChangedNoty.dispose();

    RxBus.destroy();
    super.dispose();
  }



 Future<bool> _onWillPop(BuildContext ctx) {
    return showDialog(
      context: ctx,
      child: new AlertDialog(
        title: new Text(Translations.current.areYouSureToExit()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: new Text(Translations.current.no()),
          ),
          new FlatButton(
            onPressed: () =>
                SystemNavigator.pop(),
            child: new Text(Translations.current.yes()),
          ),
        ],
      ),
    ) ??
        false;
  }
  final _random = math.Random();

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.3;
    Size screenSize = MediaQuery
        .of(context)
        .size;

    // return  BlocProvider<CartBloc>(
    //   builder: (context) => _cartBloc ,
    //   child:
    _panelHeightOpen=MediaQuery.of(context).size.height*0.40;
        return
          new WillPopScope(
        onWillPop: () async {
         return _onWillPop(context);
        },
            child: OfflineBuilder(
            connectivityBuilder: (
            BuildContext context,
            ConnectivityResult connectivity,
            Widget child,
          ) {
              hasInternet = connectivity != ConnectivityResult.none;
              if (connectivity == ConnectivityResult.none) {

              }
                return child;
            },
      child:
    Scaffold(
      key: _scaffoldKey,
       appBar: null,
       drawer: AppDrawer(
         userName: userName,
       currentRoute: route,
       imageUrl: imageUrl,
       carPageTap: onCarPageTap,
       carId: _currentCarId,),
    body:  Stack(
      alignment: Alignment.topCenter,
      overflow: Overflow.visible,
      children: <Widget>[
    StreamBuilder<Message>(
      stream: carPageChangedNoty.noty,
      initialData: null,
      builder: (BuildContext c, AsyncSnapshot<Message> data) {
        if (data != null && data.hasData) {
          Message msg = data.data;
          if (msg.type == 'CARPAGE') {
            currentCarIndex=msg.index;
            _currentCarId=centerRepository.getCarIdByIndex(currentCarIndex);
            CenterRepository.setCurrentCarId(_currentCarId);
          }
          if(msg.type=='LOCK_PANEL')
          {

          }
        }
        return
          StreamBuilder<SendingCommandVM>(
              stream: sendCommandNoty.noty,
              initialData: null,
              builder: (BuildContext c, AsyncSnapshot<SendingCommandVM> data)
              {
                if(data.hasData && data.data!=null)
                {
                  SendingCommandVM sendVM=data.data;
                  sendingCommand=sendVM.sending;
                  sentCommand=sendVM.sent;
                  sentCommandHasError=sendVM.hasError;
                  animProgressController.forward();
                }
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
                        padding: EdgeInsets.only(right: 110.0,top: 30.0),
                        child:
                        Align(
                          alignment: Alignment(1,-1),
                          child:
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, MessageAppPageState.route,arguments: _currentCarId);
                            },
                            child: StreamBuilder(
              stream: messageCountNoty.noty,
              initialData: null,
              builder: (BuildContext c, AsyncSnapshot<Message> snapshot)
              {
                if(snapshot.hasData && snapshot.data!=null) {
                  messageCounts=snapshot.data.index;
                }else
                  {
                    messageCounts=CenterRepository.messageCounts;
                  }
              return new Container(
                width: 58.0,
                height: 58.0,
                child:
                Stack(
                  children: <Widget>[
                    Positioned(
                      top:0.0,
                      left:16,
                      child:
                      Padding(
                        padding: EdgeInsets.only(
                            left: 18.0,
                            bottom: 10.0,
                            right: 0.0,
                            top: 0.0
                        ),
                        child: CircleBadge(number: messageCounts.toString(),),
                      ),),
                    Positioned(
                      top:5.0,
                      left:12,
                      child:
                      Container(
                        width: 28.0,
                        height: 28.0,
                        child:
                        new Image.asset('assets/images/message.png',color: Colors.blueAccent,),), ) ,],) ,);},),), ),),
                      Padding(
                        padding: EdgeInsets.only(right: 60.0,top: 30.0),
                        child:
                        Align(
                          alignment: Alignment(1,-1),
                          child:
                          GestureDetector(
                            onTap: () {
                              // getAdminCarsToUser();
                              AccessableActionVM accessableActionVM=new AccessableActionVM(
                                  userModel: new ApiRelatedUserModel(userId: userId,
                                      userName: null, roleTitle: null, roleId: null),
                                  carId: _currentCarId,
                                  carStateVM: null,
                                  sendingCommandVM: null,
                                  sendCommandModel: null,
                                  isFromMainAppForCommand: true,
                              carStateNoty: statusChangedNoty,
                              sendingCommandNoty: sendCommandNoty);
                              _showBottomSheetAccessableActions(context, accessableActionVM);
                              //Navigator.of(context).pushNamed('/showuser',arguments: accessableActionVM);
                            },
                            child: new Container(width: 24.0,height: 24.0,
                              child:
                              Image.asset('assets/images/car_waiting.png',color: Colors.indigoAccent,),
                            ),),), ),
                      sendingCommand ?

                      Align(
                        alignment: Alignment(1,-1),
                        child:
                        new Column(
                          children: <Widget>[
                            LinearProgressIndicator(
                              value: progressIndicatorController != null
                                  ? _progressAnimation.value
                                  : null,
                              backgroundColor: progressIndicatorBackgroundColor,
                              valueColor: progressIndicatorValueColor,
                            ),
                            new Text(Translations.current.sendingCommand(),
                              style: TextStyle(color: Colors.redAccent,fontSize:10.0),)
                          ],
                        ),) :
                      sentCommand ?
                      Align(
                        alignment: Alignment(1,-1),
                        child:
                        new Column(
                          children: <Widget>[
              LinearProgressIndicator(
              value: progressIndicatorController != null
              ? _progressAnimation.value
                  : null,
              backgroundColor: progressIndicatorBackgroundColor,
              valueColor: progressIndicatorValueColor,
              ),
                            //  new Text(Translations.current.sentCommand(),style: TextStyle(color: Colors.redAccent,fontSize:10.0))
                          ],
                        ) ,) :
                      sentCommandHasError ?
                      Align(
                        alignment: Alignment(1,-1),
                        child:
                        new Column(

                          children: <Widget>[
                            LinearProgressIndicator(
                              value: progressIndicatorController != null
                                  ? _progressAnimation.value
                                  : null,
                              backgroundColor: progressIndicatorBackgroundColor,
                              valueColor: progressIndicatorValueColor,
                            ),
                            Icon(Icons.error_outline,size: 20.0,color:Colors.red),
                            //new Text(Translations.current.sentCommandHasError(),style: TextStyle(color: Colors.redAccent,fontSize:10.0))
                          ],
                        ) ,) :
                      new Container(width: 0,height: 0,),

                      (sendingCommand ||
                          sentCommand ||
                          sentCommandHasError)  ?
                      Container(width: 0.0,height: 0.0,) :
                      new Positioned(
                        child:Padding(
              padding: EdgeInsets.only(right: 80.0,top: 20.0),
              child:
                        Container(
                          width:MediaQuery.of(context).size.width * 0.45,
                          child: new Image.asset(
                            'assets/images/i26.png', color: Colors.indigoAccent,scale: 1,),

                          alignment: Alignment(-10,0.5),),),
                        left:-1.0,),
                      hasInternet ? new Container(width: 0.0,height: 0.0,) :
                      Align(
                        alignment: Alignment(1,0),
                        child:   new Container(width: 48.0,height: 48.0,
                          child:
                          Image.asset('assets/images/no_internet.png'),),),

             /* StreamBuilder(
              initialData: Message(text: startImagePath,type: '',status: false),
              stream:  BlocProvider.of<GlobalBloc>(context).messageBloc.messageStream,
              builder: (context, snapshot) {
              if (snapshot != null &&
              snapshot.hasData) {
              Message message = snapshot.data;
              if (message != null) {
              if (message.type == 'LOCK') {
              if (currentCarState != null) {
              currentCarState.isDoorOpen = !message.status;
              currentCarState.setCarStatusImages();
              centerRepository.setCarStateVMMap(currentCarState);
              }
              setLockStatus(message.status);
              lockStatus = message.status;
              if (!lockStatus) {
              _counter = 1;
              rotationController.forward();
              }
              else {
              _counter = 0;
              rotationController.reverse();
              //_assetsAudioPlayer.stop();
              // player.clear('car_door_lock.mp3');

              }
              } else if (message.type == 'POWER') {
              setEngineStatus(message.status);
              engineStatus = message.status;
              startImagePath = message.text;
              }
              else if (message.type == 'TRUNK') {
              if (currentCarState != null) {
              currentCarState.isTraunkOpen = message.status;
              currentCarState.setCarStatusImages();
              centerRepository.setCarStateVMMap(currentCarState);
              }
              //rotationController.forward();
              trunkStatus = message.status;
              if (trunkStatus) {
              _counter = 1;
              // rotationController.forward();
              }
              else {
              _counter = 0;
              // rotationController.reverse();
              }
              }
              else if (message.type == 'CAPUT') {
              if (currentCarState != null) {
              currentCarState.isCaputOpen = message.status;
              currentCarState.setCarStatusImages();
              centerRepository.setCarStateVMMap(currentCarState);
              }
              // rotationController.forward();
              caputStatus = message.status;
              if (caputStatus) {
              _counter = 1;
              // rotationController.forward();
              }
              else {
              _counter = 0;
              rotationController.reverse();
              }
              }
              else if (message.type == 'CARPAGE') {
              currentCarIndex = message.index;

              }
              }
              }

              else {

              }


              return*/

             // } ),
                    ],
                 // ),
                  );
              }
          );
      },
    ),
      Padding(
        padding: EdgeInsets.only(right: 0.0,top: 80.0),
        child:
        Container(
          height: MediaQuery.of(context).size.height*0.80,
          child:
          SmartRefresher(

            controller: _refreshController,
            enablePullUp: true,
            enablePullDown: true,
            physics: BouncingScrollPhysics(),
            footer: MaterialClassicHeader(
              color: Theme.of(context).indicatorColor,
              height: 10.0,
              backgroundColor: Theme.of(context).backgroundColor,
              //loadStyle: LoadStyle.ShowWhenLoading,
              //completeDuration: Duration(milliseconds: 500),
            ),
            header: WaterDropMaterialHeader(),
            onRefresh: () async {
              //monitor fetch data from network
              await Future.delayed(Duration(milliseconds: 1000));

              var result=   await refreshCars();
              if (mounted) setState(() {});
              if(result==null)
                _refreshController.refreshFailed();
              else
                _refreshController.refreshCompleted();

            },
            onLoading:() async {
              //monitor fetch data from network
              await Future.delayed(Duration(milliseconds: 1000));
              var result= await refreshCars();
              if (mounted) setState(() {});
              if(result==null)
                _refreshController.loadFailed();
              else
                _refreshController.loadComplete();
            },
            child:

            ListView.builder(
              padding: EdgeInsets.only(top:1.0), //kMaterialListPadding,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index)
              {
                return
                  AppBarCollaps(
                      _controller,
                      clr,
                      createCarPages() /*createHomeScrollList(startImagePath,0)*/,
                      engineStatus,
                      lockStatus,
                      carPageChangedNoty,
                      _currentColor,
                      currentCarIndex,
                      carCount);
              },
            ),
          ),
          // },
        ),
      ),
          ],
    ),

          bottomNavigationBar: CurvedNavigationBar(
            index: 2,
            height: 60.0,
          color: centerRepository.getBackNavThemeColor(!isDark),
          backgroundColor: centerRepository.getBackNavThemeColor(isDark),//Colors.blueAccent[400],
          items: <Widget>[
            Icon(Icons.build, size: 30,color: Colors.indigoAccent),
            Icon(Icons.pin_drop, size: 30,color: Colors.indigoAccent),
            Icon(Icons.directions_car , size: 30,color:  Colors.indigoAccent),
            Icon(Icons.message, size: 30,color: Colors.indigoAccent),
            Icon(Icons.payment, size: 30,color: Colors.indigoAccent,),
          ],
          onTap: (index) {
            //Handle button tap
            onNavButtonTap(index);
          },
        ),

            ),
            ),
        );
  }

 Widget addSettingsIcon()
  {
    return
    isAdmin ?
        Align(
          alignment: Alignment.centerRight,
          child:
    Padding(
      padding: EdgeInsets.only(left: 10.0),
      child:

      IconButton(
        onPressed: () {
          Navigator.pushNamed(context, '/settings',arguments: true);
        },
        icon:
        //Icon(Icons.shopping_cart, color: Colors.white, size: 32,semanticLabel: "Cart",),
        new Stack(
          children: <Widget>[
            new Icon(Icons.settings, color: Colors.white, size: 24,semanticLabel: "Settings",),
          ],
        ),),
      // },)
    ), ) : new Text('') ;
  }

  loaduser() async {
    return await databaseHelper.getUserInfo() ;
  }

  void onNavButtonTap(int index) {
  currentBottomNaviSelected=index;
    if (index == 4) {
     Navigator.of(context).pushNamed('/plans');
    }
    else if(index==0)
    {
      Car car=centerRepository.getCarByCarId(_currentCarId);
      Navigator.pushNamed(context, '/servicepage',arguments: new ServiceVM( car: car,
          carId: _currentCarId, editMode: null, service: null, refresh: false) );
    }
    else if(index==1)
    {
      Navigator.of(context).pushNamed(
          '/mappage',arguments: new MapVM(
        carId: _currentCarId,
        carCounts: centerRepository.getCarsToAdmin().length,
        cars: centerRepository.getCarsToAdmin(),
      ));

    }
    else if(index==2)
    {
       Navigator.pushReplacementNamed(context, '/home');
     // _showCarControl();
    }
    else if(index==3)
    {
      Navigator.pushNamed(context, '/messages',arguments: _currentCarId);
    }
  }

  List<Widget> getCarsTiles() {
    List<Widget> list = [];
    if (centerRepository.getCars() != null) {
      for (Car c in centerRepository.getCars()) {

        String name = c.pelaueNumber ;
        String desc=c.description;
        list.add( ListTile(
          title: Text(name),
          subtitle: Text( ' # '+ Translations.current.carpelak()+' : '+ name),
          trailing: FlatButton(
            padding: EdgeInsets.only(left: 0, right: 0),
            child: Icon(Icons.directions_car,size: 28.0, color: Colors.red),
            onPressed: () {

            },
          ),
        ));
      }
    }
    return list;
  }

  Future<void> _handleRefresh() async {
    final Completer<void> completer = Completer<void>();
    List<AdminCarModel> carsToAdmin = new List();
    carsToAdmin = await restDatasource.getAllCarsByUserId(userId);
    if (carsToAdmin != null) {
      centerRepository.setCarsToAdmin(carsToAdmin);
      prefRepository.setCarsCount(carsToAdmin.length);
    }
    else {
      prefRepository.setCarsCount(0);
    }
    Timer(const Duration(seconds: 3), () {
      completer.complete();
    });
    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: const Text('اطلاعات بروزرسانی شد'),
          action: SnackBarAction(
              label: 'سعی مجدد',
              onPressed: () {
                //_refreshIndicatorKey.currentState.show();
              })));
    });
  }

  void createMenuContent(BuildContext context)
  {
    CarStateVM carStateVM;
    itens.add(new ScreenHiddenDrawer(
      new ItemHiddenMenu(
        name: DartHelper.isNullOrEmptyString( centerRepository.getUserInfo()!=null ?
        centerRepository.getUserInfo().UserName : userName),
        colorLineSelected: Colors.teal,
        baseStyle: TextStyle( color:  Colors.black.withOpacity(0.8), fontSize: 25.0 ),
        selectedStyle: TextStyle(color: Colors.teal),
        content: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16,left: 5.0),
              child:new CircleImage(imageUrl: imageUrl,isLocal: true,width: 48.0,height: 48.0,)/*CircleAvatar(
                backgroundImage: new Image(image: imageUrl)
                 radius: 50.0,
                child : Image.asset(imageUrl),)*/,
            ),
            Text(DartHelper.isNullOrEmptyString( centerRepository.getUserInfo()!=null ?
            centerRepository.getUserInfo().UserName : userName),
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ),
      StreamBuilder(
       initialData: Message(text: startImagePath,type: '',status: false),
          stream:  BlocProvider.of<GlobalBloc>(context).messageBloc.messageStream,
          builder: (context, snapshot) {
            if (snapshot != null &&
                snapshot.hasData) {
              Message message = snapshot.data;
              if (message != null) {
                if (message.type == 'LOCK') {
                  if (currentCarState != null) {
                    currentCarState.isDoorOpen = !message.status;
                    currentCarState.setCarStatusImages();
                    centerRepository.updateCarStateVMMap(currentCarState);
                  }
                  setLockStatus(message.status);
                  lockStatus = message.status;
                  if (!lockStatus) {
                    _counter = 1;
                    rotationController.forward();
                  }
                  else {
                    _counter = 0;
                    rotationController.reverse();
                    //_assetsAudioPlayer.stop();
                    // player.clear('car_door_lock.mp3');

                  }
                } else if (message.type == 'POWER') {
                  setEngineStatus(message.status);
                  engineStatus = message.status;
                  startImagePath = message.text;
                }
                else if (message.type == 'TRUNK') {
                  if (currentCarState != null) {
                    currentCarState.isTraunkOpen = message.status;
                    currentCarState.setCarStatusImages();
                    centerRepository.updateCarStateVMMap(currentCarState);
                  }
                  //rotationController.forward();
                  trunkStatus = message.status;
                  if (trunkStatus) {
                    _counter = 1;
                    // rotationController.forward();
                  }
                  else {
                    _counter = 0;
                    // rotationController.reverse();
                  }
                }
                else if (message.type == 'CAPUT') {
                  if (currentCarState != null) {
                    currentCarState.isCaputOpen = message.status;
                    currentCarState.setCarStatusImages();
                    centerRepository.updateCarStateVMMap(currentCarState);
                  }
                  // rotationController.forward();
                  caputStatus = message.status;
                  if (caputStatus) {
                    _counter = 1;
                    // rotationController.forward();
                  }
                  else {
                    _counter = 0;
                    rotationController.reverse();
                  }
                }
                else if (message.type == 'CARPAGE') {
                  currentCarIndex = message.index;

                }
              }
            }

            else {

            }



                    return
                      Container(
                        height: MediaQuery.of(context).size.height-60.0,
                        child:
                      SmartRefresher(
                controller: _refreshController,
                enablePullUp: true,
                enablePullDown: true,
                physics: BouncingScrollPhysics(),
                footer: MaterialClassicHeader(
                  color: Theme.of(context).indicatorColor,
                height: 20.0,
                backgroundColor: Theme.of(context).backgroundColor,
                //loadStyle: LoadStyle.ShowWhenLoading,
                //completeDuration: Duration(milliseconds: 500),
            ),
            header: WaterDropMaterialHeader(),
            onRefresh: () async {
              //monitor fetch data from network
              await Future.delayed(Duration(milliseconds: 1000));

            var result=   await refreshCars();
              if (mounted) setState(() {});
              if(result==null)
                _refreshController.refreshFailed();
              else
                _refreshController.refreshCompleted();

      },
            onLoading:() async {
                  //monitor fetch data from network
              await Future.delayed(Duration(milliseconds: 1000));
               var result= await refreshCars();
            if (mounted) setState(() {});
              if(result==null)
                  _refreshController.loadFailed();
              else
                _refreshController.loadComplete();
            },
            child:

              ListView.builder(
                  padding: kMaterialListPadding,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index)
                  {

                  return
            AppBarCollaps(
                        _controller,
                        clr,
                        createCarPages() /*createHomeScrollList(startImagePath,0)*/,
                        engineStatus,
                        lockStatus,
                        carPageChangedNoty,
                        _currentColor,
                        currentCarIndex,
                        carCount);
                  },
                ),
            ),
             // },
            );
          } ),));

    itens.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: Translations.of(context).register(),
          colorLineSelected: Colors.orange,
          baseStyle: TextStyle( /*color: Colors.black.withOpacity(0.8),*/ fontSize: 25.0 ),
          selectedStyle: TextStyle(color: Colors.orange),
          content:
          ListTile(
            onTap: (){ centerRepository.goToPage(context, '/showusers');},
            leading: Icon(Icons.person_add, color: Theme.of(context).iconTheme.color, size: 20,),
            title: Text(Translations.of(context).users(),
                style: TextStyle(
                    fontSize: 14,
                   // color: isLoginned ? Colors.blueAccent : Colors.black,
                    fontWeight: FontWeight.bold
                )),),
        ),
        /*isLoginned ? new LogoutDialog() : */ new RegisterScreen()
        ));

    itens.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: Translations.of(context).car(),
          colorLineSelected: Colors.orange,
          baseStyle: TextStyle( /*color: Colors.black.withOpacity(0.8),*/ fontSize: 25.0 ),
          selectedStyle: TextStyle(color: Colors.orange),
          content:
          Container(
            margin: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
               color: Colors.pinkAccent.withOpacity(0.2),
            ),
            child:
          ListTile(
            onTap: (){ Navigator.of(context).pushNamed('/carpage',arguments: new CarPageVM(
                userId: userId,
                isSelf: true,
                carAddNoty: valueNotyModelBloc));},
            leading: Icon(Icons.directions_car, color: Theme.of(context).iconTheme.color, size: 20,),
            title:new Text(Translations.of(context).car(),
                style: TextStyle(
                    fontSize: 14,
                    //color: Colors.black,
                    fontWeight: FontWeight.bold
                )),
            subtitle: new Text(Translations.current.cars()  + " ",
                style:
                Theme.of(context).textTheme.headline) ,
          ),
          ),
        ),

      new CarPage(
          carPageVM : new CarPageVM(
          userId: userId,
          isSelf: true,
          carAddNoty: valueNotyModelBloc)),
        ));
    itens.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: Translations.of(context).security(),
          colorLineSelected: Colors.orange,
          baseStyle: TextStyle( /*color: Colors.black.withOpacity(0.8),*/ fontSize: 25.0 ),
          selectedStyle: TextStyle(color: Colors.orange),
          content: ListTile(
            leading: Icon(Icons.security, color: Theme.of(context).iconTheme.color, size: 20,),
            title: Text(Translations.of(context).security(),
                style: TextStyle(
                    fontSize: 14,
                   // color: Colors.black,
                    fontWeight: FontWeight.bold
                )),),
        ),
       new SecuritySettingsScreen(),
        ));

    itens.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: !isLoginned ? Translations.of(context).settings() :  Translations.of(context).exit(),
          colorLineSelected: Colors.orange,
          baseStyle: TextStyle( color: Theme.of(context).textTheme.headline.color, fontSize: 25.0 ),
          selectedStyle: TextStyle(color: Colors.orange),
          content: ListTile(
            leading: Icon(Icons.settings, color: Theme.of(context).iconTheme.color, size: 20,),
            title: Text(Translations.of(context).settings() ,)),
        ),
      Container(
          color: Colors.orange,
          child: Center(
            child:new SettingsScreen() ,
          ),
        )
        ));

     itens.add(new ScreenHiddenDrawer(
         new ItemHiddenMenu(
           name: Translations.of(context).profile(),
           colorLineSelected: Colors.orange,
           baseStyle: TextStyle( color: Colors.black.withOpacity(0.8), fontSize: 25.0 ),
           selectedStyle: TextStyle(color: Colors.orange),
           content: ListTile(
             leading: Icon(Icons.person_pin, color: Theme.of(context).iconTheme.color, size: 20,),
             title: Text(Translations.of(context).profile(),
                 style: TextStyle(
                     fontSize: 14,
                     //color: Colors.black,
                     fontWeight: FontWeight.bold
                 )),),
         ),
       isLoginned ?  new ProfileTwoPage(user: centerRepository.getUserInfo()) : new LoginTwoPage(),
     ));


    itens.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: Translations.of(context).support(),
          colorLineSelected: Colors.orange,
          baseStyle: TextStyle( color: Colors.black.withOpacity(0.8), fontSize: 20.0 ),
          selectedStyle: TextStyle(color: Colors.orange),
          content: ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.black, size: 20,),
            title: Text(Translations.of(context).exit(),
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                )),),
        ),
      isLoginned ?  new LogoutDialog() : new LoginTwoPage(),
    ));
  }
  List<MenuItem> createMenuList(BuildContext context){
    final List<MenuItem> options = [
      MenuItem(Icons.person_add, Translations.of(context).register(),context,registerId),
      MenuItem(Icons.search, Translations.of(context).search(),context,searchId),
      MenuItem(Icons.shopping_basket, Translations.of(context).basket(),context,basketId),
     // MenuItem(Icons.transfer_within_a_station, Translations.of(context).coach(),context,-1),
      //MenuItem(Icons.list, Translations.of(context).myPrograms(),context,myProgramsId),
      MenuItem(Icons.help, Translations.of(context).help(),context,helpId),

    ];
    return options;
  }
 /* _modalBottomSheet(Customer user){
      return showModalBottomSheet(
        context: context,
        builder: (builder){
  return LogoutDialog(user: user);
    }
      );
  }*/

  @override
  void afterFirstLayout(BuildContext context) {
    // TODO: implement afterFirstLayout
    createMenuContent(context);
  }

}

class MenuItem{
  int id;
  String title;
  IconData icon;
  BuildContext context;
  MenuItem(this.icon, this.title,this.context,this.id);

}

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: Colors.cyan,
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                SimpleHiddenDrawerProvider.of(context)
                    .setSelectedMenuPosition(0);
              },
              child: Text("Menu 1"),
            ),
            RaisedButton(
                onPressed: () {
                  SimpleHiddenDrawerProvider.of(context)
                      .setSelectedMenuPosition(1);
                },
                child: Text("Menu 2"))
          ],
        ),
      ),
    );
  }
}

//NotyBloc<Message> startEnginChangedNoty=new NotyBloc<Message>();
NotyBloc<CarStateVM> statusChangedNoty=new NotyBloc<CarStateVM>();
/*NotyBloc<Message> carPageChangedNoty=new NotyBloc<Message>();
NotyBloc<Message> carLockPanelNoty=new NotyBloc<Message>();
NotyBloc<SendingCommandVM> sendCommandNoty=new NotyBloc<SendingCommandVM>();*/
NotyBloc<ChangeEvent> valueNotyModelBloc=new NotyBloc<ChangeEvent>();

