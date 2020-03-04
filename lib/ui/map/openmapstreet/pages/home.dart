import 'dart:async';

import 'package:anad_magicar/bloc/theme/change_theme_bloc.dart';
import 'package:anad_magicar/bloc/values/notify_value.dart';
import 'package:anad_magicar/common/constants.dart';
import 'package:anad_magicar/components/button.dart';
import 'package:anad_magicar/components/flutter_form_builder/flutter_form_builder.dart';
import 'package:anad_magicar/components/image_neon_glow.dart';
import 'package:anad_magicar/components/no_data_widget.dart';
import 'package:anad_magicar/components/send_data.dart';
import 'package:anad_magicar/data/database_helper.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/data/rxbus.dart';
import 'package:anad_magicar/date/helper/shamsi_date.dart';
import 'package:anad_magicar/model/apis/api_car_model.dart';
import 'package:anad_magicar/model/apis/api_route.dart';
import 'package:anad_magicar/model/apis/api_search_car_model.dart';
import 'package:anad_magicar/model/apis/paired_car.dart';
import 'package:anad_magicar/model/apis/slave_paired_car.dart';
import 'package:anad_magicar/model/cars/car.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/model/join_car_model.dart';
import 'package:anad_magicar/model/message.dart';
import 'package:anad_magicar/model/user/admin_car.dart';
import 'package:anad_magicar/model/viewmodel/car_info_vm.dart';
import 'package:anad_magicar/model/viewmodel/car_page_vm.dart';
import 'package:anad_magicar/model/viewmodel/car_state.dart';
import 'package:anad_magicar/model/viewmodel/map_vm.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/ui/map/geojson/geojson.dart';
import 'package:anad_magicar/ui/map/openmapstreet/pages/paired_car_expandable_panel.dart';
import 'package:anad_magicar/ui/screen/home/index.dart';
import 'package:anad_magicar/ui/screen/setting/native_settings_screen.dart';
import 'package:anad_magicar/utils/dart_helper.dart';
import 'package:anad_magicar/utils/date_utils.dart';
import 'package:anad_magicar/widgets/bottom_sheet_custom.dart';
import 'package:anad_magicar/widgets/drawer/app_drawer.dart';
import 'package:anad_magicar/widgets/drawer/drawer.dart' as drw;
import 'package:anad_magicar/widgets/extended_navbar/extended_navbar_scaffold.dart';
import 'package:anad_magicar/widgets/flash_bar/flash_helper.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:latlong/latlong.dart';
import 'package:livemap/livemap.dart';
import 'package:location/location.dart';
import 'package:pedantic/pedantic.dart';
import '../widget/drawer.dart';
import 'package:geopoint/geopoint.dart';
import 'package:geopoint_location/geopoint_location.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:user_location/user_location.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import 'package:anad_magicar/widgets/persian_datepicker/persian_datepicker.dart';
import 'package:flutter/services.dart';
final List<String> carImgList = [
  "assets/images/car_red.png",
  "assets/images/car_blue.png",
  "assets/images/car_black.png",
  "assets/images/car_white.png",
  "assets/images/car_yellow.png",
  "assets/images/car_gray.png",
];

class MapPage extends StatefulWidget {


  int carId;
  int carCounts;
  List<AdminCarModel> carsToUser;
  MapVM mapVM;
  MapPage({
    @required this.mapVM,
    @required this.carId,
    @required this.carCounts,
    @required this.carsToUser
  });


  @override
  MapPageState createState() {
    // TODO: implement createState
    return new MapPageState();
  }



}

class MapPageState extends State<MapPage> {
  static const String route = '/mappage';
  static final String MINMAX_SPEED_TAG='MINMAX_SPEED';
  static final String MIN_SPEED_TAG='MIN_SPEED';
  static final String MAX_SPEED_TAG='MAX_SPEED';
  String userName='';
  int userId=0;
  int minSpeed=30;
  int maxSpeed=100;
  int minDelay=0;
  int currentCarLocationSpeed=0;
  static bool forAnim=false;
  static int lastCarIdSelected=0;
  bool _showInfoPopUp=false;
  bool isGPSOn=false;
  bool isGPRSOn=false;
  bool showAllItemsOnMap=true;
  final TextEditingController textEditingController = TextEditingController();
  String fromDate='';
  String toDate='';
  String minStopTime1='';
  String mStopTime2='';
  PersianDatePickerWidget persianDatePicker;
  final String imageUrl = 'assets/images/user_profile.png';
  final String markerRed='assets/images/mark_red.png';
  final String markerGreen='assets/images/mark_green.png';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = new GlobalKey<FormState>();

  bool _autoValidate=false;
  bool isDark=false;
  List<CarInfoVM> carInfos=new List();
  NotyBloc<Message> reportNoty=new NotyBloc<Message>();
  NotyBloc<Message> statusNoty=new NotyBloc<Message>();

  NotyBloc<Message> moreButtonNoty=new NotyBloc<Message>();
  NotyBloc<Message> pairedChangedNoty=new NotyBloc<Message>();
  NotyBloc<Message> animateNoty=new NotyBloc<Message>();
  NotyBloc<Message> showAllItemsdNoty=new NotyBloc<Message>();


  Future<List<CarInfoVM>> carInfoss;
  Future<List<ApiPairedCar>> carsPaired;


  List<AdminCarModel> carsToUserSelf;
  List<ApiPairedCar> carsPairedList;
  List<SlavedCar> carsSlavePairedList;

  int _carCounts=0;
  LocationData currentLocation ;
  var location = new Location();

  List<Marker> markers = [];
  List<LatLng> points=[];
  StreamController<LatLng> markerlocationStream = StreamController();
  UserLocationOptions userLocationOptions;

  final polygons = <Polygon>[];
  List<Polyline> lines = new List();//<Polyline>[];
  Future<List<Polyline>> lines2 ;

  MapController mapController;
  LiveMapController liveMapController;

  Marker _marker;
  Timer _timer;
  int _markerIndex = 0;
  Polyline _polyLine;
  Polyline _polyLineAnim;

  LatLng _fpoint;
  LatLng _spoint;

  int _pointIndex=0;
  Timer _timerLine;
  int _polyLineIndex = 0;

  String pelakForSearch='';
  String carIdForSearch='';
  String mobileForSearch='';
  String minStopTime;
  String minStopDate;

  String minStopTime2;
  String minStopDate2;

  LatLng firstPoint;
  LatLng currentCarLatLng;

  Widget getMarkerOnSpeed(int speed) {
    var item=Image.asset( markerRed  , key: ObjectKey(Colors.red ));
    if(maxSpeed==null || maxSpeed==0)
       maxSpeed=100;
    if(minSpeed==null || minSpeed==0)
      minSpeed=30;
    if(speed==null)
      speed=0;
    if (speed > maxSpeed)
    return item;
    else
   /*return Image.asset( markerGreen  , key: ObjectKey(Colors.green ),) ;
       else*/ return
   Image.asset( markerGreen  , color: Colors.amber,key: ObjectKey(Colors.amber ),) ;
  }
  getMinMaxSpeed() async {
    /*maxSpeed=await prefRepository.getMinMaxSpeed(SettingsScreenState.MAX_SPEED_TAG);
    minSpeed=await prefRepository.getMinMaxSpeed(SettingsScreenState.MIN_SPEED_TAG);*/

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

  animateRoutecar() async {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {

        _marker = markers[_markerIndex];
        _markerIndex = (_markerIndex + 1) % markers.length;
       // animateNoty.updateValue(new Message(type: 'MARKER_ANIM'));
    });
  }

  animateRoutecarPolyLines() async {


    int next=0;
    int index=0;
    _timerLine = Timer.periodic(Duration(milliseconds: 500), (_) {

        _polyLine = lines[_polyLineIndex];
        _polyLineIndex = (_polyLineIndex + 1) % lines.length;
        //index=_polyLine.points.length;
        if (index < _polyLine.points.length - 1) {
          index++;
          next = index + 1;
        }
       // _fpoint=_polyLine.points[_pointIndex];
        _pointIndex=(_pointIndex + 1) % _polyLine.points.length;
        if (index < _polyLine.points.length - 1) {
          _fpoint = _polyLine.points[index];
          _spoint = _polyLine.points[next];
          points..add(_fpoint)..add(_spoint);
        }
        if((_pointIndex+1)>=_polyLine.points.length){
          _timerLine.cancel();
        }
        _polyLineAnim=new Polyline(strokeWidth: 12.0,
            color: Colors.pinkAccent,
            points: points);
        animateNoty.updateValue(new Message(type: 'LINE_ANIM'));
    });
  }

  getUserId() async {
    userId=await prefRepository.getLoginedUserId();
  }

  _onPelakChanged( value)
  {
    pelakForSearch=value.toString();
  }

  _onMobileChanged( value)
  {
    mobileForSearch=value.toString();
  }
  _onCarIdChanged( value)
  {
    carIdForSearch=value.toString();
  }

  _deleteCarFromPaired(int masterId,int  secondCar,) async{
    // var result=await restDatasource.savePairedCar(car);
    List<int> carIds=[secondCar];
    var result=await restDatasource.deletePairedCars(masterId, carIds);
     if(result!=null){
       if(result.IsSuccessful){
         centerRepository.showFancyToast(result.Message);
        // setState(() {
           carsSlavePairedList.removeWhere((c)=>c.CarId==secondCar);
         pairedChangedNoty.updateValue(new Message(type: 'CAR_PAIRED'));
         //});
       }else{
         centerRepository.showFancyToast(result.Message);
       }
     }
  }

  _showCarPairedActions(SlavedCar car,BuildContext context){
    showModalBottomSheetCustom(context: context ,
        mHeight: 0.70,
        builder: (BuildContext context) {
          return new Container(
            height: 250.0,
            child:
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
        GestureDetector(
          child : Padding(
            padding: EdgeInsets.only(bottom: 20.0, right: 10.0,left: 10.0),
            child:
            Button(clr: Colors.pinkAccent,wid:150.0,title: Translations.current.confirm(),),),
          onTap: (){
            var cpaired=carsPairedList.where((c)=>c.SecondCarId==car.CarId).toList();
            if(cpaired!=null && cpaired.length>0) {
              ApiPairedCar pairedCar = new ApiPairedCar(
                  PairedCarId:cpaired.first.PairedCarId , MasterCarId: car.masterId,
                  SecondCarId: car.CarId,
                  FromDate: cpaired.first.FromDate,
                  ToDate: DateTimeUtils.getDateJalali(),
                  FromTime: cpaired.first.FromTime,
                  ToTime: DateTimeUtils.getTimeNow(),
                  Description: null,
                  IsActive: true,
                  RowStateType: Constants.ROWSTATE_TYPE_UPDATE,
                  CarIds: null,
                  master: null,
                  slaves: null);
              addCarToPaired(pairedCar,Constants.ROWSTATE_TYPE_UPDATE);
            }
            Navigator.pop(context);
          },),
        GestureDetector(
          child : Padding(
        padding: EdgeInsets.only(bottom: 20.0, right: 10.0,left: 10.0),
            child:
          Button(clr: Colors.pinkAccent,wid:150.0,title: Translations.current.delete(),),),
          onTap: (){

            _deleteCarFromPaired(car.masterId,car.CarId);
            Navigator.pop(context);
          },),

        ],
      ),


        GestureDetector(
          child :Button(clr: Colors.pinkAccent,wid:150.0,title: Translations.current.navigateToCurrent(),),
          onTap: (){
            Navigator.pop(context);
            navigateToCarSelected(0,true, car.CarId);
          },),



      ],
    ),
          );
        });
  }

  _showBottomSheetForSearchedCar(BuildContext cntext, Car car )
  {
    showModalBottomSheetCustom(context: cntext ,
        builder: (BuildContext context) {
          return new Container(
            height: 450.0,
            child:
            new Card(
              margin: new EdgeInsets.only(
                  left: 5.0, right: 5.0, top: 78.0, bottom: 5.0),
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white,width: 0.5),
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 0.0,
              child:
              new Container(
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                  color: Color(0xfffefefe),
                  borderRadius: new BorderRadius.all(
                      new Radius.circular(5.0)),
                ),
                child:
                      Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0,left: 10.0),
                                child:
                                Text(Translations.current.carId()),),
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0,left: 10.0),
                                  child:
                                Text(car.carId.toString()),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0,left: 10.0),
                                  child:
                                Text(Translations.current.carpelak()),),
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0,left: 10.0),
                                  child:
                                Text(car.pelaueNumber),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0,left: 10.0),
                                  child:
                                  new Container(
                                    alignment: Alignment.center,
                                    decoration: new BoxDecoration(
                                      color: Colors.pinkAccent,
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(5.0)),
                                    ),
                                    child:
                                  FlatButton(
                                      onPressed: (){

                                        String toDate=DateTimeUtils.convertIntoDateTime(DateTimeUtils.getDateJalali());
                                        String toTime=DateTimeUtils.getTimeNow();

                                        ApiPairedCar pairedCar=new ApiPairedCar(
                                            PairedCarId: 0, MasterCarId: widget.mapVM.carId,
                                            SecondCarId: car.carId,
                                            FromDate: toDate, ToDate: null,
                                            FromTime: toTime, ToTime: null ,
                                            Description: null, IsActive: true,
                                            RowStateType: Constants.ROWSTATE_TYPE_INSERT,
                                            CarIds: null, master: null, slaves: null);

                                        addCarToPaired(pairedCar,Constants.ROWSTATE_TYPE_INSERT);
                                        Navigator.pop(context);
                                      },
                                     child: Text( Translations.current.addToPaired(),style: TextStyle(color:Colors.white),)),),),

                              ],
                            ),

                          ],
                        ),
                      ),
              ),
            ),
          );
        });
  }

  searchCar() async{

    SearchCarModel searchCarModel=new SearchCarModel(
        AdminUserId: null,
        RequestFromThisUserId: null,
        CarId:int.tryParse( carIdForSearch),
        Message: null,
        userId: userId,
        pelak: pelakForSearch,
        DecviceSerialNumber: mobileForSearch);
    try {
      centerRepository.showProgressDialog(context, 'در حال جستجو...');
     List<Car> result = await restDatasource.searchCars(int.tryParse( carIdForSearch),pelakForSearch,mobileForSearch);
     if(result!=null && result.length>0){
       centerRepository.dismissDialog(context);
       var cr=result.where((c)=>c.carId==int.tryParse( carIdForSearch)).toList();
       if(cr!=null && cr.length>0) {
         _showBottomSheetForSearchedCar(context, cr.first);
       }
       else{
         centerRepository.showFancyToast('خودروی مورد نظر یافت نشد');
       }
     }
    }
    catch(error)
    {
     print('');
    }

  }

  Future<List<CarInfoVM>> getCarInfo() async {

    carsToUserSelf= centerRepository.getCarsToAdmin();

    if(_carCounts==0) {

      if(centerRepository.getCarsToAdmin()!=null)
        _carCounts=centerRepository.getCarsToAdmin().length;
      fillCarInfo(carsToUserSelf);

    }
    var cars=await restDatasource.getAllPairedCars();
    carsPairedList=cars;
    carsSlavePairedList=new List();
    for(var c in cars) {
      for(var sc in c.slaves ){
        sc.masterId=c.master;
      }
      carsSlavePairedList..addAll(c.slaves);
    }

        fillCarsInGroup();
      return carInfos;
  }

  fillCarsInGroup() async{
    for(var car in carInfos){
       if(carsSlavePairedList!=null && carsSlavePairedList.length>0) {
         var carfound = carsSlavePairedList.where((c) => c.CarId == car.carId)
             .toList();
         if (carfound != null && carfound.length > 0) {
           car.hasJoind = true;
         }
         else {
           car.hasJoind = false;
         }
       }
    }
  }

  fillCarInfo(List<AdminCarModel> carsToUser)
  {
    carInfos = new List();
    int indx=0;
    for (var car in carsToUser) {
      Car car_info = centerRepository
          .getCars()
          .where((c) => c.carId == car.CarId)
          .toList()
          .first;
      if (car_info != null) {
        int tip=0;
        if(centerRepository.getCarBrands()!=null)
        {
          // tip=centerRepository.getCarBrands().where((d)=>d.brandId==car_info. )
        }
        SaveCarModel editModel=new SaveCarModel(
            carId: car_info.carId,
            brandId:0,
            modelId: null,
            tip: null,
            pelak: car_info.pelaueNumber,
            colorId: car_info.colorTypeConstId,
            distance: null,
            ConstantId: null,
            DisplayName: null,);

        CarStateVM carState=centerRepository.getCarStateVMByCarId(car_info.carId);

        CarInfoVM carInfoVM = new CarInfoVM(
            brandModel: null,
            car: car_info,
            carColor: null,
            carModel: null,
            carModelDetail: null,
            brandTitle: car_info.brandTitle,
            modelTitle: car_info.carModelTitle,
            modelDetailTitle: car_info.carModelDetailTitle,
            color: '',
            carId: car_info.carId,
            Description: car_info.description,
            fromDate: car.FromDate,
            CarToUserStatusConstId: car.CarToUserStatusConstId,
            isAdmin: car.IsAdmin,
            userId: car.UserId,
        imageUrl: carState!=null ? carState.carImage : carImgList[indx]);
        carInfos.add(carInfoVM);
        indx++;
      }

    }
  }

  showSpeedDialog(int speed) async {
    FlashHelper.informationBar2(context, message: ' سرعت خودرو در این نقطه :'+speed.toString() + 'km/h');
  }
  Future<void> processData() async {
    final geojson = GeoJson();
    geojson.processedMultipolygons.listen((GeoJsonMultiPolygon multiPolygon) {
      for (final polygon in multiPolygon.polygons) {
        final geoSerie = GeoSerie(
            type: GeoSerieType.polygon,
            name: polygon.geoSeries[0].name,
            geoPoints: <GeoPoint>[]);
        for (final serie in polygon.geoSeries) {
          geoSerie.geoPoints.addAll(serie.geoPoints);
        }
        final color =
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
            .withOpacity(0.3);
        final poly = Polygon(
            points: geoSerie.toLatLng(ignoreErrors: true), color: color);
        setState(() => polygons.add(poly));
      }
    });
    geojson.endSignal.listen((bool _) => geojson.dispose());
    final data = await rootBundle.loadString('assets/images/test.geojson');
    final nameProperty = "ADMIN";
    unawaited(geojson.parse(data, nameProperty: nameProperty, verbose: true));
  }




  Future<List<Polyline>> processLineData(bool fromCurrent,
      String clat,String clng,
      String fromDate,String toDate,
      bool forReport,bool anim,bool fromGo) async {

    String sdate=DateTimeUtils.convertIntoDateTime(DateTimeUtils.getDateJalali());
    String tdate=DateTimeUtils.convertIntoDateTime(DateTimeUtils.getDateJalaliWithAddDays(-3));

    ApiRoute route=new ApiRoute(
        carId: lastCarIdSelected,
        startDate: forReport ? DateTimeUtils.convertIntoDateTime(fromDate) : sdate,
        endDate: forReport ? DateTimeUtils.convertIntoDateTime(toDate) : tdate,
        dateTime: null,
        speed: null,
        lat: null,
        long: null,
        enterTime: null,
        carIds: null,
        DeviceId: null,
        Latitude: null,
        Longitude: null,
        Date: null,
        Time: null,
        CreatedDateTime: null);


    centerRepository.showProgressDialog(context, Translations.current.loadingdata());
    var queryBody = '{"coordinates":[';//$lng2,$lat2],[$lng1,$lat1]]}';
    if(!fromCurrent) {
      final pointDatas = await restDatasource.getRouteList(route);
      if (pointDatas != null && pointDatas.length > 0) {
        if(markers!=null && markers.length>0){
          markers.clear();
        }
        var points = '';
        int index = pointDatas.length - 1;

        String latStr1=pointDatas[0].lat;
        String lngStr1=pointDatas[0].long;
        var firstLat=latStr1.split('*');
        var firstLng=lngStr1.split('*');
        var secondLat=firstLat[1].split("'");
        var secondLng=firstLng[1].split("'");

        double fresultLatLng=ConvertDegreeAngleToDouble(
            double.tryParse( firstLat[0]), double.tryParse( secondLat[0]), double.tryParse( secondLat[1]));

        double sresultLatLng=ConvertDegreeAngleToDouble(
            double.tryParse( firstLng[0]), double.tryParse( secondLng[0]), double.tryParse( secondLng[1]));

        firstPoint = LatLng(fresultLatLng, sresultLatLng);
        for (var i = 0; i < pointDatas.length; i++) {
          String latStr2=pointDatas[i].lat;
          String lngStr2=pointDatas[i].long;
          var firstLat1=latStr2.split('*');
          var firstLng1=lngStr2.split('*');
          var secondLat1=firstLat1[1].split("'");
          var secondLng1=firstLng1[1].split("'");

          double fresultLatLng1=ConvertDegreeAngleToDouble(
              double.tryParse( firstLat1[0]), double.tryParse( secondLat1[0]), double.tryParse( secondLat1[1]));

          double sresultLatLng1=ConvertDegreeAngleToDouble(
              double.tryParse( firstLng1[0]), double.tryParse( secondLng1[0]), double.tryParse( secondLng1[1]));


          double lat = fresultLatLng1;
          double lng = sresultLatLng1;
          int speed=pointDatas[i].speed;
          if(speed==null)
            speed=0;

            if(index>100) {
              if (i < index && speed > 0 && (i % 20)==0)
                points += '[$lng,$lat],';
              else if (i>=index && speed > 0)
                points += '[$lng,$lat]';
            }else if(index>300) {
              if (i < index && speed > 0 && (i % 40)==0)
                points += '[$lng,$lat],';
              else if (i>=index && speed > 0)
                points += '[$lng,$lat]';
            }
            else if(index >400) {
              if (i < index && speed > 0 && (i % 60)==0)
                points += '[$lng,$lat],';
              else if (i>=index && speed > 0)
                points += '[$lng,$lat]';
            }
            else {
              if (i < index )
                points += '[$lng,$lat],';
              else
                points += '[$lng,$lat]';
            }
          //points..add(item);

            var marker = Marker(
              width: 30.0,
              height: 30.0,
              point: LatLng(lat,lng),
              builder: (ctx) {
                return
                  GestureDetector(
                    onTap: () {
                        _showInfoPopUp = true;
                        showSpeedDialog(speed);
                    },
                    child: Container(
                        width: 30.0,
                        height: 30.0,
                        child: CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Colors.transparent,
                            child: getMarkerOnSpeed(speed)
                            ,)
                    ),);}
            );
            markers.add(marker);
        }
        if(points.endsWith(',')){
          points=points.substring(0,points.length-1);
        }
        queryBody = queryBody + points + ']}';
      } else {
        var points = '';
        double lat = 35.7511447;
        double lng = 51.4716509 ;
        firstPoint = LatLng(lat,lng);
        double lat2 = 35.796249;
        double lng2 = 51.427583 ;

        points += '[$lng,$lat],';
        points += '[$lng2,$lat2]';

        queryBody = queryBody + points + ']}';

      }
    }
    else{
      double speed=80;
      if(currentLocation!=null) {
        double lat1 = double.tryParse(clat);
        double lng1 = double.tryParse(clng);
        firstPoint=LatLng(lat1,lng1);
        if(clat==null || clat.isEmpty || clng==null || clng.isEmpty){
          lat1=  35.7511447;
          lng1=51.4716509;
        }

        double lat2 = double.tryParse(currentLocation.latitude.toString());
        double lng2 = double.tryParse(currentLocation.longitude.toString());
        speed=currentLocation.speed;
        if(speed==null)
          speed=0;
        if(currentCarLocationSpeed==null || currentCarLocationSpeed==0)
          currentCarLocationSpeed=0;
        var marker = Marker(
          width: 30.0,
          height: 30.0,
          point: LatLng(lat1,lng1),
          builder: (ctx) {
            return
              GestureDetector(
                onTap: () {
                    _showInfoPopUp = true;
                    showSpeedDialog(int.tryParse( currentCarLocationSpeed.toString()));
                },
                child: Container(
                    width: 30.0,
                    height: 30.0,
                    child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.transparent,
                        child: getMarkerOnSpeed(int.tryParse( currentCarLocationSpeed.toString())),)
                ),);}
        );
        markers.add(marker);

         marker = Marker(
          width: 30.0,
          height: 30.0,
          point: LatLng(lat2,lng2),
          builder: (ctx) {
            return
              GestureDetector(
                onTap: () {
                    _showInfoPopUp = true;
                    showSpeedDialog(int.tryParse(speed.toString()));
                },
                child: Container(
                    width: 30.0,
                    height: 30.0,
                    child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.transparent,
                        child:  getMarkerOnSpeed(int.tryParse( speed.toString())) ,)
                ),);}
        );
        markers.add(marker);
         queryBody = '{"coordinates":[[$lng2,$lat2],[$lng1,$lat1]]}';

      }
      else
        {
          centerRepository.showFancyToast(Translations.current.yourLocationNotFound());
        }
    }
    if(lines!=null && lines.length>0){
      lines.clear();
    }
      final openRoutegeoJSON = await restDatasource
          .fetchOpenRouteServiceURlJSON(body: queryBody);
      if (openRoutegeoJSON != null) {
        final geojson = GeoJson();
        geojson.processedLines.listen((GeoJsonLine line) {

          final color = Color(
              (math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
              .withOpacity(0.5);
          lines.add(Polyline(
              strokeWidth: 12.0,
              color: color,
              points: line.geoSerie.toLatLng()));
        });
        geojson.endSignal.listen((_) {
          geojson.dispose();
        });
        // unawaited(geojson.parse(data, verbose: true));
        await geojson.parse(openRoutegeoJSON, verbose: true);
      }

    if(lines!=null && lines.length>0) {
     // moreButtonNoty.updateValue(new Message(type:'CLOSE_MORE_BUTTON'));
    if(!fromGo) {
      RxBus.post(new ChangeEvent(type: 'CLOSE_MORE_BUTTON'));
    }
      liveMapController.mapController.move(firstPoint, 15);
      return lines;
    }

    return null;
  }



  Future<List<Marker>> processLineDataForReportMinTime(
      String fromDat,
      String toDat,
      String minTime) async {

    String sdate=DateTimeUtils.convertIntoDateTime(DateTimeUtils.getDateJalali());
    String tdate=DateTimeUtils.convertIntoDateTime(DateTimeUtils.getDateJalaliWithAddDays(0));


    ApiRoute route=new ApiRoute(
        carId: lastCarIdSelected,
        startDate: (fromDat!=null && fromDat.isNotEmpty) ? DateTimeUtils.convertIntoDateTime(fromDat) : sdate,
        endDate: (toDat!=null && toDat.isNotEmpty) ? DateTimeUtils.convertIntoDateTime(toDat) : tdate ,
        dateTime: null,
        speed: null,
        lat: null,
        long: null,
        enterTime: null,
        carIds: null,
        DeviceId: null,
        Latitude: null,
        Longitude: null,
        Date: null,
        Time: null,
        CreatedDateTime: null);


    if(minDelay==null){
      minDelay=10;
    }
    centerRepository.showProgressDialog(context, Translations.current.loadingdata());
    var queryBody = '{"coordinates":[';//$lng2,$lat2],[$lng1,$lat1]]}';

      final pointDatas = await restDatasource.getRouteList(route);
      if (pointDatas != null && pointDatas.length > 0) {
        if(markers!=null && markers.length>0)
          markers.clear();
        minStopTime='';
        minStopTime2='';
        minStopDate='';
        minStopDate2='';

        var points = '';
        int index = pointDatas.length - 1;

        String latStr1=pointDatas[0].lat;
        String lngStr1=pointDatas[0].long;
        var firstLat=latStr1.split('*');
        var firstLng=lngStr1.split('*');
        var secondLat=firstLat[1].split("'");
        var secondLng=firstLng[1].split("'");

        double fresultLatLng=ConvertDegreeAngleToDouble(
            double.tryParse( firstLat[0]), double.tryParse( secondLat[0]), double.tryParse( secondLat[1]));

        double sresultLatLng=ConvertDegreeAngleToDouble(
            double.tryParse( firstLng[0]), double.tryParse( secondLng[0]), double.tryParse( secondLng[1]));

        firstPoint = LatLng(fresultLatLng,
            sresultLatLng);
        for (var i = 0; i < pointDatas.length; i++) {

          String latStr2=pointDatas[i].lat;
          String lngStr2=pointDatas[i].long;
          var firstLat1=latStr2.split('*');
          var firstLng1=lngStr2.split('*');
          var secondLat1=firstLat1[1].split("'");
          var secondLng1=firstLng1[1].split("'");

          double fresultLatLng1=ConvertDegreeAngleToDouble(
              double.tryParse( firstLat1[0]), double.tryParse( secondLat1[0]), double.tryParse( secondLat1[1]));

          double sresultLatLng1=ConvertDegreeAngleToDouble(
              double.tryParse( firstLng1[0]), double.tryParse( secondLng1[0]), double.tryParse( secondLng1[1]));

          double lat = fresultLatLng1;
          double lng = sresultLatLng1;
          if(i<pointDatas.length-1) {
             latStr2=pointDatas[i+1].lat;
             lngStr2=pointDatas[i+1].long;

             firstLat1=latStr2.split('*');
             firstLng1=lngStr2.split('*');
             secondLat1=firstLat1[1].split("'");
             secondLng1=firstLng1[1].split("'");

             fresultLatLng1=ConvertDegreeAngleToDouble(
                double.tryParse( firstLat1[0]), double.tryParse( secondLat1[0]), double.tryParse( secondLat1[1]));

             sresultLatLng1=ConvertDegreeAngleToDouble(
                double.tryParse( firstLng1[0]), double.tryParse( secondLng1[0]), double.tryParse( secondLng1[1]));

            double lat2 = fresultLatLng1;
            double lng2 = sresultLatLng1;

          /*  double lat2 = double.tryParse(pointDatas[i + 1].lat);
            double lng2 = double.tryParse(pointDatas[i + 1].lat);
*/
            int speed = pointDatas[i].speed;
            if(speed==null)
              speed=0;
            if (i < index)
              points += '[$lng,$lat],';
            else
              points += '[$lng,$lat]';
            //points..add(item);
            final Distance distance = new Distance();

            if(speed<1 && (minStopTime==null || minStopTime.isEmpty)) {
              minStopDate=pointDatas[i].dateTime;
              minStopTime=pointDatas[i].enterTime;
            } else if(speed>1 && (minStopTime!=null && minStopTime.isNotEmpty)){
              minStopDate2=pointDatas[i].dateTime;
              minStopTime2=pointDatas[i].enterTime;



              var time1=minStopTime.split(':');
              var time2=minStopTime2.split(':');
             /* int h1=int.tryParse(time1[0]);
              int m1=int.tryParse(time1[1]);
              int s1=int.tryParse(time1[2]);

              int h2=int.tryParse(time2[0]);
              int m2=int.tryParse(time2[1]);
              int s2=int.tryParse(time2[2]);*/

              minStopDate=minStopDate.replaceAll('/', '');
              minStopDate2=minStopDate2.replaceAll('/', '');
              if(minStopDate.trim()==minStopDate2.trim()) {
                int diff = DateTimeUtils.diffMinsFromDateToDate4(
                    DateTimeUtils.convertIntoTimeOnly(minStopTime2),
                    DateTimeUtils.convertIntoTimeOnly(minStopTime));
                if (diff > minDelay) {

                  var marker = Marker(
                    width: 30.0,
                    height: 30.0,
                    point: LatLng(lat, lng),
                    builder: (ctx) {
                      return
                        GestureDetector(
                          onTap: () {
                              showSpeedDialog(speed);
                          },
                          child: Container(
                              width: 30.0,
                              height: 30.0,
                              child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors.transparent,
                                  child: getMarkerOnSpeed(speed),
                          ),),);} );

                  markers.add(marker);
                   marker = Marker(
                    width: 30.0,
                    height: 30.0,
                    point: LatLng(lat2, lng2),
                    builder: (ctx){
                      return
                        GestureDetector(
                          onTap: () {
                            showSpeedDialog(speed);
                          },
                          child: Container(
                              width: 30.0,
                              height: 30.0,
                              child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors.transparent,
                                  child: Image.asset( markerRed
                                      , key: ObjectKey(Colors.red ),))
                          ),);}
                  );

                  markers.add(marker);
                  minStopTime='';
                }
              }
            }
          }
        }

        queryBody = queryBody + points + ']}';
      } else {
        var points = '';
        double lat = 35.7511447;
        double lng = 51.4716509 ;
        firstPoint = LatLng(lat,lng);
        double lat2 = 35.796249;
        double lng2 = 51.427583 ;

        points += '[$lng,$lat],';
        points += '[$lng2,$lat2]';
        queryBody = queryBody + points + ']}';

      }


    if(markers!=null && markers.length>0) {
      if(firstPoint.longitude!= markers[0].point.latitude && firstPoint.longitude!= markers[0].point.longitude){
        firstPoint=markers[0].point;
      }
     // moreButtonNoty.updateValue(new Message(type: 'CLOSE_MORE_BUTTON'));
      RxBus.post(new ChangeEvent(type: 'CLOSE_MORE_BUTTON'));

      liveMapController.mapController.move(firstPoint, 15);
      reportNoty.updateValue(new Message(type: 'HAS_MARKERS'));

      return markers;
    }
      return null;
  }


  @override
  void initState() {
   // processData();


    getUserId();
    //getMinMaxSpeed();
    location = new Location();
    mapController=new MapController();
    reportNoty=new NotyBloc<Message>();
    pairedChangedNoty=new NotyBloc<Message>();
    moreButtonNoty=new NotyBloc<Message>();
    animateNoty=new NotyBloc<Message>();
    statusNoty=new NotyBloc<Message>();
    showAllItemsdNoty=NotyBloc<Message>();
    carInfoss= getCarInfo();
    getCurrentLoaction();

    liveMapController = LiveMapController(
      autoCenter: true, mapController: mapController, verbose: true,autoRotate: true,positionStreamEnabled: true,
      updateTimeInterval: 1,
      updateDistanceFilter: 1,);


     //currentLocation = LocationData;

    location.onLocationChanged().listen((LocationData currentLocation) {
      print(currentLocation.latitude);
      print(currentLocation.longitude);

      //mapController.move(LatLng(currentLocation.latitude,currentLocation.longitude), 17.0);
    });

    if(widget.mapVM!=null && widget.mapVM.forReport!=null &&
    widget.mapVM.forReport){
      lines2=processLineData(false, '', '',widget.mapVM.fromDate,widget.mapVM.toDate,widget.mapVM.forReport,false,false);
    }
    super.initState();
  }
  _onConfirmDefaultSettings(String type,BuildContext context) async{
    _formKey.currentState.save();

      prefRepository.setMinMaxSpeed(MIN_SPEED_TAG,  minSpeed);
      prefRepository.setMinMaxSpeed(MAX_SPEED_TAG,  maxSpeed);
      centerRepository.showFancyToast('اطلاعات با موفقیت ذخیره شد.');

    Navigator.pop(context);
  }
  _showDefaultSettingsSheet(BuildContext context,String type)
  {
  showModalBottomSheetCustom(context: context ,
  mHeight: 0.90,
  builder: (BuildContext context) {
  return Builder( builder:
  (context) {
  return  Form(
  key: _formKey,
  child:
  Container(
  width: MediaQuery.of(context).size.width-10,
  height: 450.0,
  child:
   Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
  Container(
  width: 150.0,
  height: 50.0,
  child: _buildMaxTextField(
  Translations.current.maxSpeed(), 80.0, maxSpeed.toString()),
  ),
  ],
  ),
  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
  Container(
  width: 150.0,
  height: 50.0,
  child: _buildMinTextField(
  Translations.current.minSpeed(), 80.0, minSpeed.toString()),
  )
  ],
  ),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            child: FlatButton(
              onPressed: () {
                _onConfirmDefaultSettings(type,context);
              },
              child: Button(title: Translations.current.confirm(),wid: 120.0,clr: Colors.green,),
            )
        )
      ],
    ),
      ],
  ),
  ),
    );
  },
  );
  });
  }

  Widget _buildMinDelayTextField(String hint,double width, String result) {
    return
      new TextFormField(
        decoration: new InputDecoration(
          labelText: hint,
          fillColor: Colors.white,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(2.0),
            borderSide: new BorderSide(
            ),
          ),
          //fillColor: Colors.green
        ),
        validator: (val) {
            return null;
        },
        onSaved: (value){
          minDelay=int.tryParse( value==null ? '0' : value);
        },
        keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false) ,
        style: new TextStyle(
          fontFamily: "IranSans",
        ),
        onFieldSubmitted: (value) {

        },
      );
  }
  Widget _buildMaxTextField(String hint,double width, String result) {
    return
      new TextFormField(
        decoration: new InputDecoration(
          labelText: "حداکثر سرعت",
          fillColor: Colors.white,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(2.0),
            borderSide: new BorderSide(
            ),
          ),
          //fillColor: Colors.green
        ),
        validator: (val) {
            return null;
        },
        onSaved: (value){
          maxSpeed=int.tryParse( value==null ? '0' : value);
        },
        keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false) ,
        style: new TextStyle(
          fontFamily: "IranSans",
        ),
        onFieldSubmitted: (value) {

        },
      );
  }
  Widget _buildMinTextField(String hint,double width, String result) {
    return
      new TextFormField(
        decoration: new InputDecoration(
          labelText: "حداقل سرعت",
          fillColor: Colors.white,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(2.0),
            borderSide: new BorderSide(
            ),
          ),
          //fillColor: Colors.green
        ),
        validator: (val) {
            return null;
        },
        onSaved: (value){
          minSpeed=int.tryParse( value==null ? '0' : value);
          // result=value;
        },
        keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false) ,
        style: new TextStyle(
          fontFamily: "IranSans",
        ),
        onFieldSubmitted: (value) {

        },

      );
  }
  Widget createInfoPopup(String lastDateOnline,String lastTimeOnline,String pelak){
    return Container(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.pink,
        elevation: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
             ListTile(
              leading: Icon(Icons.album, size: 70),
              title: Text(lastDateOnline, style: TextStyle(color: Colors.white)),
              subtitle: Text(lastTimeOnline, style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.album, size: 70),
              title: Text(pelak, style: TextStyle(color: Colors.white)),
              subtitle: Text(lastTimeOnline, style: TextStyle(color: Colors.white)),
            ),
            ButtonBarTheme(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child:  Text(Translations.current.close(), style: TextStyle(color: Colors.white)),
                    onPressed: () {},
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<LocationData> getCurrentLoaction() async {
    try {
      currentLocation = await location.getLocation();
      if(currentLocation!=null) {
       // lines2= processLineData(currentLocation.latitude.toString(),currentLocation.longitude.toString());
        return currentLocation;
      }
    }  catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // error = 'Permission denied';
      }
      currentLocation = null;
    }
  }
   double ConvertDegreeAngleToDouble( double degrees, double minutes, double seconds )
  {
    //Decimal degrees =
    //   whole number of degrees,
    //   plus minutes divided by 60,
    //   plus seconds divided by 3600

    return degrees + (minutes/60) + (seconds/3600);
  }
  _showInfoDialog(int carId) async{
    List<int> carIds=new List();
    carIds..add(carId);

    ApiRoute apiRoute=new ApiRoute(carId: null,
        startDate: null,
        endDate: null,
        dateTime: null,
        speed: null,
        lat: null,
        long: null,
        enterTime: null,
        carIds: carIds,
        DeviceId: null,
        Latitude: null,
        Longitude: null,
        Date: null,
        Time: null,
        CreatedDateTime: null);
    var result=await restDatasource.getLastPositionRoute(apiRoute);
    if(result!=null && result.length>0) {

      String latStr=result[0].Latitude;
      String lngStr=result[0].Longitude;
      var firstLat=latStr.split('*');
      var firstLng=lngStr.split('*');
      var secondLat=firstLat[1].split("'");
      var secondLng=firstLng[1].split("'");

      double fresultLatLng=ConvertDegreeAngleToDouble(
          double.tryParse( firstLat[0]), double.tryParse( secondLat[0]), double.tryParse( secondLat[1]));

      double sresultLatLng=ConvertDegreeAngleToDouble(
          double.tryParse( firstLng[0]), double.tryParse( secondLng[0]), double.tryParse( secondLng[1]));

      double lat = fresultLatLng;
      double lng = sresultLatLng;
      LatLng latLng = LatLng(lat, lng);
      currentCarLatLng = LatLng(lat, lng);
      String date=result[0].Date;
      String time=result[0].Time;
      int speed=result[0].speed;

      String msgTemp=time+' '+ 'با سرعت : '+speed.toString()+' km/h ';
      DateTime newObjDate=DateTimeUtils.convertIntoDateObject(date);
      String newDate=DateTimeUtils.getDateJalaliFromDateTimeObj(newObjDate);
      FlashHelper.informationBar2(context,title: newDate, message:msgTemp,);
    }
    else{
      FlashHelper.informationBar2(context,title: null, message:'اطلاعاتی برای نمایش یافت نشد',);
    }
  }
  Future<ApiRoute> navigateToCarSelected(int index,bool isCarPaired,int carId) async{

    String imgUrl='';
    CarInfoVM carInfo;
    //SlavedCar carSlave;
    if(isCarPaired){
       // carSlave=carsSlavePairedList[index];
    }
    else{
      carInfo=carInfos[index];
    }

    List<int> carIds=new List();
    if(isCarPaired) {carIds..add(carId);
    imgUrl=carImgList[0];
    }
      else {
        carIds..add(carInfo.carId);
        imgUrl=carInfo!=null ?  carInfo.imageUrl : carImgList[0];
    }
      if(imgUrl==null || imgUrl.isEmpty){
        imgUrl=carImgList[0];
      }
    lastCarIdSelected=carId>0 ? carId : (carInfo!=null) ? carInfo.carId : 0;
    ApiRoute apiRoute=new ApiRoute(carId: null,
        startDate: null,
        endDate: null,
        dateTime: null,
        speed: null,
        lat: null,
        long: null,
        enterTime: null,
        carIds: carIds,
        DeviceId: null,
        Latitude: null,
        Longitude: null,
        Date: null,
        Time: null,
        CreatedDateTime: null);
    var result=await restDatasource.getLastPositionRoute(apiRoute);
    if(result!=null && result.length>0)
      {

        int speed=result[0].speed;
        String GPSDateTime=result[0].GPSDateTimeGregorian;

        String date=result[0].Date;
        String time=result[0].Time;

        if(date!=null && time !=null){
          isGPRSOn=true;
        }
        else{
          isGPRSOn=false;
        }

        DateTime gpsDt=DateTimeUtils.convertIntoDateTimeObject(GPSDateTime);
        DateTime now= DateTime.now();
        Duration diff=now.difference(gpsDt);
        if(diff.inMinutes<=2){
          isGPSOn=true;
        }
        else{
          isGPSOn=false;
        }

        if(speed==null )
          speed=100;

        currentCarLocationSpeed=speed;
        String latStr=result[0].Latitude;
        String lngStr=result[0].Longitude;
        var firstLat=latStr.split('*');
        var firstLng=lngStr.split('*');
        var secondLat=firstLat[1].split("'");
        var secondLng=firstLng[1].split("'");

        double fresultLatLng=ConvertDegreeAngleToDouble(
            double.tryParse( firstLat[0]), double.tryParse( secondLat[0]), double.tryParse( secondLat[1]));

        double sresultLatLng=ConvertDegreeAngleToDouble(
            double.tryParse( firstLng[0]), double.tryParse( secondLng[0]), double.tryParse( secondLng[1]));

        double lat=fresultLatLng;
        double lng=sresultLatLng;
        LatLng latLng=LatLng(lat,lng);
        currentCarLatLng=LatLng(lat,lng);
        liveMapController.mapController.move(latLng, 14);
      var marker=  Marker(
          width: 40.0,
          height: 40.0,
          point: latLng,
          builder: (ctx) => Container (
            child : GestureDetector(
            onTap: (){
              _showInfoDialog(lastCarIdSelected);
                _showInfoPopUp=true;

            },
            child: Container(
            width: 38.0,
            height: 38.0,
            child: CircleAvatar(
              radius: 38.0,
                backgroundColor: Colors.transparent,
                child:  Image.asset(imgUrl,key: ObjectKey( Colors.green),))
          ),),),
        );

        markers.add(marker);
        statusNoty.updateValue(new Message(type: 'GPS_GPRS_UPDATE'));
      }else {
      double lat = 35.796249;
      double lng = 51.427583 ;

      LatLng latLng=LatLng(lat,lng);
      currentCarLatLng=LatLng(lat,lng);
      liveMapController.mapController.move(latLng, 14);
      var marker=  Marker(

        width: 40.0,
        height: 40.0,
        point: latLng,
        builder: (ctx) => Container (
          child : GestureDetector(
          onTap: ()async {

              _showInfoPopUp=true;
              _showInfoDialog(lastCarIdSelected);

          },
          child:
            Container(
            width: 38.0,
            height: 38.0,
            child: CircleAvatar(
                radius: 38.0,
                backgroundColor: Colors.transparent,
                child: Image.asset(imgUrl,key: ObjectKey(Colors.amber),))
        ),),
        ),
      );

      markers.add(marker);
      statusNoty.updateValue(new Message(type: 'GPS_GPRS_UPDATE'));
    }
  }

  addCarToPaired(ApiPairedCar car,int type) async {
    if(type!=Constants.ROWSTATE_TYPE_UPDATE)
      car.PairedCarId=0;
    var result=await restDatasource.savePairedCar(car);
    if(result!=null) {
      centerRepository.showFancyToast(result.Message);
      if( result.IsSuccessful){
            centerRepository.showFancyToast(result.Message);
            pairedChangedNoty.updateValue(new Message(type:'CAR_PAIRED'));
   }
   else {
        centerRepository.showFancyToast(result.Message);
   }
  }
  }

  onCarPageTap()
  {
    Navigator.of(context).pushNamed('/carpage',arguments: new CarPageVM(
        userId: centerRepository.getUserCached().id,
        isSelf: true,
        carAddNoty: valueNotyModelBloc));
  }


  _showBottomSheetLastCars(BuildContext cntext,  List<ApiPairedCar> cars)
  {
    showModalBottomSheetCustom(context: cntext ,
        builder: (BuildContext context) {
          return new Container(
            height: 450.0,
            child:
            new Card(
              margin: new EdgeInsets.only(
                  left: 5.0, right: 5.0, top: 78.0, bottom: 5.0),
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white,width: 0.5),
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 0.0,
              child:
              new Container(
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                  color: Color(0xfffefefe),
                  borderRadius: new BorderRadius.all(
                      new Radius.circular(5.0)),
                ),
                child:
                PairedCarsExpandPanel(cars: cars,),
              ),
            ),
          );
        });
  }
  initDatePicker(TextEditingController controller,String type){
    persianDatePicker = PersianDatePicker(
      controller: controller,
      datetime: Jalali.now().toString(),
      fontFamily: 'IranSans',
      onChange: (String oldText, String newText){
        if(type=='From')
          fromDate=newText;
        else
          toDate=newText;
      },

    ).init();
    return persianDatePicker;
  }
  _onValueChanged(String value) {
    minStopTime=value;
  }
  showLastCarJoint(BuildContext cntext) async {
    //var cars=await databaseHelper.getLastCarsJoint();
    var cars=await restDatasource.getAllPairedCars();
    if(cars!=null && cars.length>0)
        _showBottomSheetLastCars(cntext, cars);
  }
  _showBottomSheetDates(BuildContext cntext) {
    showModalBottomSheetCustom(context: cntext ,
        mHeight: 0.95,
        builder: (BuildContext context) {
          return
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(Translations.current.fromDate(),
                  style: TextStyle(color: Colors.pinkAccent,fontSize: 15.0),
                  textAlign: TextAlign.center,),
                Container(
                  height: MediaQuery.of(context).size.height*0.35,
                  child: initDatePicker(textEditingController, 'From'),
                ),
                Text(Translations.current.toDate(),
                  style: TextStyle(color: Colors.pinkAccent,fontSize: 15.0),
                  textAlign: TextAlign.center,),
                Container(
                  height:MediaQuery.of(context).size.height*0.35,
                  child: initDatePicker(textEditingController, 'To'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10.0,left: 10.0),
                      child:
                    FlatButton(
                      child: Button(wid: 120.0,clr: Colors.pinkAccent,title: Translations.current.doFilter(),),
                      onPressed: () {
                        if(lastCarIdSelected==null || lastCarIdSelected==0){
                         centerRepository.showFancyToast('لطفا ابتدا خودرو را انتخاب نمایید');
                        }else {
                          forAnim=false;
                          Navigator.pop(context);
                          lines2 = processLineData(
                              false, currentCarLatLng.latitude.toString(),
                              currentCarLatLng.longitude.toString(), fromDate,
                              toDate, true,false,false);
                          Navigator.pop(context);

                        }
                      },
                    ),),
                    Padding(
                      padding: EdgeInsets.only(right: 10.0,left: 10.0),
                      child:
                    FlatButton(
                      child: Button(wid: 120.0,clr: Colors.pinkAccent,title: Translations.current.close(),),
                      onPressed: () {
                          Navigator.pop(context);
                      },
                    ),),
                  ],
                )
              ],
            );
        });

  }
  showFilterDate(BuildContext context, bool from) {
    return _showBottomSheetDates(context);
  }
  _showBottomSheetReport(BuildContext cntext)
  {
    double wid=MediaQuery.of(cntext).size.width*0.75;
    showModalBottomSheetCustom(context: cntext ,
        mHeight: 0.85,
        builder: (BuildContext context) {
          return Stack(
            overflow: Overflow.visible,
            //alignment: Alignment.topCenter,
            children: <Widget>[
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('اگر تاریخ را انتخاب نکنید بصورت پیش فرض روز جاری در نظر گرفته میشود')
                      ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                          margin: EdgeInsets.only(top: 5.0,right: 5.0,left: 5.0),
                          constraints: new BoxConstraints.expand(
                            height: 48.0,
                            width: wid,
                          ),
                          decoration: BoxDecoration(
                            //color: Colors.pinkAccent,
                            border: Border(),
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          ),
                          child: FlatButton(
                            onPressed: (){
                             // Navigator.pop(context);
                              showFilterDate(context, true);

                            },
                            child: Button(title: Translations.current.fromDateToDate(),wid: wid,clr: Colors.blueAccent,),
                          )
                      ),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        width: MediaQuery.of(context).size.width*0.85,
                        height: 400,
                        child:

                        new ListView (
                          physics: BouncingScrollPhysics(),
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.all(0.0),
                              width: MediaQuery.of(context).size.width*0.80,
                              height: 400,
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                //margin: EdgeInsets.symmetric(horizontal: 20.0),
                                children: <Widget>[
                                  SizedBox(
                                    height: 0,
                                  ),

                                  Container(
                                    alignment: Alignment.topCenter,
                                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                                    width:MediaQuery.of(context).size.width*0.75,
                                    child:
                                    Form(
                                      key: _formKey,
                                      autovalidate: _autoValidate,
                                      child:
                                      SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        physics: BouncingScrollPhysics(),
                                        child: new Column(
                                          children: <Widget>[
                                            Container(
                                              //height: 45,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.0, horizontal: 2.0),
                                              child:
                                              _buildMinDelayTextField('حداقل زمان توقف دقیقه', 150.0, null),
                                            ),
                                            Container(
                                              //height: 45,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.0, horizontal: 2.0),
                                              child:
                                                   _buildMinTextField('حداقل سرعت', 150.0, null),


                                            ),
                                            Container(
                                              //height: 45,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.0, horizontal: 2.0),
                                              child:
                                              _buildMaxTextField('حداکثر سرعت', 150.0, null),
                                            ),
                                            new GestureDetector(
                                              onTap: () {
                                              },

                                              child: new Container(
                                                  margin: EdgeInsets.only(top: 5.0,right: 5.0,left: 5.0,bottom: 5.0),
                                                  constraints: new BoxConstraints.expand(
                                                    height: 48.0,
                                                    width: wid,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    //color: Colors.pinkAccent,
                                                    border: Border(),
                                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: (){
          if(lastCarIdSelected==null || lastCarIdSelected==0){
          centerRepository.showFancyToast('لطفا ابتدا خودرو را انتخاب نمایید');
          }else {
                                                        forAnim=false;
                                                      _formKey.currentState.save();
                                                      processLineDataForReportMinTime(fromDate,toDate,minDelay.toString());
                                                      Navigator.pop(context);}
                                                    },
                                                    child: Button(title: Translations.current.showReport(),wid: wid,clr: Colors.blueAccent,),
                                                  )
                                              ),

                                            ),
                                            Padding(padding: EdgeInsets.only(bottom: 10.0),
                                            child:
                                            new GestureDetector(
                                              onTap: () {
                                                if(lastCarIdSelected==null || lastCarIdSelected==0){
                                                  centerRepository.showFancyToast('لطفا ابتدا خودرو را انتخاب نمایید');
                                                }else {
                                                  _formKey.currentState.save();
                                                  forAnim=true;
                                                 lines2= processLineData(
                                                      false, currentCarLatLng.latitude.toString(),
                                                      currentCarLatLng.longitude.toString(), fromDate,
                                                      toDate, true,true,false);
                                                 lines2.then((result){
                                                   if(result!=null && result.length>0) {
                                                       reportNoty.updateValue(new Message(type:'ANIM_ROUTE'));
                                                   }
                                                 });
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child:
                                              Container(
                                                width: wid,
                                                height: 40.0,
                                                child:
                                                new Button(title: 'گزارش با حرکت خودرو در مسیر',
                                                  color: Colors.white.value,
                                                  clr: Colors.pinkAccent,),
                                              ),
                                            ),),
                                            new GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child:
                                              Container(
                                                width: wid,
                                                height: 40.0,
                                                child:
                                                new Button(title: Translations.current.cancel(),
                                                  color: Colors.white.value,
                                                  clr: Colors.pinkAccent,),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[

                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }

  _showReportSheet(BuildContext context) async {
    _showBottomSheetReport(context);
  }

  _showMapGuid(BuildContext context) async {
    _showBottomSheetGuid(context);
  }

  _showBottomSheetGuid(BuildContext context) {
      double wid=MediaQuery.of(context).size.width*0.95;
      showModalBottomSheetCustom(context: context ,
          mHeight: 0.85,
          builder: (BuildContext context) {
            return new Padding(
              padding: EdgeInsets.only(top: 10.0,right: 10.0),
              child:
              Container(
            width: wid,
            child:
                new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 68,
                        height: 68,
                        child:
                        Padding(
                          padding: EdgeInsets.only(left: 5.0,right: 10.0),
                          child:
                      Image.asset(markerRed),
                      ),),
                      Container(
                        width: MediaQuery.of(context).size.width*0.70,
                        height: 48,
                        child:
                      Text('نقاط قرمز برروی نقشه نشان از سرعت بالای 100 کیلومتر می باشد',softWrap: true,style: TextStyle(fontSize: 13.0),),),
                      //Text('نقاط زرد برروی نقشه نشان از سرعت زیر 30 کیلومتر می باشد',overflow: TextOverflow.visible,softWrap: true,style: TextStyle(fontSize: 15.0),),
                     // Text('نقاط سبز برروی نقشه نشان از سرعت زیر 100 کیلومتر می باشد',overflow: TextOverflow.visible,softWrap: true,style: TextStyle(fontSize: 15.0),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 68,
                        height: 68,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0,right: 10.0),
                          child:
                      Image.asset(markerRed,color: Colors.amber,),),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width*0.70,
                        height: 48,
                        child:
                      Text('نقاط زرد برروی نقشه نشان از سرعت زیر 30 کیلومتر می باشد',softWrap: true,style: TextStyle(fontSize: 13.0),),),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.80,
                        height: 48,
                        child:
                      Text('با لمس هر نقطه اطلاعات سرعت و ... را مشاهده نمایید.',softWrap: true,style: TextStyle(fontSize: 13.0),),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.80,
                        height: 48,
                        child:
                      Text('برای گزارش حرکت خودرو با انتخاب تاریخ تا تاریخ و انتخاب تاریخ مورد نظر ',softWrap: true,style: TextStyle(fontSize: 13.0),),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.80,
                        height: 48,
                        child:
                      Text('و سپس لمس دکمه بستن در منوی زیرین گزارش مسیر با حرکت خودرو را انتخاب کنید',softWrap: true,style: TextStyle(fontSize: 13.0),),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.80,
                        height: 80,
                        child:
                        Text('جهت تایید یا رد درخواست افزودن خودرو به ارتباط گروهی در منوی پایین در قسمت مرتبط به خودروها جهت افزودن به گروه با لمس هر وخدور میتوانید تایید یا رد درخواست کنید.',softWrap: true,style: TextStyle(fontSize: 13.0),),),
                    ],
                  )
                  ]
            ),
              ),
            );
            });
  }

  showRouteCurrentToCar() async{
    if(lastCarIdSelected==null || lastCarIdSelected==0){
      centerRepository.showFancyToast('لطفا ابتدا خودرو را انتخاب نمایید');
    }else {
      lines2 = processLineData(true, currentCarLatLng.latitude.toString(),
          currentCarLatLng.longitude.toString(), '', '', false,false,true);
    }
  }

  showCarRoute() {
    if(lastCarIdSelected==null || lastCarIdSelected==0){
      centerRepository.showFancyToast('لطفا ابتدا خودرو را انتخاب نمایید');
    }else {
      lines2 = processLineData(false, '', '', '', '', false,false,false);
    }
  }

  @override
  void dispose() {
    pairedChangedNoty.dispose();
    markerlocationStream.close();
    animateNoty.dispose();
    _timer.cancel();
    _timerLine.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    markerlocationStream.stream.listen((onData) {
      print(onData.latitude);
    });
    userLocationOptions = UserLocationOptions(
        context: context,
        mapController: liveMapController.mapController,
        markers: markers,
        onLocationUpdate: (LatLng pos) {
          print("onLocationUpdate ${pos.toString()}");
         // mapController.move(pos, 17.0);
        },
        updateMapLocationOnPositionChange: true,
        showMoveToCurrentLocationFloatingActionButton: true,
        zoomToCurrentLocationOnLoad: true,
        fabBottom: 160,
        fabRight: 20,
        verbose: false);
    return StreamBuilder<Message>(
      //initialData: new Message(t),
      stream: pairedChangedNoty.noty,
      builder: (context,snapshot)
    {
      if(snapshot.hasData && snapshot.data!=null){
        if(snapshot.data.type=='CAR_PAIRED')
          getCarInfo();
      }
      return
        FutureBuilder<List<CarInfoVM>>(
          future: carInfoss,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null) {
              final parallaxCardItemsList = <ParallaxCardItem>[
                for(var car in carInfos)
                  ParallaxCardItem(
                    backColor: (car.hasJoind!=null && car.hasJoind) ? Colors.lightBlue : Colors.white,
                      title: DartHelper.isNullOrEmptyString(
                          car.car.pelaueNumber),
                      body: DartHelper.isNullOrEmptyString(
                          car.carId.toString()),
                      background: Container(
                        width: 50.0,
                       // color: (car.hasJoind!=null && car.hasJoind) ? Colors.lightBlue : Colors.white,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 30.0,
                          child: Image.asset(car.imageUrl),
                        ),
                      )),


              ];

              final carPairedItemsList = <ParallaxCardItem>[
                for(var car in carsSlavePairedList)
                  ParallaxCardItem(
                    backColor: Colors.blueAccent,
                    title: DartHelper.isNullOrEmptyString(car.BrandTitle),
                    body: DartHelper.isNullOrEmptyString(car.CarId.toString()),
                    background: Container(
                      width: 160.0,
                      color: Theme
                          .of(context)
                          .cardColor,
                      child: Container(
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            Row(
                              children: <Widget>[
                                Text(Translations.current.thisCarPaired(),
                                  style: TextStyle(fontSize: 10.0),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(Translations.current.masterCarId(),
                                    style: TextStyle(fontSize: 10.0)),
                                Text(DartHelper.isNullOrEmptyString(
                                    car.masterId.toString()),
                                    style: TextStyle(fontSize: 10.0)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(DartHelper.isNullOrEmptyString(
                                    car.CarModelTitle),
                                    style: TextStyle(fontSize: 10.0)),
                                Container(
                                  width: 50.0,
                                 // color:  Colors.lightBlue ,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 30.0,
                                    child: Image.asset(carImgList[1]),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(DartHelper.isNullOrEmptyString(
                                    car.CarModelDetailTitle),
                                    style: TextStyle(fontSize: 10.0)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ];

              return
                StreamBuilder<Message>(
                  stream: showAllItemsdNoty.noty,
                  builder: (context,snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null) {

                }
                return
                  ExtendedNavigationBarScaffold(
                    notyBloc: moreButtonNoty,
                    key: _scaffoldKey,
                    drawer: AppDrawer(userName: userName,
                      currentRoute: route,
                      imageUrl: imageUrl,
                      carPageTap: onCarPageTap,
                      carId: widget.mapVM.carId,),
                    body:
                    Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[

                        FutureBuilder<List<Polyline>>(
                            future: lines2,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data != null) {
                                centerRepository.dismissDialog(context);

                                return
                                  StreamBuilder<Message>(
                                    stream: reportNoty.noty,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        Message msg = snapshot.data;
                                        if (msg.type == 'ANIM_ROUTE') {
                                          // if (forAnim) {
                                          animateRoutecarPolyLines();
                                          // }
                                        }
                                        if (msg.type == 'CLEAR_MAP') {
                                          if (_timerLine != null &&
                                              _timerLine.isActive) {
                                            //_timerLine=null;
                                            _timerLine.cancel();
                                          }
                                          if (_polyLineAnim != null) {
                                            forAnim = false;
                                            _polyLineAnim = null;
                                          }

                                          if (lines != null &&
                                              lines.length > 0) {
                                            lines.clear();
                                          }
                                          if (markers != null &&
                                              markers.length > 0) {
                                            markers.clear();
                                          }
                                          if (lines2 != null) {
                                            lines2 = null;
                                          }
                                        }
                                      }
                                      return StreamBuilder<Message>(
                                        stream: animateNoty.noty,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            if (_fpoint != null)
                                              liveMapController.mapController
                                                  .move(_fpoint, 15);
                                          }
                                          return

                                            StreamBuilder<Message>(
                                              stream: statusNoty.noty,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data != null) {
              }
                                                      return
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .all(0.0),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                    top: 0.0,
                                                                    bottom: 0.0),
                                                                child: Text(
                                                                    ''),
                                                              ),
                                                              Flexible(
                                                                child: Stack(
                                                                  children: <
                                                                      Widget>[
                                                                    FlutterMap(
                                                                      mapController: liveMapController
                                                                          .mapController,
                                                                      options: MapOptions(
                                                                        center: firstPoint !=
                                                                            null
                                                                            ? firstPoint
                                                                            : currentLocation !=
                                                                            null
                                                                            ?
                                                                        LatLng(
                                                                            currentLocation
                                                                                .latitude,
                                                                            currentLocation
                                                                                .longitude)
                                                                            : LatLng(
                                                                            35.6917856,
                                                                            51.4204603),
                                                                        zoom: 15.0,
                                                                        plugins: [
                                                                          UserLocationPlugin(),
                                                                        ],
                                                                      ),

                                                                      layers: [
                                                                        TileLayerOptions(
                                                                         tms: true,
                                                                          urlTemplate:
                                                                          'http://tileserver.maptiler.com/nasa/{z}/{x}/{y}.png',
                                                                         /* 'https://{s}.tile.openstreetmap.org?layers=H&{z}/{x}/{y}.png',
                                                                          subdomains: [
                                                                            'a',
                                                                            'b',
                                                                            'c'
                                                                          ],*/
                                                                          // NetworkTileProvider or CachedNetworkTileProvider
                                                                          tileProvider: CachedNetworkTileProvider(),
                                                                        ),

                                                                        (forAnim &&
                                                                            _polyLineAnim !=
                                                                                null)
                                                                            ? PolylineLayerOptions(
                                                                            polylines: <
                                                                                Polyline>[
                                                                              _polyLineAnim
                                                                            ]) :
                                                                        PolylineLayerOptions(
                                                                            polylines: lines),

                                                                        MarkerLayerOptions(
                                                                            markers: markers),
                                                                        userLocationOptions,
                                                                      ],
                                                                    ),

                                                                    Positioned(
                                                                      right: 20.0,
                                                                      bottom: 310.0,
                                                                      child:
                                                                      Container(
                                                                        width: 38.0,
                                                                        height: 38.0,
                                                                        child:
                                                                        FloatingActionButton(
                                                                          onPressed: () {
                                                                            showAllItemsOnMap =
                                                                            !showAllItemsOnMap;
                                                                            showAllItemsdNoty
                                                                                .updateValue(
                                                                                new Message(
                                                                                    type: 'CLEAR_ALL'));
                                                                          },
                                                                          child: Container(
                                                                            width: 38.0,
                                                                            height: 38.0,
                                                                            child: Image
                                                                                .asset(
                                                                              'assets/images/clear_all.png',
                                                                              color: showAllItemsOnMap ? Colors
                                                                                  .white : Colors.amber,),),
                                                                          elevation: 0.0,
                                                                          backgroundColor: Colors
                                                                              .blueAccent,
                                                                          heroTag: 'CLEARALL',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    showAllItemsOnMap
                                                                        ? Positioned(
                                                                      right: 20.0,
                                                                      bottom: 260.0,
                                                                      child:
                                                                      Container(
                                                                        width: 38.0,
                                                                        height: 38.0,
                                                                        child:
                                                                        FloatingActionButton(
                                                                          onPressed: () {
                                                                            reportNoty
                                                                                .updateValue(
                                                                                new Message(
                                                                                    type: 'CLEAR_MAP'));
                                                                          },
                                                                          child: Container(
                                                                            width: 38.0,
                                                                            height: 38.0,
                                                                            child: Image
                                                                                .asset(
                                                                              'assets/images/clear_map.png',
                                                                              color: Colors
                                                                                  .white,),),
                                                                          elevation: 3.0,
                                                                          backgroundColor: Colors
                                                                              .blueAccent,
                                                                          heroTag: 'ClearMap1',
                                                                        ),
                                                                      ),
                                                                    )
                                                                        : Container(),
                                                                    showAllItemsOnMap
                                                                        ? Positioned(
                                                                      right: 20.0,
                                                                      bottom: 210.0,
                                                                      child:
                                                                      Container(
                                                                        width: 38.0,
                                                                        height: 38.0,
                                                                        child:
                                                                        FloatingActionButton(
                                                                          onPressed: () {
                                                                            showRouteCurrentToCar();
                                                                          },
                                                                          child: Container(
                                                                            width: 38.0,
                                                                            height: 38.0,
                                                                            child: Image
                                                                                .asset(
                                                                              'assets/images/go.png',
                                                                              color: Colors
                                                                                  .white,),),
                                                                          elevation: 0.0,
                                                                          backgroundColor: Colors
                                                                              .blueAccent,
                                                                          heroTag: 'GO1',
                                                                        ),
                                                                      ),
                                                                    )
                                                                        : Container(),
                                                                    showAllItemsOnMap
                                                                        ? Positioned(
                                                                      left: 20.0,
                                                                      top: 60.0,
                                                                      child:
                                                                      Container(
                                                                        width: 38.0,
                                                                        height: 38.0,
                                                                        child:
                                                                        FloatingActionButton(
                                                                          onPressed: () {

                                                                          },
                                                                          child: Container(
                                                                            width: 38.0,
                                                                            height: 38.0,
                                                                            child: isGPSOn
                                                                                ? ImageNeonGlow(
                                                                              imageUrl: 'assets/images/gps.png',
                                                                              counter: 0,
                                                                              color: Colors
                                                                                  .indigoAccent,)
                                                                                :
                                                                            Image
                                                                                .asset(
                                                                              'assets/images/gps.png',
                                                                              color: Colors
                                                                                  .white,),),
                                                                          elevation: 1.0,
                                                                          backgroundColor: Colors
                                                                              .transparent,
                                                                          heroTag: 'GPS',
                                                                        ),
                                                                      ),
                                                                    )
                                                                        : Container(),
                                                                    showAllItemsOnMap
                                                                        ? Positioned(
                                                                      left: 80.0,
                                                                      top: 60.0,
                                                                      child:
                                                                      Container(
                                                                        width: 38.0,
                                                                        height: 38.0,
                                                                        child:
                                                                        FloatingActionButton(
                                                                          onPressed: () {

                                                                          },
                                                                          child: Container(
                                                                            width: 38.0,
                                                                            height: 38.0,
                                                                            child: isGPRSOn
                                                                                ? ImageNeonGlow(
                                                                              imageUrl: 'assets/images/gprs.png',
                                                                              counter: 0,
                                                                              color: Colors
                                                                                  .indigoAccent,)
                                                                                :
                                                                            Image
                                                                                .asset(
                                                                              'assets/images/gprs.png',
                                                                              color: Colors
                                                                                  .white,),),
                                                                          elevation: 1.0,
                                                                          backgroundColor: Colors
                                                                              .transparent,
                                                                          heroTag: 'GPRS',
                                                                        ),
                                                                      ),
                                                                    )
                                                                        : Container(),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],

                                                          ),
                                                        );

                                              },
                                            );
                                        },
                                      );
                                    },
                                  );
                              }
                              else {
                                double lat = currentLocation != null
                                    ? currentLocation
                                    .latitude
                                    : 35.6917856;
                                double long = currentLocation != null
                                    ? currentLocation
                                    .longitude
                                    : 51.4204603;
                                return StreamBuilder<Message>(
                                  stream: reportNoty.noty,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      Message msg = snapshot.data;
                                      if (msg.type == 'ANIM_ROUTE') {
                                        if (forAnim) {
                                          animateRoutecarPolyLines();
                                        }
                                      }
                                      if (msg.type == 'CLEAR_MAP') {
                                        if (_timerLine != null &&
                                            _timerLine.isActive) {
                                          _timerLine.cancel();
                                        }
                                        if (_polyLineAnim != null) {
                                          forAnim = false;
                                          _polyLineAnim = null;
                                        }

                                        if (lines != null && lines.length > 0) {
                                          lines.clear();
                                        }
                                        if (markers != null &&
                                            markers.length > 0) {
                                          markers.clear();
                                        }
                                        if (lines2 != null) {
                                          lines2 = null;
                                        }
                                      }
                                    }
                                    return StreamBuilder<Message>(
                                      stream: animateNoty.noty,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          if (_fpoint != null)
                                            liveMapController.mapController
                                                .move(_fpoint, 15);
                                        }
                                        return
                                          StreamBuilder<Message>(
                                            stream: statusNoty.noty,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {

                                              }
                                              return

                                                Column(
                                                  children: [
                                                    Flexible(
                                                      child: Stack(
                                                        children: <Widget>[
                                                          FlutterMap(
                                                            options: MapOptions(
                                                              center: LatLng(
                                                                  lat, long),
                                                              zoom: 16.0,
                                                              plugins: [
                                                                UserLocationPlugin(),
                                                              ],

                                                            ),
                                                            layers: [
                                                              TileLayerOptions(

                                                                urlTemplate: 'https://api.maptiler.com/maps/hybrid/?key=2UnTxClTTOQ2d3xsUL5T#0.62/0/0',
                                                                //additionalOptions: {'key':'2UnTxClTTOQ2d3xsUL5T'},
                                                              ),
                                                                /*'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                                subdomains: [
                                                                  'a',
                                                                  'b',
                                                                  'c'
                                                                ],
                                                                additionalOptions: {
                                                                  "tileLayerJSON":'http://tileserver.maptiler.com/swissimage25m.json',
                                                                },
                                                                //tileProvider: NetworkTileProvider(),
                                                              ),
                                                              TileLayerOptions (
                                                                urlTemplate: 'http://tileserver.maptiler.com/grandcanyon/{z}/{x}/{y}.png',
                                                                subdomains: [
                                                                  'a',
                                                                  'b',
                                                                  'c'
                                                                ],
                                                              ),*/
                                                              (forAnim &&
                                                                  _polyLineAnim !=
                                                                      null)
                                                                  ? PolylineLayerOptions(
                                                                  polylines: <
                                                                      Polyline>[
                                                                    _polyLineAnim
                                                                  ])
                                                                  :
                                                              PolylineLayerOptions(
                                                                  polylines: lines) ,
                                                              /*forAnim ?  MarkerLayerOptions(
                                                    markers: <Marker>[_marker]) :*/
                                                              /* MarkerLayerOptions(
                                                    markers: markers),*/
                                                              MarkerLayerOptions(
                                                                  markers: markers),
                                                              userLocationOptions
                                                            ],
                                                            mapController: liveMapController
                                                                .mapController,
                                                          ),
                                                          Positioned(
                                                            right: 20.0,
                                                            bottom: 310.0,
                                                            child:
                                                            Container(
                                                              width: 38.0,
                                                              height: 38.0,
                                                              child:
                                                              FloatingActionButton(
                                                                onPressed: () {
                                                                  showAllItemsOnMap =
                                                                  !showAllItemsOnMap;
                                                                  showAllItemsdNoty
                                                                      .updateValue(
                                                                      new Message(
                                                                          type: 'CLEAR_ALL'));
                                                                },
                                                                child: Container(
                                                                  width: 38.0,
                                                                  height: 38.0,
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/clear_all.png',
                                                                    color: showAllItemsOnMap ? Colors
                                                                        .white : Colors.amber,),),
                                                                elevation: 0.0,
                                                                backgroundColor: Colors
                                                                    .blueAccent,
                                                                heroTag: 'CLEARALL',
                                                              ),
                                                            ),
                                                          ),
                                                          showAllItemsOnMap
                                                              ? Positioned(
                                                            right: 20.0,
                                                            bottom: 260.0,
                                                            child:
                                                            Container(
                                                              width: 38.0,
                                                              height: 38.0,
                                                              child:
                                                              FloatingActionButton(
                                                                onPressed: () {
                                                                  // liveMapController.removeMarkers();
                                                                  reportNoty
                                                                      .updateValue(
                                                                      new Message(
                                                                          type: 'CLEAR_MAP'));
                                                                },
                                                                child: Container(
                                                                  width: 38.0,
                                                                  height: 38.0,
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/clear_map.png',
                                                                    color: Colors
                                                                        .white,),),
                                                                elevation: 3.0,
                                                                backgroundColor: Colors
                                                                    .blueAccent,
                                                                heroTag: 'ClearMap2',
                                                              ),
                                                            ),
                                                          )
                                                              : Container(),
                                                          showAllItemsOnMap
                                                              ? Positioned(
                                                            right: 20.0,
                                                            bottom: 210.0,
                                                            child:
                                                            Container(
                                                                width: 38.0,
                                                                height: 38.0,
                                                                child:
                                                                FloatingActionButton(
                                                                  onPressed: () {
                                                                    showRouteCurrentToCar();
                                                                  },
                                                                  child: Container(
                                                                    width: 38.0,
                                                                    height: 38.0,
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/go.png',
                                                                      color: Colors
                                                                          .white,),),
                                                                  elevation: 0.0,
                                                                  backgroundColor: Colors
                                                                      .blueAccent,
                                                                  heroTag: 'GO2',
                                                                )
                                                            ),
                                                          )
                                                              : Container(),
                                                          showAllItemsOnMap
                                                              ? Positioned(
                                                            left: 20.0,
                                                            top: 60.0,
                                                            child:
                                                            Container(
                                                              width: 38.0,
                                                              height: 38.0,
                                                              child:
                                                              FloatingActionButton(
                                                                onPressed: () {

                                                                },
                                                                child: Container(
                                                                  width: 38.0,
                                                                  height: 38.0,
                                                                  child: isGPSOn
                                                                      ? ImageNeonGlow(
                                                                    imageUrl: 'assets/images/gps.png',
                                                                    counter: 0,
                                                                    color: Colors
                                                                        .indigoAccent,)
                                                                      :
                                                                  Image.asset(
                                                                    'assets/images/gps.png',
                                                                    color: Colors
                                                                        .white,),),
                                                                elevation: 1.0,
                                                                backgroundColor: Colors
                                                                    .transparent,
                                                                heroTag: 'GPS',
                                                              ),
                                                            ),
                                                          )
                                                              : Container(),
                                                          showAllItemsOnMap
                                                              ? Positioned(
                                                            left: 80.0,
                                                            top: 60.0,
                                                            child:
                                                            Container(
                                                              width: 38.0,
                                                              height: 38.0,
                                                              child:
                                                              FloatingActionButton(
                                                                onPressed: () {

                                                                },
                                                                child: Container(
                                                                  width: 38.0,
                                                                  height: 38.0,
                                                                  child: isGPRSOn
                                                                      ? ImageNeonGlow(
                                                                    imageUrl: 'assets/images/gprs.png',
                                                                    counter: 0,
                                                                    color: Colors
                                                                        .indigoAccent,)
                                                                      :
                                                                  Image
                                                                      .asset(
                                                                    'assets/images/gprs.png',
                                                                    color: Colors
                                                                        .white,),),
                                                                elevation: 1.0,
                                                                backgroundColor: Colors
                                                                    .transparent,
                                                                heroTag: 'GPRS',
                                                              ),
                                                            ),
                                                          )
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  ],

                                                );
                                            },
                                          );
                                      },
                                    );
                                  },
                                );
                              }
                            }
                          // ),
                        ),

                      ],
                    ),
                    elevation: 0,
                    floatingAppBar: true,
                    floatAppbar:
                    Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment(1, -1),
                          child:
                          Container(
                            height: 70.0,
                            child:
                            AppBar(
                              automaticallyImplyLeading: true,
                              backgroundColor: Colors.transparent,
                              elevation: 0.0,
                              actions: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.arrow_forward,
                                    color: Colors.indigoAccent,),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/home');
                                  },
                                ),
                              ],
                              leading: null, /*IconButton(
                              icon: Icon(Icons.menu,
                                color: Colors.indigoAccent,),
                              onPressed: () {
                                _scaffoldKey.currentState.openDrawer();
                              },
                            ),*/
                            ),
                          ),
                        ),
                        showAllItemsOnMap ? Padding(
                          padding: EdgeInsets.only(top: 80.0),
                          child:
                          Container(
                            color: Colors.transparent,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width - 10,
                            height: 110.0,
                            child:
                            PageTransformer(
                              pageViewBuilder: (context, visibilityResolver) {
                                return
                                  PageView.builder(
                                    physics: BouncingScrollPhysics(),
                                    controller: PageController(
                                      viewportFraction: 0.5,),
                                    itemCount: parallaxCardItemsList.length,
                                    itemBuilder: (context, index) {
                                      final item = parallaxCardItemsList[index];
                                      final pageVisibility =
                                      visibilityResolver.resolvePageVisibility(
                                          index);
                                      return GestureDetector(
                                        onTap: () {
                                          navigateToCarSelected(
                                              index, false, 0);
                                        },
                                        child:
                                        Container(
                                          color: Colors.white.withOpacity(0.0),
                                          width: 200.0,
                                          height: 100.0,
                                          child: ParallaxCardsWidget(
                                            item: item,
                                            pageVisibility: pageVisibility,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                              },
                            ),
                          ),
                        ) : Container(),
                      ],),
                    appBar: null /*AppBar(
                      shape: kAppbarShape,
                      actions: <Widget>[
                      ],
                      leading: IconButton(
                        icon: Icon(
                          EvaIcons.person,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () {},
                      ),
                      title: Text(
                        'خودروهای تعریف شده',
                        style: TextStyle(color: Colors.black),
                      ),
                      centerTitle: true,
                      backgroundColor: Colors.white,
                    )*/,
                    navBarColor: Colors.white,
                    navBarIconColor: Colors.blueAccent,
                    moreButtons: [
                      MoreButtonModel(
                        icon: MaterialCommunityIcons.account_question,
                        label: 'درخواست ها',
                        onTap: () {
                          showLastCarJoint(context);
                        },
                      ),
                      MoreButtonModel(
                        icon: MaterialCommunityIcons.parking,
                        label: 'مسیر طی شده',
                        onTap: () {
                          showCarRoute();
                        },
                      ),
                      MoreButtonModel(
                        icon: FontAwesome.book,
                        label: 'گزارش مسیر',
                        onTap: () {
                          _showReportSheet(context);
                        },
                      ),

                      MoreButtonModel(
                        icon: MaterialCommunityIcons.help_circle_outline,
                        label: 'راهنما',
                        onTap: () {
                          _showMapGuid(context);
                        },
                      ),

                      null,
                      /*MoreButtonModel(
              icon: MaterialCommunityIcons.home_map_marker,
              label: 'ارسال پیام',
              onTap: () {},
            ),*/
                      null,
                      /*MoreButtonModel(
              icon: FontAwesome5Regular.user_circle,
              label: 'گروه خودروها',
              onTap: () {},
            ),*/
                      null,
                      null,
                      /*MoreButtonModel(
              icon: EvaIcons.settings,
              label: 'تنظیمات',
              onTap: () {},
            ),*/
                      null,
                    ],
                    searchWidget: Container(
                      width: 350.0,
                      height: 300,
                      child:
                      Stack(
                        children: <Widget>[
                          new ListView (
                            physics: BouncingScrollPhysics(),
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                //margin: EdgeInsets.symmetric(horizontal: 20.0),
                                children: <Widget>[
                                  SizedBox(
                                    height: 0,
                                  ),
                                  /* FlatButton(
                          onPressed: (){ showLastCarJoint(context);},
                          child: Button(color: Colors.blueAccent.value,wid: 220,title: Translations.current.carJoindBefore(),),
                        ),*/
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.70,
                                    child:
                                    Form(
                                      key: _formKey2,
                                      autovalidate: _autoValidate,
                                      child:
                                      SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        physics: BouncingScrollPhysics(),
                                        child: new Column(
                                          children: <Widget>[

                                            Container(
                                              //height: 45,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 2.0),
                                              child:
                                              FormBuilderTextField(
                                                initialValue: '',
                                                attribute: "CarId",
                                                decoration: InputDecoration(
                                                  errorStyle: TextStyle(color: Colors.pinkAccent),
                                                  labelText: Translations
                                                      .current
                                                      .carId(),
                                                ),
                                                onChanged: (value) =>
                                                    _onCarIdChanged(value),
                                                valueTransformer: (text) =>
                                                    num.tryParse(text),
                                               // autovalidate: true,
                                                validators: [
                                                  FormBuilderValidators
                                                      .required(),
                                                  FormBuilderValidators
                                                      .numeric(),
                                                  FormBuilderValidators.maxLength(20),
                                                ],
                                                keyboardType: TextInputType
                                                    .number,
                                              ),

                                            ),
                                            Container(
                                              // height: 45,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 2.0),
                                              child:
                                              FormBuilderTextField(
                                                initialValue: '',
                                                attribute: "SerialNumber",
                                                decoration: InputDecoration(
                                                  errorStyle: TextStyle(color: Colors.pinkAccent),
                                                  labelText: Translations
                                                      .current
                                                      .serialNumber(),
                                                ),
                                                onChanged: (value) =>
                                                    _onMobileChanged(value),
                                                valueTransformer: (
                                                    text) => text,
                                                validators:[],
                                                keyboardType: TextInputType.text,
                                              ),
                                            ),
                                            Container(
                                              // height: 45,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 2.0),
                                              child:
                                              FormBuilderTextField(
                                                initialValue: '',
                                                attribute: "Pelak",
                                                inputFormatters: [
                                                  BlacklistingTextInputFormatter(
                                                      RegExp(
                                                          "[,@#%^&*()+=!.`~\"';:?؟و/\\\\]"))
                                                ],
                                                decoration: InputDecoration(
                                                  errorStyle: TextStyle(color: Colors.pinkAccent),
                                                  labelText: Translations
                                                      .current
                                                      .carpelak(),
                                                ),
                                                onChanged: (value) =>
                                                    _onPelakChanged(value),
                                                valueTransformer: (
                                                    text) => text,
                                                validators: [],
                                                // keyboardType: TextInputType.text,
                                              ),
                                            ),


                                            new GestureDetector(
                                              onTap: () {
                                               // _formKey2.currentState.save();
                                                if(_formKey2.currentState.validate())
                                                    searchCar();
                                              },
                                              child:
                                              Container(

                                                child:
                                                new SendData(),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),


                        ],
                      ),
                    ),
                    // onTap: (button) {},
                    // currentBottomBarCenterPercent: (currentBottomBarParallexPercent) {},
                    // currentBottomBarMorePercent: (currentBottomBarMorePercent) {},
                    // currentBottomBarSearchPercent: (currentBottomBarSearchPercent) {},
                    parallexCardPageTransformer: PageTransformer(
                      pageViewBuilder: (context, visibilityResolver) {
                        return
                          PageView.builder(
                            controller: PageController(viewportFraction: 0.50),
                            itemCount: carPairedItemsList.length,
                            itemBuilder: (context, index) {
                              final item = carPairedItemsList[index];
                              final pageVisibility =
                              visibilityResolver.resolvePageVisibility(index);
                              return GestureDetector(
                                child:
                                Container(
                                  color: Colors.white.withOpacity(0.0),
                                  width: 200.0,
                                  height: 130.0,
                                  child: ParallaxCardsWidget(
                                    item: item,
                                    pageVisibility: pageVisibility,
                                  ),
                                ),
                                onTap: () {
                                  _showCarPairedActions(
                                      carsSlavePairedList[index], context);
                                },
                              );
                            },
                          );
                      },
                    ),
                  );
              },
                );
            }
            else {
              return NoDataWidget();
            }
          },
        );
    },
    );
 // },
 // );




  }


  void addGeoMarkerFromCurrentPosition() async {
    GeoPoint gp = await geoPointFromLocation(name: "Current position");
    Marker m = Marker(
        width: 180.0,
        height: 250.0,
        point: gp.point,
        builder: (BuildContext context) {
          return Icon(Icons.location_on);
        });
    await liveMapController.addMarker(marker: m, name: "Current position");
    await liveMapController.fitMarker("Current position");
  }

  void addGeoMarkerFromPosition(LatLng pos) async {
    GeoPoint gp = await  geoPointFromLocation(name: "Current position");
    Marker m = Marker(
        width: 180.0,
        height: 250.0,
        point: gp.point,
        builder: (BuildContext context) {
          return Icon(Icons.location_on);
        });
    await liveMapController.addMarker(marker: m, name: "Current position");
    await liveMapController.fitMarker("Current position");
  }

}
