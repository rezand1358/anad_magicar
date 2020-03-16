import 'package:anad_magicar/bloc/values/notify_value.dart';
import 'package:anad_magicar/components/button.dart';
import 'package:anad_magicar/components/no_data_widget.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/model/apis/api_service.dart';
import 'package:anad_magicar/model/apis/service_type.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/model/viewmodel/reg_service_type_vm.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/ui/screen/base/main_page.dart';
import 'package:anad_magicar/ui/screen/service/service_item.dart';
import 'package:anad_magicar/ui/screen/service/service_type/register_service_type_page.dart';
import 'package:anad_magicar/ui/screen/service/service_type/service_type_item.dart';
import 'package:anad_magicar/utils/date_utils.dart';
import 'package:anad_magicar/widgets/bottom_sheet_custom.dart';
import 'package:flutter/material.dart';



class ServiceTypePage extends StatefulWidget {
  int carId;
  ServiceTypePage({Key key,this.carId}) : super(key: key);


  @override
  ServiceTypePageState createState() {
    return ServiceTypePageState();
  }
}

class ServiceTypePageState extends MainPage<ServiceTypePage> {

  static final String route='/servicetypepage';

  String serviceDate='';
  String alarmDate='';

  Future<List<ServiceType>>  fServices;
  List<ServiceType> servcies=new List();

  NotyBloc<ChangeEvent> notyDateBloc;
  Future<List<ServiceType>> loadCarServiceTypes() async {
    centerRepository.showProgressDialog(context, '');
    var result=await restDatasource.getCarServiceTypes();
    if(result!=null && result.length>0)
      return result;
    return null;
  }


  _showBottomSheetPlans(BuildContext cntext)
  {
    showModalBottomSheetCustom(context: cntext ,
        mHeight: 0.40,
        builder: (BuildContext context) {
          return StreamBuilder<ChangeEvent>(
            initialData: new ChangeEvent(
                fromDate:DateTimeUtils.getDateJalali(),
                toDate: DateTimeUtils.getDateJalali()),
            stream: notyDateBloc.noty ,
            builder: (context,snapshot) {
              if(snapshot.hasData && snapshot.data!=null) {
                var data = snapshot.data;
                serviceDate = data.fromDate;
                alarmDate = data.toDate;
              }
              return
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Button(wid: 120.0,color: Colors.indigoAccent.value,title: (serviceDate==null || serviceDate.isEmpty) ? Translations.current.serviceDate() : serviceDate,),
                          onPressed: (){
                          serviceDate= centerRepository.showFilterDate(context, true);
                          notyDateBloc.updateValue(new ChangeEvent(fromDate: serviceDate));
                          },
                        ),
                        FlatButton(
                          child: Button(wid: 120.0,color: Colors.indigoAccent.value,title: (alarmDate==null || alarmDate.isEmpty) ? Translations.current.alarmDate() : alarmDate,),
                          onPressed: (){
                            alarmDate= centerRepository.showFilterDate(context, false);
                            notyDateBloc.updateValue(new ChangeEvent(toDate: alarmDate));
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Button(wid: 140.0,color: Colors.pinkAccent.value,title: Translations.current.confirm(),),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Button(wid: 140.0,color: Colors.pinkAccent.value,title: Translations.current.confirm(),),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    )
                  ],
                );
            },
          );
        });
  }

  addServiceType() async {
    Navigator.pushNamed(context, RegisterServicePageTypeState.route,arguments: new RegServiceTypeVM(carId: widget.carId, route: route));
  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  String getCurrentRoute() {
    return route;
  }

  @override
  FloatingActionButton getFab() {
    return FloatingActionButton(
      onPressed: (){ addServiceType(); },
      child: Icon(Icons.add,color: Colors.white,
      size: 30.0,),
      backgroundColor: Colors.blueAccent,
      elevation: 0.0,

    );
  }

  @override
  initialize() {
    fServices=loadCarServiceTypes();
    return null;
  }

  @override
  Widget pageContent() {
    // TODO: implement pageContent
    return FutureBuilder<List<ServiceType>>(
      future: fServices,
      builder: (context,snapshot) {
        if(snapshot.hasData && snapshot.data!=null) {
          centerRepository.dismissDialog(context);
          servcies=snapshot.data;
          return
          new Padding(padding: EdgeInsets.only(top: 80.0),
            child:
            Container(
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: servcies.length,
                  itemBuilder: (context, index) {
                    return ServiceTypeItem(serviceItem: servcies[index]);
                  }),
            ),
            );
        }
        else {
          return NoDataWidget();
        }
    },
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
    return 0;
  }
}
