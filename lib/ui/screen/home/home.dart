import 'dart:ui';

import 'package:anad_magicar/bloc/basic/global_bloc.dart';
import 'package:anad_magicar/bloc/values/notify_value.dart';
import 'package:anad_magicar/components/CircleImage.dart';
import 'package:anad_magicar/components/bounce_animation.dart';
import 'package:anad_magicar/components/image_neon_glow.dart';
import 'package:anad_magicar/components/shimmer/myshimmer.dart';
import 'package:anad_magicar/components/switch_button.dart';
import 'package:anad_magicar/data/rxbus.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/model/message.dart';
import 'package:anad_magicar/model/viewmodel/car_state.dart';
import 'package:anad_magicar/model/viewmodel/map_vm.dart';
import 'package:anad_magicar/notifiers/opacity.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/listener/listener_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/utils/dart_helper.dart';
import 'package:anad_magicar/utils/marquee_widget.dart';
import 'package:anad_magicar/widgets/slider/carousel_slider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anad_magicar/bloc/basic/bloc_provider.dart'  as bp;
import 'package:provider/provider.dart';
//car images list
/*final List<String> imgList = [
  "assets/images/car_red.png",
  "assets/images/car_blue.png",
  "assets/images/car_black.png",
  "assets/images/car_white.png",
  "assets/images/car_yellow.png",
  "assets/images/car_green.png",

];*/

/*final List<String> carRedStatusList = [
  "assets/images/car_red_door.png",
  "assets/images/car_red_opendoor.png",
  "assets/images/car_red_trunk.png",
  "assets/images/car_red_caput.png"
];*/

final List<String> carNumbers= [
  "assets/images/one.png",
  "assets/images/two.png",
  "assets/images/three.png",
  "assets/images/four.png",
  "assets/images/four.png",
  "assets/images/four.png",

];

List<Color> colors=[
  Colors.redAccent,
  Colors.blueAccent,
  Colors.pinkAccent,
  Colors.purpleAccent,
  Colors.yellowAccent,
  Colors.greenAccent,
];

enum MaterialColor {RED,BLUE,GREEN,YELLOW,BLACK,WHITE}

enum CarStatus { ONLYDOOROPEN, ONLYTRUNKOPEN, BOTHOPEN, BOTHCLOSED}

var _currentColor=Colors.redAccent;
var carStatus=CarStatus.BOTHCLOSED;
bool lock_status=true;
bool shock_status=false;
bool power_status=false;
bool trunk_status=false;
bool isPark=true;
bool isGPSOn=true;
bool isHighSpeed=false;
/*final CarouselSlider touchDetectionDemo = CarouselSlider(
  viewportFraction: 1,
  aspectRatio: 2.0,
  autoPlay: true,
  enlargeCenterPage: false,
  pauseAutoPlayOnTouch: Duration(seconds: 3),
  items: imgList.map(
        (url) {
      return Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: 1000.0,
          ),
        ),
      );
    },
  ).toList(),
);*/


Widget buildControlRow(BuildContext context,
    String startImgPath,
    NotyBloc<Message> noty,
    bool engineStatus,
    bool lockStatus,)  {


  return
    Stack(
      alignment: new Alignment(0, 0),
      overflow: Overflow.visible,
      children: <Widget>[
    new Padding(padding: EdgeInsets.only(top: 4.0) ,
      child:
         Container(

    width: MediaQuery.of(context).size.width-1,
      height: 180.0,
      child:

  new Card(
   margin: new EdgeInsets.only(
  left: 22.0, right: 22.0, top: 5.0, bottom: 5.0),
  shape: RoundedRectangleBorder(
    side: BorderSide(color: Colors.white,width: 100.5),
  borderRadius: new BorderRadius.all(Radius.elliptical(100, 50)),
  ),
  elevation: 0.0,
  child: Text(''),
  ),
    ),
    ),
        new Positioned(
  left: 1.0,
  top: 1.0,
  child:
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[


  Align(
  alignment: Alignment.topLeft,
  child:
      new Container(
        margin: EdgeInsets.only(left: 15.0,top: 10.0),
        //width: 64.0,
  child:
      new GestureDetector(
          onTap: () {
            listenerRepository.onLockTap(context, false);
          } ,
          child:
          AvatarGlow(
            startDelay: Duration(milliseconds: 1000),
            glowColor: Colors.blue,
            endRadius: 40.0,
            duration: Duration(milliseconds: 2000),
            repeat: true,
            showTwoGlows: true,
            repeatPauseDuration: Duration(milliseconds: 100),
            child: Material(
              elevation: 0.0,
              shape: CircleBorder(),
              child: CircleAvatar(
                  backgroundColor:Colors.black12, //Colors.grey[100] ,
                  child: Image.asset('assets/images/unlock_2.png',scale: 1.0,),
                  radius: 24.0,
                  //shape: BoxShape.circle
              ),
            ),
            shape: BoxShape.circle,
            animate: !lockStatus,
            curve: Curves.fastOutSlowIn,
          ),
  /*new Container(
  decoration: new BoxDecoration(
  image: new DecorationImage(
  image: new ExactAssetImage('assets/images/unlock2.png'),
  fit: BoxFit.cover,
  ),
  ),
  child:
  new BackdropFilter(
  filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
  child: new Container(
  decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
  ),
  ),
  //  new Image.asset('assets/images/lock1.png',scale: 2.8,fit:BoxFit.cover),
  ),*/
             // new Image.asset('assets/images/unlock2.png',scale: 2.8,fit: BoxFit.cover,)
  ),
      ),
  ),
  ],
        ),
  ),
  new Positioned(
  right: 1.0,
  top: -1.0,
  child:
      Row(
        children: <Widget>[
      Align(
        alignment: Alignment.topRight,
        child:
        new Container(
          margin: EdgeInsets.only(right: 15.0,top:10),
          child:
  new GestureDetector(
  onTap: () {
    listenerRepository.onLockTap(context, true);
  } ,
  child:
  AvatarGlow(
    startDelay: Duration(milliseconds: 1000),
    glowColor: Colors.blue,
    endRadius: 48.0,
    duration: Duration(milliseconds: 2000),
    repeat: true,
    showTwoGlows: true,
    repeatPauseDuration: Duration(milliseconds: 100),
    child: Material(
      elevation: 0.0,
      shape: CircleBorder(),
      child: CircleAvatar(
        backgroundColor:Colors.black12, //Colors.grey[100] ,
        child: Image.asset('assets/images/lock_2.png',scale: 0.5, ),
        radius: 24.0,
        //shape: BoxShape.circle
      ),
    ),
    shape: BoxShape.circle,
    animate: lockStatus,
    curve: Curves.fastOutSlowIn,
  ),

        ),
      ),
      ),
      ],
        ),
        ),
        new Positioned(
          left: 0.0,
          right: 0.0,
          top: 0.0,
  bottom: 0.0,
  child:
        Row(
          children: <Widget>[
      Expanded(
  child:
        Padding(
          padding:EdgeInsets.only(top: 4.0,left:0.0, right: 25.0,),
          child:
          Container(
            height:0.5,

            color:Colors.blueGrey,),),
  ),

      new GestureDetector(
        onTap: () {

        if(engineStatus)
            bp.BlocProvider.of<GlobalBloc>(context).messageBloc.addition.add(new Message(text: 'assets/images/car_start_3_1.png',status: false));
        else
          bp.BlocProvider.of<GlobalBloc>(context).messageBloc.addition.add(new Message(text: 'assets/images/car_start_3.png',status: true));


        //noty.updateValue(new Message(text: 'assets/images/car_start_3.png',status: true));
        },
      child:
      new Padding(padding: EdgeInsets.only(top: 4.0) ,
      child:

  AvatarGlow(
  startDelay: Duration(milliseconds: 1000),
  glowColor: Colors.pink,
  endRadius: MediaQuery.of(context).size.width/4.5,
  duration: Duration(milliseconds: 2000),
  repeat: true,
  showTwoGlows: true,
  repeatPauseDuration: Duration(milliseconds: 100),
  child: Material(
  elevation: 0.0,
  shape: CircleBorder(),
  child: CircleAvatar(
  backgroundColor:Colors.white, //Colors.grey[100] ,
  child: Image.asset(startImgPath,scale: 1,),
  radius:MediaQuery.of(context).size.width/5.0,
  //shape: BoxShape.circle
  ),
  ),
  shape: BoxShape.circle,
  animate: engineStatus,
  curve: Curves.fastOutSlowIn,
  ),

  ),
      ),
  Expanded(
  child:
        Padding(
          padding:EdgeInsets.only(top: 4.0,left: 25.0, right: 0.0,),
          child:
          Container(
            height:0.5,
            color:Colors.blueGrey,),),
        ),
  ],
  ),
        ),

        new Positioned(
          right: 1.0,
          bottom: 1.0,
          child:
          Row(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child:
                new Container(
                  margin: EdgeInsets.only(right: 25.0,bottom:15),
                  child:
                  new GestureDetector(
                    onTap: () {
                      listenerRepository.onLockTap(context, true);
                    } ,
                    child:
                    AvatarGlow(
                      startDelay: Duration(milliseconds: 1000),
                      glowColor: Colors.blue,
                      endRadius: 30.0,
                      duration: Duration(milliseconds: 2000),
                      repeat: true,
                      showTwoGlows: true,
                      repeatPauseDuration: Duration(milliseconds: 100),
                      child: Material(
                        elevation: 0.0,
                        shape: CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor:Colors.black12, //Colors.grey[100] ,
                          child: Image.asset('assets/images/dashboard.png',scale: 3.5, ),
                          radius: 18.0,
                          //shape: BoxShape.circle
                        ),
                      ),
                      shape: BoxShape.circle,
                      animate: lockStatus,
                      curve: Curves.fastOutSlowIn,
                    ),

                  ),
                ),
              ),
            ],
          ),
        ),
        new Positioned(
          left: -1.0,
          bottom: -1.0,
          child:
          Row(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child:
                new Container(
                  margin: EdgeInsets.only(left: 25.0,bottom:5),
                  child:
                  new GestureDetector(
                    onTap: () {
                      listenerRepository.onLockTap(context, true);
                    } ,
                    child:
                    AvatarGlow(
                      startDelay: Duration(milliseconds: 1000),
                      glowColor: Colors.blue,
                      endRadius: 40.0,
                      duration: Duration(milliseconds: 2000),
                      repeat: true,
                      showTwoGlows: true,
                      repeatPauseDuration: Duration(milliseconds: 100),
                      child: Material(
                        elevation: 0.0,
                        shape: CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor:Colors.black12, //Colors.grey[100] ,
                          child: Image.asset('assets/images/find_car.png',scale: 3.5, ),
                          radius: 18.0,
                          //shape: BoxShape.circle
                        ),
                      ),
                      shape: BoxShape.circle,
                      animate: lockStatus,
                      curve: Curves.fastOutSlowIn,
                    ),

                  ),
                ),
              ),
            ],
          ),
        ),
 ],
  );
}


BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border.all(
      width: 0.5,
      color: Colors.pinkAccent,
    ),
    borderRadius: BorderRadius.all(
        Radius.circular(5.0)
    ),
  );
}
CarStateVM currentState;
CarStateVM currentState2;

Widget buildCarRow(BuildContext context,
    NotyBloc<Message> carPageChangedNoty,
    NotyBloc<CarStateVM> carStateNoty,
    int index,
    CarStateVM statusVM,
    AnimationController rotationController,
    int counter) {

return
  StreamBuilder<CarStateVM>(
      stream: carStateNoty.noty,
      initialData: statusVM,
      builder: (BuildContext c, AsyncSnapshot<CarStateVM> data) {
        if (data != null && data.hasData) {
           currentState = data.data;
            rotationController.forward();
        }
        else
          {
            currentState=statusVM;
          }
  return

    AnimatedSwitcher(
      duration: const Duration(milliseconds: 3000),
  transitionBuilder: (Widget child, Animation<double> animation) {
  return FadeTransition(child: child, opacity:animation);
  },
  child:
  Container(
    margin: EdgeInsets.all(0.0),
    alignment: Alignment.topCenter,
    width: MediaQuery.of(context).size.width/1.8,
    height: MediaQuery.of(context).size.height/1.7,
    key: ValueKey(counter),
    //color: Color(0xff757575),
  child:

        Stack(
          overflow: Overflow.visible,
          alignment: Alignment.center,
          children: <Widget>[

        /*statusVM.carStatus==CarStatus.BOTHCLOSED  ? */
            new Align(
              alignment: Alignment(0,0),
              child:
            new Padding(padding: EdgeInsets.only(top: 1.0),
            child:
        new Image.asset(  currentState.carImage/*imgList[index]*/,
            fit: BoxFit.cover,
          scale: 1.0,),
  )  ,),



            new Padding(padding: EdgeInsets.only(top: 1.0),
              child: currentState.carCaputImage.isNotEmpty ?
              new Image.asset( currentState.carCaputImage,
                fit: BoxFit.cover,
                scale: 1.0,) :
              new Container(),

            ) ,
       new Padding(padding: EdgeInsets.only(top: 1.0),
              child: currentState.carDoorImage.isNotEmpty ?
              new Image.asset( currentState.carDoorImage,
                fit: BoxFit.cover,
                scale: 1.0,) :
              new Container(),

         ) ,
            new Padding(padding: EdgeInsets.only(top: 1.0),
              child:
              currentState.carTrunkImage.isNotEmpty ?
              new Image.asset( currentState.carTrunkImage,
                fit: BoxFit.cover,
                scale: 1.0,) :
                new Container(),
            ) ,

            Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                /*image: DecorationImage(
                  colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                    //image: AssetImage(carNumbers[index]),
                    fit: BoxFit.cover),*/
              ),
              child: CircleAvatar(
                backgroundColor: Colors.black12,
                radius: 50.0,
                child: Text(statusVM.carId.toString(),style: TextStyle(color: Colors.pinkAccent.withOpacity(0.95),fontSize: 14.0,fontWeight: FontWeight.bold),),
              )
            ),

    ],
        ),

    ),
    );
      },

  );
}

 buildStatusRow(BuildContext context,
     NotyBloc<Message> carPageChangedNoty,
     NotyBloc<CarStateVM> carStatusNoty,
     CarStateVM carStateVM,
     bool lockStatus,
     bool shockStatus,
     bool powerStatus,
      AnimationController animController) {

  double w=MediaQuery.of(context).size.width/8.0;
  var _currentColorRow=carStateVM.getCurrentColor();
  double i_w=32.0;
  double i_h=32.0;
  double m_top=10.0;
  double m_bot=10.0;
  return
    StreamBuilder<Message>(
        stream: carPageChangedNoty.noty,
        initialData: null,
        builder: (BuildContext c, AsyncSnapshot<Message> data) {
          if (data != null && data.hasData) {
            Message msg = data.data;
            if (msg.type == 'CARPAGE') {
             // _currentColor = colors[msg.index];

            }
          }
          return
            StreamBuilder<CarStateVM>(
              stream: carStatusNoty.noty,
              initialData: carStateVM,
              builder: (BuildContext c, AsyncSnapshot<CarStateVM> data) {
                  if(data!=null && data.hasData)
                    {
                      CarStateVM carState=data.data;
                      //currentState2=carState;
                      lock_status=!carState.isDoorOpen;
                      trunk_status=carState.isTraunkOpen;
                      power_status=carState.isPowerOn!=null ? carState.isPowerOn : false;

                    }
                return
    Container(
      margin: EdgeInsets.only(right: 10.0,top: 60.0),
      width:MediaQuery.of(context).size.width/8.0,
   height: MediaQuery.of(context).size.height*0.55,
   child:
    Column(

      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
          //color: Colors.white,
          alignment: Alignment.center,
          height:i_h,
          width: i_w,
          padding: EdgeInsets.symmetric(horizontal: 1.0),
          child:
          Center(
            child:

            Container(
              //color: Colors.white,
              margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
              alignment: Alignment.center,
              height:i_h,
              width: i_w,
              child:  !shock_status ?

              Image.asset('assets/images/shock.png',
                fit: BoxFit.cover, color:  _currentColorRow  ,) :
              BounceAnimationBuilder(
                child:  ImageNeonGlow(imageUrl: 'assets/images/shock.png',counter: 0,color: _currentColorRow,),
                animationController: animController,
                start: lock_status,),
            ),
          ),

        ),
  Container(
    margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
    //color: Colors.white,
    alignment: Alignment.center,
    height:i_h,
    width: i_w,
    padding: EdgeInsets.symmetric(horizontal: 1.0),
    child:
        Center(
    child:

    Container(
      //color: Colors.white,
        margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
        alignment: Alignment.center,
        height:i_h,
        width: i_w,
            child:  !lock_status ?

            Image.asset('assets/images/lock_11.png',
            fit: BoxFit.cover, color:  _currentColorRow  ,) :
            BounceAnimationBuilder(
                child:  ImageNeonGlow(imageUrl: 'assets/images/lock_11.png',counter: 0,color: _currentColorRow,),
                animationController: animController,
            start: lock_status,),
    ),
    ),

  ),
        Container(
          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
          //color: Colors.white,
          alignment: Alignment.center,
          height:i_h,
          width: i_w,
          padding: EdgeInsets.symmetric(horizontal: 1.0),
          child:
          Center(
            child:
            Container(
              //color: Colors.white,
                margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
                alignment: Alignment.center,
                height:i_h,
                width: i_w,
                child:
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 48.0,
                  child:  !trunk_status ?
                    Image.asset('assets/images/trunk.png',
                      fit: BoxFit.cover, color:  _currentColorRow ,) :
                  BounceAnimationBuilder(
                      child: ImageNeonGlow(imageUrl: 'assets/images/trunk.png',counter: 0,color: _currentColorRow,),
                  animationController: animController,
                  start: trunk_status,),
                ),
            ),
          ),

        ),
        Container(
          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
          //color: Colors.white,
          alignment: Alignment.center,
          height:i_h,
          width: i_w,
          padding: EdgeInsets.symmetric(horizontal: 1.0),
          child:
          Center(
              child:
   Container(
   //color: Colors.white,
       margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
   alignment: Alignment.topCenter,
   height:i_h,
   width: i_w,
   child:
  /* BounceAnimationBuilder(
                child:*/
              Image.asset('assets/images/horn.png',
                scale: 1.5,fit: BoxFit.cover,
                  color: _currentColorRow) ,
   /*animationController: animController,
   start: false,),*/
          ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
          //color: Colors.white,
          alignment: Alignment.center,
          height:i_h,
          width: i_w,
          padding: EdgeInsets.symmetric(horizontal: 1.0),
          child:
          Center(
              child:
   Container(
   //color: Colors.white,
       margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
   alignment: Alignment.topCenter,
   height:i_h,
   width: i_w,
   child: !power_status ?
              Image.asset('assets/images/power.png',
                scale: 1.5,fit: BoxFit.cover,
                  color: _currentColorRow):
   BounceAnimationBuilder(
                child: ImageNeonGlow(imageUrl: 'assets/images/power.png',color: _currentColorRow,counter: 0,),
   animationController: animController,
   start: power_status,),
          ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
          //color: Colors.white,
          alignment: Alignment.center,
          height:i_h,
          width: i_w,
          padding: EdgeInsets.symmetric(horizontal: 1.0),
          child:
          Center(
              child:
   Container(
   //color: Colors.white,
       margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
   alignment: Alignment.topCenter,
   height:i_h,
   width: i_w,
   child:
       lock_status ?
              Image.asset('assets/images/unlock_22.png',
                scale: 0.5,fit: BoxFit.cover,
                  color: _currentColorRow) :
       BounceAnimationBuilder(
                child: ImageNeonGlow(imageUrl: 'assets/images/unlock_22.png',color: _currentColorRow,counter: 0,),
       animationController: animController,
       start: !lock_status,),
          ),
          ),
        ),
      ],
    ),
    );
              },
            );
        },

  );
}

 buildLockPanelRow(BuildContext context,int carIndex,NotyBloc<Message> carLockNoty)
 {
   bool lockPanelStatus=false;
   return
     StreamBuilder<Message>(
         stream: carLockNoty.noty,
         initialData: new Message(type: 'LOCK_PANEL',status: false,),
         builder: (BuildContext c, AsyncSnapshot<Message> data) {
     if (data != null && data.hasData) {
       lockPanelStatus=data.data.status;
     }
     return
     Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
     new Align(
     alignment: Alignment.centerLeft,
       child:
       new Padding(padding: EdgeInsets.symmetric(horizontal: 15.0),
         child:
         new Shimmer.fromColors(
           baseColor:  Colors.redAccent ,
           highlightColor: Colors.white ,
           direction: ShimmerDirection.rtl,
           period: new Duration(seconds: 3),
           child: new Container(
             margin: EdgeInsets.only(right: 5.0),
             width: 18.0,
             height: 18.0,
             child:
                GestureDetector(
                  onTap: () {
                    lockPanelStatus=!lockPanelStatus;
                    carLockNoty.updateValue(new Message(type: 'LOCK_PANEL',status: lockPanelStatus,index: carIndex));
                  },
                  behavior: HitTestBehavior.translucent,
                  child: SwitchlikeCheckbox(checked: lockPanelStatus),
                ),
           ),
         ),
       ),
     ) ,
   ],
     );
         }
     );
 }
 buildArrowRow(BuildContext context,int carIndex,CarStateVM carStateVM,
     bool left,NotyBloc<Message> carPageChangedNoty,
     OpacityNotifier opacityNotifier) {
   var _currentColorRow=carStateVM.getCurrentColor();
   var opacityValue=1.0;
  return
    /*Container(
      margin: EdgeInsets.only(bottom: 10.0),
      height: 28.0,
        child:*/
        /*Stack(
          overflow: Overflow.visible,
          children: <Widget>[*/
    MultiProvider(
      providers: [


   StreamProvider<Message>(create: (context)=>carPageChangedNoty.noty,
   initialData: null,),
      ],
            child:
                Consumer<OpacityNotifier> (
                  builder: (context,opacity,child) {
                    return
                      AnimatedOpacity(
                        // If the widget is visible, animate to 0.0 (invisible).
                        // If the widget is hidden, animate to 1.0 (fully visible).
                        opacity: opacity.value,
                        duration: Duration(milliseconds: 500),
                        // The green box must be a child of the AnimatedOpacity widget.
                        child:
                        Container(
                          margin: EdgeInsets.only(
                              right: 15.0, top: 1.0, left: 15.0),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.0,
                          height: 38.0,
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Align(
                                alignment: Alignment.center,
                                child:
                                new Padding(padding: EdgeInsets.symmetric(
                                    horizontal: 1.0),
                                  child:
                                  new Shimmer.fromColors(
                                    baseColor: Colors.indigoAccent,
                                    highlightColor: Colors.white,
                                    direction: ShimmerDirection.rtl,
                                    period: new Duration(seconds: 3),
                                    child: new Container(
                                        margin: EdgeInsets.only(right: 1.0),
                                        height: 30.0,
                                        child:
                                        Text(DartHelper.isNullOrEmptyString(
                                            carStateVM.brandTitle),
                                            style: TextStyle(fontSize: 18.0,
                                                fontWeight: FontWeight.bold))
                                    ),
                                  ),
                                ),
                              ),
                              new Align(
                                alignment: Alignment.centerLeft,
                                child:
                                new Padding(padding: EdgeInsets.symmetric(
                                    horizontal: 1.0),
                                  child:
                                  new Shimmer.fromColors(
                                    baseColor: Colors.indigoAccent,
                                    highlightColor: Colors.white,
                                    direction: ShimmerDirection.rtl,
                                    period: new Duration(seconds: 3),
                                    child: new Container(
                                      alignment: Alignment.topCenter,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width / 3.0,
                                      height: 30.0,
                                      child:
                                      Text(DartHelper.isNullOrEmptyString(
                                          carStateVM.modelTitle),
                                        style: TextStyle(fontSize: 18.0,
                                            fontWeight: FontWeight.bold),),
                                      //),
                                    ),
                                  ),
                                ),
                              ),
                              new Align(
                                alignment: Alignment.centerRight,
                                child:
                                new Padding(padding: EdgeInsets.symmetric(
                                    horizontal: 1.0),
                                  child:
                                  new Shimmer.fromColors(
                                    baseColor: Colors.indigoAccent,
                                    highlightColor: Colors.white,
                                    direction: ShimmerDirection.ltr,
                                    period: new Duration(seconds: 3),
                                    child:
                                    new Container(
                                      margin: EdgeInsets.only(left: 0.0),

                                      height: 30.0,
                                      child:
                                      new Text(DartHelper.isNullOrEmptyString(
                                          carStateVM.colorTitle),
                                          style: TextStyle(fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            // ),
                            /*],*/
                          ),
                        ),
                      );
                  },
            ),
  );
}

int _currebtCarIndex=0;
buildMapRow(BuildContext context,
    CarStateVM carStateVM,
    NotyBloc<Message> carPageChangedNoty,
    NotyBloc<CarStateVM> carStateNoty,
    AnimationController animController) {
  var _currentColorRow=carStateVM.getCurrentColor();
  double i_w=28.0;
  double i_h=28.0;
  double m_top=0.0;
  double m_bot=5.0;

  return
    StreamBuilder<Message>(
        stream: carPageChangedNoty.noty,
        initialData: null,
        builder: (BuildContext c, AsyncSnapshot<Message> data) {
          if (data.data != null && data.hasData) {
            Message msg = data.data;
            if (msg.type == 'CARPAGE') {
              _currebtCarIndex = msg.index;
              // _currentColor = colors[msg.index];

            }
          }
          return
            StreamBuilder<CarStateVM>(
              stream: carStateNoty.noty,
              initialData: null,
              builder: (BuildContext c, AsyncSnapshot<CarStateVM> data) {
                if (data.data != null && data.hasData) {
                  CarStateVM stateVM = data.data;
                  isPark=stateVM.isPark;
                  isGPSOn=stateVM.isGPSOn;
                  isHighSpeed=stateVM.highSpeed;
                }
                return
                  Container(
                    margin: EdgeInsets.only(top: 60.0,right: 10),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width / 8.0,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.55,
                    child:
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Container(
                          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
                          //color: Colors.white,
                          alignment: Alignment.center,
                          height:i_h,
                          width: i_w,
                          padding: EdgeInsets.symmetric(horizontal: 1.0),
                          child:
                          Center(
                            child:

                            Container(
                              //color: Colors.white,
                              margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
                              alignment: Alignment.center,
                              height:i_h,
                              width: i_w,
                              child:  !isHighSpeed ?

                              Image.asset('assets/images/speed.png',
                                fit: BoxFit.cover, color:  _currentColorRow  ,) :
                              BounceAnimationBuilder(
                                child:  ImageNeonGlow(imageUrl: 'assets/images/speed.png',counter: 0,color: _currentColorRow,),
                                animationController: animController,
                                start: isHighSpeed,),
                            ),
                          ),

                        ),
                        Container(
                          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
                          //color: Colors.white,
                          alignment: Alignment.center,
                          height:i_h,
                          width: i_w,
                          padding: EdgeInsets.symmetric(horizontal: 1.0),
                          child:
                          Center(
                            child:

                            Container(
                              //color: Colors.white,
                              margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
                              alignment: Alignment.center,
                              height:i_h,
                              width: i_w,
                              child:  !isPark ?

                              Image.asset('assets/images/park.png',
                                fit: BoxFit.cover, color:  _currentColorRow  ,) :
                              BounceAnimationBuilder(
                                child:  ImageNeonGlow(imageUrl: 'assets/images/park.png',counter: 0,color: _currentColorRow,),
                                animationController: animController,
                                start: isPark,),
                            ),
                          ),

                        ),

                        Container(
                          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
                          //color: Colors.white,
                          alignment: Alignment.center,
                          height:i_h,
                          width: i_w,
                          padding: EdgeInsets.symmetric(horizontal: 1.0),
                          child:
                          Center(
                            child:

                            Container(
                              //color: Colors.white,
                              margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
                              alignment: Alignment.center,
                              height:i_h,
                              width: i_w,
                              child:  !isGPSOn ?

                              Image.asset('assets/images/gps.png',
                                fit: BoxFit.cover, color:  _currentColorRow  ,) :
                              BounceAnimationBuilder(
                                child:  ImageNeonGlow(imageUrl: 'assets/images/gps.png',counter: 0,color: _currentColorRow,),
                                animationController: animController,
                                start: isGPSOn,),
                            ),
                          ),

                        ),

                        Container(
                          margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
                          //color: Colors.white,
                          alignment: Alignment.center,
                          height:i_h,
                          width: i_w,
                          padding: EdgeInsets.symmetric(horizontal: 1.0),
                          child:
                          Center(
                            child:

                            Container(
                              //color: Colors.white,
                              margin: EdgeInsets.only(top: 0.0,bottom: 0.0),
                              alignment: Alignment.center,
                              height:i_h,
                              width: i_w,
                              child:  !isGPSOn ?

                              Image.asset('assets/images/gprs.png',
                                fit: BoxFit.cover, color:  _currentColorRow  ,) :
                              BounceAnimationBuilder(
                                child:  ImageNeonGlow(imageUrl: 'assets/images/gprs.png',counter: 0,color: _currentColorRow,),
                                animationController: animController,
                                start: isGPSOn,),
                            ),
                          ),

                        ),

                          Container(
                            // color: Color(0xff757575),
                            margin: EdgeInsets.only(top: m_top, bottom: m_bot),
                            child:
                            Stack(

                              children: <Widget>[

                Padding(
                padding: EdgeInsets.only(top:0.0),
                child:
                                new Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    //color: Colors.white,
                                    alignment: Alignment.center,
                                    height: i_h,
                                    width: i_w,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 1.0),
                                    child:
                                    Center(
                                      child:
                                      Container(
                                        //color: Colors.white,
                                          alignment: Alignment.center,
                                          height: i_h,
                                          width: i_w,
                                          child:
                                          Image.asset(
                                            'assets/images/battery_1.png',
                                            scale: 1.0, fit: BoxFit.cover,
                                            color: _currentColorRow,)
                                      ),
                                    ),
                                  ),

                                ),
                ),
                                Padding(
                                  padding: EdgeInsets.only(top:25.0),
                                  child:
                                  Container(
                                    height: 20.0,
                                    child:
                                    Center(

                                      child: Text( DartHelper.isNullOrEmptyString( (carStateVM.battery_value/10).toString(),),textAlign: TextAlign.center,style: TextStyle(fontSize: 12.0,color: _currentColorRow),),
                                    ),),
                                ),
                              ],
                            ),
                          ),

                        Container(
                          margin: EdgeInsets.only(top: m_top, bottom: m_bot),
                          // color: Color(0xff757575),
                          child:
                          Stack(

                            children: <Widget>[

                Padding(
                padding: EdgeInsets.only(top:0.0),
                child:
                              new Align(
                                alignment: Alignment.center,
                                child: Container(
                                  //color: Colors.white,
                                  alignment: Alignment.center,
                                  height: i_h,
                                  width: i_w,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1.0),
                                  child:
                                  Center(
                                    child:
                                    Container(
                                      //color: Colors.white,
                                        alignment: Alignment.center,
                                        height: i_h,
                                        width: i_w,
                                        child:
                                        Image.asset('assets/images/celsius.png',
                                          scale: 1.0, fit: BoxFit.cover,
                                          color: _currentColorRow,)
                                    ),
                                  ),
                                ),
                              ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top:25.0),
                                child:
                                Container(
                                  height: 15.0,
                                  child: Center(

                                    child:Text(DartHelper.isNullOrEmptyString( carStateVM.tempreture.toString()),textAlign: TextAlign.center,style: TextStyle(fontSize: 12.0,color: _currentColorRow)),),
                                ),),
                            ],
                          ),
                        ),
                        /* Container(
                    margin: EdgeInsets.only(top: m_top,bottom: m_bot ),
                    //color: Color(0xff757575),
                    child:
                    Stack(
                      children: <Widget>[
                        new Align(
                          alignment: Alignment.center,
                          child:
                          new
                          Container(
                            //color: Colors.white,
                            alignment: Alignment.center,
                            height: i_h,
                            width: i_w,
                            padding: EdgeInsets.symmetric(horizontal: 1.0),
                            child:
                            Center(
                              child:
                              Container(
                                //color: Colors.white,
                                alignment: Alignment.topCenter,
                                height: i_h,
                                width: i_w,
                                child:
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        '/mappage',arguments: new MapVM(
                                      carId: 0,
                                        carCounts: centerRepository.getCarsToAdmin().length,
                                      cars: centerRepository.getCarsToAdmin(),
                                    ));
                                    */ /*RxBus.post(new ChangeEvent(message: 'MAP_PAGE'));*/ /* */ /*Navigator.of(context).pushNamed('/map');*/ /*
                                  },
                                  child:
                                  new Image.asset(
                                    'assets/images/find_car3.png',
                                    scale: 0.5,
                                  color: _currentColorRow ,),),
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                    // ),
                    // ],
                    //),
                  );
              },
            );
        },
    );
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}



/*final List childTouch=imgList.map(
      (url) {
    return Container(
      margin: EdgeInsets.all(0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: 1000.0,
        ),
      ),
    );
  },
).toList();*/



/*final List childListView=imgList.map(
      (url) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: 100.0,
        ),
      ),
    );
  },
).toList();*/

/*final List child = map<Widget>(
  imgList,
      (index, i) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Stack(children: <Widget>[
          Image.network(i, fit: BoxFit.cover, width: 1000.0),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                'No. $index image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  },
).toList();*/


