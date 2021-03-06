import 'package:anad_magicar/bloc/values/notify_value.dart';
import 'package:anad_magicar/common/constants.dart';
import 'package:anad_magicar/components/button.dart';
import 'package:anad_magicar/components/no_data_widget.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/data/rxbus.dart';
import 'package:anad_magicar/model/apis/api_service.dart';
import 'package:anad_magicar/model/apis/service_type.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/model/message.dart';
import 'package:anad_magicar/model/viewmodel/service_vm.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/ui/screen/service/service_form.dart';

import 'package:flutter/material.dart';

import '../../../translation_strings.dart';

class ServicePage extends StatefulWidget {
  int carId;
  ServiceVM serviceVM;
  NotyBloc<Message> filterNoty;
  ServicePage({Key key,this.carId,this.serviceVM,this.filterNoty}) : super(key: key);


  @override
  ServicePageState createState() {
    return ServicePageState();
  }
}

class ServicePageState extends State<ServicePage>  with AutomaticKeepAliveClientMixin{


  String serviceDate='';
  String alarmDate='';

  Future<List<ApiService>>  fServices;
  List<ApiService> servcies=new List();
  List<ServiceType> servcieTypes=new List();

  NotyBloc<ChangeEvent> notyDateBloc;
  void registerBus() {
    RxBus.register<ChangeEvent>().listen((ChangeEvent event)  {

      if(event.type=='SERVICE')
      {
          if(event.message=='DELETED'){
            fServices=loadCarServices(widget.serviceVM.carId);
          }
      }


    });
  }
  Future<List<ApiService>> loadCarServices(int carId) async {
    centerRepository.showProgressDialog(context, Translations.current.loadingdata());
    List<ApiService> result=await restDatasource.getCarService(widget.serviceVM.carId);
    if(result!=null && result.length>0)
      return result;
    return null;
  }


  @override
  void dispose() {
    notyDateBloc.dispose();
    super.dispose();
  }


  @override
  void initState() {

    fServices=loadCarServices(widget.serviceVM.carId);
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder<List<ApiService>>(
        future: fServices,
        builder: (context,snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            centerRepository.dismissDialog(context);
            servcies = snapshot.data;
            List<ApiService> finalServices=new List();
            List<ApiService> newServices=servcies.where((s)=>s.ServiceStatusConstId==Constants.SERVICE_DONE).toList();
            finalServices=newServices;
            return
                  StreamBuilder<Message>(
                    stream: widget.filterNoty.noty,
                    builder: (context,snapshot){
                      if(snapshot.hasData && snapshot.data!=null) {
                        if (snapshot.data.type == 'REFRESH') {
                          fServices=loadCarServices(widget.serviceVM.carId);
                        } else {
                          centerRepository.dismissDialog(context);
                          int stid = snapshot.data.index;
                          finalServices =
                              newServices.where((s) => s.ServiceTypeId == stid)
                                  .toList();
                        }
                      }else{
                        finalServices=newServices;
                      }
                      if(finalServices!=null && finalServices.length>0) {
                        finalServices.sort((ApiService a, ApiService b) {
                          String s1 = a.ServiceDate!=null ?  a.ServiceDate.replaceAll('/', '') : '0';
                          String s2 = b.ServiceDate!=null ? b.ServiceDate.replaceAll('/', '') : '0';
                          return int.tryParse(s2).compareTo(int.tryParse(s1));
                        });
                      }
                      return
                          ServiceForm(carId: widget.serviceVM.carId, serviceVM: widget.serviceVM,servcies: finalServices,);
                    }
                  );
          }
          else {
            if (widget.serviceVM != null && widget.serviceVM.refresh != null &&
                widget.serviceVM.refresh) {
              centerRepository.dismissDialog(context);
              fServices = loadCarServices(widget.serviceVM.carId);
            }
            return NoDataWidget();
          }
        }
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
