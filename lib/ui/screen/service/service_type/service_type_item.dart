import 'package:anad_magicar/common/constants.dart';
import 'package:anad_magicar/model/apis/api_service.dart';
import 'package:anad_magicar/model/apis/service_type.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/utils/dart_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ServiceTypeItem extends StatelessWidget {
  ServiceType serviceItem;
  ServiceTypeItem({Key key,this.serviceItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    bool isDurational=(serviceItem.ServiceTypeConstId!=Constants.SERVICE_TYPE_FUNCTIONALITY);

    return Padding(
      padding: EdgeInsets.only(top: 5.0,left: 5.0,right: 5.0,bottom: 5.0),
      child: Card(
        elevation: 0.0,
        child: Container(
          decoration: BoxDecoration(
            //color: Colors.white30,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          new Padding(padding: EdgeInsets.only(right: 10.0),
          child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
               Text(DartHelper.isNullOrEmptyString( serviceItem.ServiceTypeTitle)),
              ],
            ),),
        new Padding(padding: EdgeInsets.only(right: 10.0),
          child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translations.current.serviceTypeCode(),style: TextStyle(fontSize: 16.0),),
                Text(DartHelper.isNullOrEmptyString(serviceItem.ServiceTypeCode),style: TextStyle(fontSize: 16.0))
              ],
            ),),
        isDurational ?  new Padding(padding: EdgeInsets.only(right: 10.0),
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('دوره زمانی هشدار',style: TextStyle(fontSize: 16.0),),
                  Text(DartHelper.isNullOrEmptyString(serviceItem.AlarmDurationDay==null ? '0' : serviceItem.AlarmDurationDay.toString())),
                ],
              ),) : Container(),
          isDurational ?  new Padding(padding: EdgeInsets.only(right: 10.0),
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('دوره زمانی',style: TextStyle(fontSize: 16.0),),
                  Text(DartHelper.isNullOrEmptyString( serviceItem.DurationValue==null ? '0' : serviceItem.DurationValue.toString())),
                ],
              ),) : Container(),
        new Padding(padding: EdgeInsets.only(right: 10.0),
          child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translations.current.description(),style: TextStyle(fontSize: 16.0),),
                Text(DartHelper.isNullOrEmptyString(serviceItem.Description),style: TextStyle(fontSize: 16.0)),
                Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent
                  ),
                  child:  Image.asset('assets/images/scar2.png',color: Colors.pinkAccent),),
              ],
            ),),
      !isDurational ? new Padding(padding: EdgeInsets.only(right: 10.0),
          child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translations.current.alarmCount(),style: TextStyle(fontSize: 16.0),),
                Text(DartHelper.isNullOrEmptyString(serviceItem.AlarmCount==null ? '0' : serviceItem.AlarmCount.toString()),style: TextStyle(fontSize: 16.0))
              ],
            ),) : Container(),
          ],
        ),
       ),
      ),
    );
  }
}
