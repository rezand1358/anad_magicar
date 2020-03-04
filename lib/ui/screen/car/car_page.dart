import 'package:anad_magicar/bloc/car/confirm/confirm_car.dart';
import 'package:anad_magicar/bloc/values/notify_value.dart';
import 'package:anad_magicar/common/constants.dart';
import 'package:anad_magicar/components/button.dart';
import 'package:anad_magicar/components/no_data_widget.dart';
import 'package:anad_magicar/data/ds/car_ds.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/data/rxbus.dart';
import 'package:anad_magicar/model/apis/api_brand_model.dart';
import 'package:anad_magicar/model/apis/api_car_model.dart';
import 'package:anad_magicar/model/apis/api_carmodel_model.dart';
import 'package:anad_magicar/model/apis/api_related_user_model.dart';
import 'package:anad_magicar/model/apis/service_result.dart';
import 'package:anad_magicar/model/cars/car.dart';
import 'package:anad_magicar/model/cars/car_model.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/model/message.dart';
import 'package:anad_magicar/model/user/admin_car.dart';
import 'package:anad_magicar/model/viewmodel/add_car_vm.dart';
import 'package:anad_magicar/model/viewmodel/car_info_vm.dart';
import 'package:anad_magicar/model/viewmodel/car_page_vm.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/ui/factory/car/factory_car.dart';
import 'package:anad_magicar/ui/screen/base/main_page.dart';
import 'package:anad_magicar/ui/screen/car/fancy_car/src/widgets/animated_text_form_field.dart';
import 'package:anad_magicar/ui/screen/car/role_sheet.dart';
import 'package:anad_magicar/utils/dart_helper.dart';
import 'package:anad_magicar/widgets/bottom_sheet_custom.dart';
import 'package:anad_magicar/widgets/curved_navigation_bar.dart';
import 'package:anad_magicar/widgets/flutter_offline/flutter_offline.dart';
import 'package:anad_magicar/widgets/magicar_appbar.dart';
import 'package:anad_magicar/widgets/magicar_appbar_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:anad_magicar/widgets/animated_dialog_box.dart';
class CarPage extends StatefulWidget {

  CarPageVM carPageVM;

  CarPage({Key key,
    this.carPageVM}) : super(key: key) ;

  @override
  CarPageState createState() {
    return CarPageState();
  }
}

class CarPageState extends MainPage<CarPage> {

  static final route='/carpage';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _carCounts=0;
  bool hasInternet=true;
  Future<int> carCounts;
  CarDS carDS;
  Future<List<AdminCarModel>> carsToUser;
  List<AdminCarModel> carsToUserSelf;
  List<AdminCarModel> carsToUserForConfirm;
  ConfirmCarBloc confirmCarBloc;
  List<CarInfoVM> carInfos=new List();
  NotyBloc<Message> carChangedNoty;


  void registerBus() {
    RxBus.register<ChangeEvent>().listen((ChangeEvent event)  {

      if(event.type=='CAR_ADDED')
      {

          if(widget.carPageVM!=null &&
              widget.carPageVM.isSelf!=null && !widget.carPageVM.isSelf)
            carsToUser=factoryCar.loadCarsToUserByUserId(widget.carPageVM.userId);
          else{
            carCounts = getCarInfo();
          }
          carChangedNoty.updateValue(new Message(type: 'CAR_ADDED'));

      }


    });
  }

 Future<int> getCarInfo() async {

   centerRepository.showProgressDialog(context, Translations.current.loadingdata());

   carsToUserSelf = await carDS.getAllCarsByUserId(userId);
   if (carsToUserSelf != null) {
     _carCounts=carsToUserSelf.length;
     fillCarInfo(carsToUserSelf);
     centerRepository.setCarsToAdmin(carsToUserSelf);
     prefRepository.setCarsCount(carsToUserSelf.length);
   }
   else {
     prefRepository.setCarsCount(0);
   }
    if(_carCounts==0) {

        if(centerRepository.getCarsToAdmin()!=null)
          _carCounts=centerRepository.getCarsToAdmin().length;
        fillCarInfo(carsToUserSelf);
      }

    return _carCounts;
  }

  fillCarInfo(List<AdminCarModel> carsToUser)
  {
    carInfos = new List();
    for (var car in carsToUser) {
      Car car_info = centerRepository
          .getCars()
          .where((c) => c.carId == car.CarId)
          .toList()
          .first;
      if (car_info != null) {
        int tip=0;
        int modelId=0;
        int brandId=0;
        if(centerRepository.getCarBrands()!=null)
          {
           // tip=centerRepository.getCarBrands().where((d)=>d.brandId==car_info. )
          }
        if(centerRepository.getCarModelDetails()!=null && centerRepository.getCarModelDetails().length>0) {
          var modelDetail = centerRepository.getCarModelDetails().where((c) =>
          c.carModelDetailId == car_info.carModelDetailId).toList();
          if (modelDetail != null && modelDetail.length > 0) {
              modelId=modelDetail.first.carModelId;
              if(centerRepository.getCarBrands()!=null && centerRepository.getCarBrands().length>0) {
                var model = centerRepository.getCarModels().where((c) =>
                c.carModelId == modelId).toList();
                if (model != null && model.length > 0) {
                  var brand = centerRepository.getCarBrands().where((c) =>
                  c.brandId == model.first.brandId).toList();
                  if(brand!=null && brand.length>0){
                    brandId=brand.first.brandId;
                  }
                }
              }
          }
        }
        SaveCarModel editModel=new SaveCarModel(
            carId: car_info.carId,
            brandId:brandId,
            modelId: modelId,
            tip: car_info.carModelDetailId,
            pelak: car_info.pelaueNumber,
            colorId: car_info.colorTypeConstId,
            distance: car_info.totlaDistance,
            ConstantId: null,
            DisplayName: null);

        CarInfoVM carInfoVM = new CarInfoVM(
          colorId: car_info.colorTypeConstId,
          brandId: brandId,
            moddelId: modelId,
            modelDetailId: car_info.carModelDetailId,
            brandModel: null,
            car: car_info,
            carColor: null,
            carModel: null,
            isActive: car.IsActive,
            pelak: car_info.pelaueNumber,
            distance: car_info.totlaDistance.toString(),
            carModelDetail: null,
            brandTitle: car_info.brandTitle,
            modelTitle: car_info.carModelTitle,
            modelDetailTitle: car_info.carModelDetailTitle,
            color: car_info.colorTitle,
        carId: car_info.carId,
        Description: car_info.description,
        fromDate: car.FromDate,
        CarToUserStatusConstId: car.CarToUserStatusConstId,
        isAdmin: car.IsAdmin,
        userId: car.UserId);
        carInfos.add(carInfoVM);
      }
    }
  }

  _deleteCarToUser(int userId,int carId,CarInfoVM car) async{
   ServiceResult result=await restDatasource.deletecarToUser(userId, carId);
   if(result!=null) {
       centerRepository.showFancyToast(result.Message);
     }
   else
     {
       centerRepository.showFancyToast(Translations.current.hasErrors());
     }
  }
  _deleteCars(int carId,) async{
    await animated_dialog_box.showScaleAlertBox(
        title:Center(child: Text(Translations.current.confimDelete())) ,
        context: context,
        firstButton: MaterialButton(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          color: Colors.white,
          child: Text(Translations.current.yes()),
          onPressed: () async {
            onConfirmDelete(carId);
          }
        ),
        secondButton: MaterialButton(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          color: Colors.white,
          child: Text(Translations.current.no()),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        icon: Icon(Icons.info_outline,color: Colors.red,),
        yourWidget: Container(
          child: Text(Translations.current.areYouSureToDelete()),
        ));

  }

  Future<void> onConfirmDelete(int carId) async {
    List<int> cars=new List();
    cars..add(carId);
    ServiceResult result=await restDatasource.deleteCars( cars);
    if(result!=null) {
      centerRepository.showFancyToast(result.Message);
      if(result.IsSuccessful) {
        carInfos.removeWhere((r) => r.carId == carId);
        carChangedNoty.updateValue(new Message(type: 'CAR_DELETED'));
      }
      else{
      }
    }
    else
    {
      centerRepository.showFancyToast(Translations.current.hasErrors());
    }
    Navigator.pop(context);
    return Future.value(0);
  }
  _addCar(SaveCarModel editModel,int userId, bool edit) {

    Navigator.of(context).pushReplacementNamed('/addcar',
        arguments: new AddCarVM(
        fromMainApp: true,
        editMode: edit,
        editCarModel: editModel,
        addNotyBloc: carChangedNoty,
        notyBloc: widget.carPageVM.carAddNoty));
  }

  _showBottomSheetAcceptRole(BuildContext cntext,int carId,int userId)
  {
    showModalBottomSheetCustom(context: cntext ,
        builder: (BuildContext context) {
          return new ChangeRoleSheet(
            user: null,
            userId: userId,
            changeRole: (userId,roleId) {
              confirmCarBloc.add(new LoadConfirmCarEvent(
                  userId,
                  carId,
                  roleId,
                  context,
                  Constants.CAR_TO_USER_STATUS_CONFIRMED_TAG));
            },
          ) ;
        });
  }

  _showBottomSheetEditCarInfo(
      BuildContext cntext,
      SaveCarModel editModel,
      int carId,
      int userId) {

   _addCar(editModel,userId,true);

  }

  List<Widget> getCarsTiles(List<CarInfoVM> cars) {
    List<Widget> list = [];
    if (cars != null) {
      for (CarInfoVM c in cars) {
        //Car car=centerRepository.getCars().where((cr)=>cr.carId==c.CarId).toList().first;
        String name = DartHelper.isNullOrEmptyString(c.brandTitle);
        String desc=DartHelper.isNullOrEmptyString(c.Description);
        String carId=c.carId.toString();
        String modelTitle=DartHelper.isNullOrEmptyString(c.modelTitle);
        String detailTitle=DartHelper.isNullOrEmptyString(c.modelDetailTitle);
        String fromDate=DartHelper.isNullOrEmptyString( c.fromDate);
        String pelak=DartHelper.isNullOrEmptyString(c.pelak);
        String colortitle=DartHelper.isNullOrEmptyString(c.color);
        bool isAdmin=c.isAdmin;
        int statusId=c.CarToUserStatusConstId;
        bool active=c.isActive;
        list.add(
          Container(
            margin: EdgeInsets.only(bottom: 2.0),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                border:Border.all(color: Colors.black38.withOpacity(0.1),width: 0.5)
            ),
            child:
              Column(
                children: <Widget>[
            ListTile(
          title:Card(
            color: Colors.black12.withOpacity(0.0),
            margin: new EdgeInsets.only(
                left: 2.0, right: 2.0, top: 5.0, bottom: 5.0),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white,width: 0.0),
              borderRadius: new BorderRadius.all(Radius.circular(5.0)),
            ),
           // color: Color(0xfffefefe),
            elevation: 0.0,
            child:
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
              padding:  EdgeInsets.only(right: 0.0),
                      child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 5.0,left: 5.0),
                        child:
                        Text( Translations.current.carId(),style: TextStyle(fontSize: 18.0)),
                        ),
              Padding(
                padding: EdgeInsets.only(right: 5.0,left: 5.0),
                child:
                 Text( carId,style: TextStyle(fontSize: 20.0)),),
                      ],
                    ),
                    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
    Padding(
    padding: EdgeInsets.only(right: 5.0,left: 5.0),
    child:
                    Text(Translations.current.carTitle(),style: TextStyle(fontSize: 18.0)),
    ),
    Padding(
    padding: EdgeInsets.only(right: 5.0,left: 5.0),
    child:
                    Text(name ,style: TextStyle(fontSize: 18.0)),
    ),
          ],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
    Padding(
    padding: EdgeInsets.only(right: 5.0,left: 5.0),
    child:
          Text(Translations.current.carModelTitle(),style: TextStyle(fontSize: 18.0)),
    ),
    Padding(
    padding: EdgeInsets.only(right: 5.0,left: 5.0),
    child:
          Text(modelTitle ,style: TextStyle(fontSize: 18.0)),
    ),
          ],
    ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
    Padding(
    padding: EdgeInsets.only(right: 5.0,left: 5.0),
    child:
            Text(Translations.current.carModelDetailTitle(),style: TextStyle(fontSize: 18.0)),
    ),
    Padding(
    padding: EdgeInsets.only(right: 5.0,left: 5.0),
    child:
              Text(detailTitle ,style: TextStyle(fontSize: 18.0)),
    ),
            ],
          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 5.0,left: 5.0),
                          child:
                          Text(Translations.current.carcolor(),style: TextStyle(fontSize: 18.0)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0,left: 5.0),
                          child:
                          Text(colortitle ,style: TextStyle(fontSize: 18.0)),
                        ),
                      ],
                    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
    Padding(
    padding: EdgeInsets.only(right: 5.0,left: 5.0),
    child:
            Text(Translations.current.startDate() ,style: TextStyle(fontSize: 18.0)),
    ),
    Padding(
    padding: EdgeInsets.only(right: 5.0,left: 5.0),
    child:
            Text(fromDate,style: TextStyle(fontSize: 18.0), ),
    ),
    ],
    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 5.0,left: 5.0),
                          child:
                          Text(Translations.current.carpelak() ,style: TextStyle(fontSize: 18.0)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0,left: 5.0),
                          child:
                          Text(pelak,style: TextStyle(fontSize: 18.0), ),
                        ),
                      ],
                    ),
                  ],
                ),
          ),
          subtitle: Text(  Translations.current.description()+' : '+ DartHelper.isNullOrEmptyString( desc)),
          trailing: Container(width: 0.0,height: 0.0,)
        ),
                  Container(
                    height: 48.0,
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FlatButton(
                          padding: EdgeInsets.only(left: 0, right: 0),
                          child: Button(title: Translations.current.edit(),wid: 80.0,clr: Colors.blueAccent,),
                    onPressed: () {
                      if(isAdmin) {

                        SaveCarModel editModel=new SaveCarModel(userId: c.userId, carId: c.carId,
                            brandId: c.brandId, modelId: c.moddelId, tip: c.modelDetailId,
                            pelak: c.pelak, colorId:c.colorId , distance: int.tryParse(c.distance), ConstantId: null, DisplayName: null);
                        _showBottomSheetEditCarInfo(context, editModel, c.carId,c.userId);
                      }
                    },
                  ) ,
                        ((isAdmin && statusId==Constants.CAR_TO_USER_STATUS_WAITING_TAG ) || (!active) ) ?  FlatButton (
                          padding: EdgeInsets.only(left: 0, right: 0),
                          child: Button(title: Translations.current.activateCar(),wid: 80.0,color: Colors.greenAccent.value,),
                          onPressed: () {
                            if(isAdmin) {
                             _showBottomSheetAcceptRole(context, c.carId,c.userId);
                            }
                          },
                        ) :
                        Container(width: 0.0,height: 0.0,),
                        ( (isAdmin && statusId==Constants.CAR_TO_USER_STATUS_WAITING_TAG ) || (!active))?  FlatButton(
                          padding: EdgeInsets.only(left: 0, right: 0),
                          child: Button(title: Translations.current.denyRequest(),wid: 50.0,color: Colors.greenAccent.value,),
                          onPressed: () {
                            if(isAdmin) {
                              _deleteCarToUser(c.userId,c.carId,c);
                            }
                          },
                        ) :
                        Container(width: 0.0,height: 0.0,),
                        isAdmin ?   FlatButton(
                          padding: EdgeInsets.only(left: 0, right: 0),
                          child: Button(title: Translations.current.delete(),wid: 50.0,clr: Colors.pinkAccent,),
                          onPressed: () {
                            _deleteCars( c.carId);
                          },
                        ) :
                        Container(width: 0.0,height: 0.0,)
                      ],
                    ),
                  ),
    ],
              ),
          ),
    );
      }
    }
    return list;
  }

  Widget createBody(List<CarInfoVM> cars,
      bool connection)
  {
    return
      Stack(
      overflow: Overflow.visible,
      children: <Widget> [
        new Card(
          margin: EdgeInsets.symmetric(vertical: 65.0, horizontal: 1.0),
          color: Colors.white30,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            //side: BorderSide(width: 0.5,color: Colors.black54),
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(70.0),
                bottomLeft: Radius.circular(3.0) ),
          ),
          child: cars!=null &&
              cars.length > 0 ? new Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 0.0,
              left: 2.0,
            ),
            child:
            Container(
              padding: EdgeInsets.all(1),
              child:
              Column(children: [
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          leading: Text(Translations.current.car(),
                              style: Theme.of(context).textTheme.subhead),
                          trailing: Text(_carCounts.toString(),
                              style:
                              Theme.of(context).textTheme.headline),
                          onTap: () {
                            /*Navigator.of(context).pushNamed('/addcar',arguments: new AddCarVM(notyBloc : null,
                                fromMainApp: true));*/
                          },

                        ),

                      ),

                       Card(
                         margin: EdgeInsets.only(bottom: 2.0),
                            elevation: 0.0,
                             child:
                        ExpansionTile(
                          initiallyExpanded: true,
                            title: Text(Translations.current.carsNo()+ " ( " +
                                _carCounts.toString() +
                                " ) "),
                            children: getCarsTiles(cars)),
                      ) /*: Card(
                        child: ExpansionTile(
                            title: Text(Translations.current.carsNo()+ " ( " +
                                _carCounts.toString() +
                                " ) "),
                            children: getCarsTiles(cars)),
                      ),*/

                    ],
                  ),
                ),
              ],
              ),
            ),
          ) :
          NoDataWidget(),
        ),

      ],
    );
  }

  @override
  void dispose() {
    carChangedNoty.dispose();
    confirmCarBloc.close();
    super.dispose();
  }


  @override
  String getCurrentRoute() {
    return route;
  }

  @override
  initialize() {
    confirmCarBloc=new ConfirmCarBloc();
    carDS=new CarDS();
    carChangedNoty=new NotyBloc<Message>();
    if(widget.carPageVM!=null &&
        widget.carPageVM.isSelf!=null && !widget.carPageVM.isSelf)
      carsToUser=factoryCar.loadCarsToUserByUserId(widget.carPageVM.userId);
    else{
      carCounts = getCarInfo();
    }
    registerBus();
    return null;
  }

  @override
  Widget pageContent() {

    return
      BlocBuilder<ConfirmCarBloc, ConfirmCarState>(
          bloc: confirmCarBloc,
          builder: (
              BuildContext context,
              ConfirmCarState currentState,)
          {
            if(currentState is LoadConfirmCarState)
            {
              centerRepository.showProgressDialog(context, Translations.current.loadingdata());
            }
            if(currentState is ConfirmedCarState)
            {
              centerRepository.dismissDialog(context);
              centerRepository.showSnackLogin(_scaffoldKey,
                  context,
                  Translations.current.confirmCarSuccessful(),
                  false);
            }
            return StreamBuilder<Message>(
              initialData: new Message(type: 'CAR_ADDED'),
                stream: carChangedNoty.noty,
                builder: (context,snapshot){
                  if(snapshot.hasData && snapshot.data!=null){
                    _carCounts=carInfos.length;
                    Message msg=snapshot.data;
                   // if(msg.type=='CAR_ADDED'){
                      centerRepository.dismissDialog(context);
                      if(widget.carPageVM!=null &&
                          widget.carPageVM.isSelf!=null && !widget.carPageVM.isSelf) {
                        carsToUser = factoryCar.loadCarsToUserByUserId(
                            widget.carPageVM.userId);
                        carCounts = getCarInfo();
                       // fillCarInfo(carsToUserSelf);
                      }
                      else {
                        carCounts = getCarInfo();
                      }
                   //}
                    if(msg.type=='CAR_DELETED'){

                    }
                  }
                  return
              (widget.carPageVM == null ||
                  widget.carPageVM.isSelf == null ||
                  widget.carPageVM.isSelf) ? FutureBuilder<int>(
                  future: carCounts,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      centerRepository.dismissDialog(context);
                      carsToUserSelf = centerRepository.getCarsToAdmin();
                      fillCarInfo(carsToUserSelf);
                      _carCounts = snapshot.data;
                    }

                        return createBody(carInfos, hasInternet);
                      }

              ) :
              FutureBuilder<List<AdminCarModel>>(
                  future: carsToUser,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      centerRepository.dismissDialog(context);
                      carsToUserSelf = snapshot.data;
                      if (carsToUserSelf != null &&
                          carsToUserSelf.length > 0) {
                        carsToUserForConfirm =
                            carsToUserSelf
                                .where((c) =>
                            c.CarToUserStatusConstId ==
                                Constants.CAR_TO_USER_STATUS_WAITING_TAG)
                                .toList();
                        fillCarInfo(carsToUserForConfirm);
                      }
                      _carCounts = carsToUserForConfirm.length;
                    }

                    return createBody(carInfos, hasInternet);
                  }
                    );
          }

    );
  });
            }

  @override
  FloatingActionButton getFab() {
    // TODO: implement getFab
    return  FloatingActionButton(
      onPressed: (){_addCar(null, 0, false);},
      child: Icon(Icons.add,size: 20.0,color: Colors.white,),
      elevation: 0.0,
      backgroundColor: Colors.blueAccent,
    );
  }

  @override
  List<Widget> actionIcons() {
    // TODO: implement actionIcons
    return null;
  }

  @override
  int setCurrentTab() {
    // TODO: implement setCurrentTab
    return 2;
  }


}
