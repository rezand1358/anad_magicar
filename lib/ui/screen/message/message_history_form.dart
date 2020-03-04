
import 'package:anad_magicar/bloc/values/notify_value.dart';
import 'package:anad_magicar/components/no_data_widget.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/date/helper/shamsi_date.dart';
import 'package:anad_magicar/model/apis/car_action_log.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/ui/screen/message/message_history_form_item.dart';
import 'package:anad_magicar/utils/date_utils.dart';
import 'package:flutter/material.dart';

class MessageHistoryForm extends StatefulWidget {

  int carId;
  NotyBloc<ChangeEvent> notyDateFilterBloc;
  MessageHistoryForm({Key key,this.carId,this.notyDateFilterBloc}) : super(key: key);

  @override
  MessageHistoryFormState createState() {
    return MessageHistoryFormState();
  }
}

class MessageHistoryFormState extends State<MessageHistoryForm> {


  String fromDate='';
  String toDate='';

  Future<List<CarActionLog>> fcarActionLogs;
  List<CarActionLog> carActionLogs = new List();

  Future<List<CarActionLog>> getCarActionLog(String fromDate,
      String toDate) async {
  /*String mfDate=  DateTimeUtils.convertIntoDateObject(DateTimeUtils.convertIntoDateTime(fromDate)).toIso8601String();
  String mtDate= DateTimeUtils.convertIntoDateObject(DateTimeUtils.convertIntoDateTime(toDate)).toIso8601String();
  */  //Jalali fj=Jalali()
    var result = await restDatasource.GetCarLog(widget.carId, DateTimeUtils.convertIntoDateTime(fromDate),DateTimeUtils.convertIntoDateTime( toDate));
    if (result != null && result.length>0)
      return result;
    return null;
  }

  @override
  void initState() {

    fromDate=DateTimeUtils.getDateJalaliWithAddDays(-3);
    toDate=DateTimeUtils.getDateJalali();
    fcarActionLogs=getCarActionLog(fromDate, toDate);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<ChangeEvent>(
      initialData: new ChangeEvent(
          fromDate:fromDate,
          toDate: toDate),
      stream: widget.notyDateFilterBloc.noty ,
      builder: (context,snapshot) {
        if(snapshot.hasData && snapshot.data!=null) {
           var data=snapshot.data;
           fromDate=data.fromDate;
           toDate=data.toDate;
          fcarActionLogs= getCarActionLog(fromDate, toDate);
          return FutureBuilder<List<CarActionLog>>(
            future: fcarActionLogs,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null) {
                carActionLogs = snapshot.data;
                return  new Card(
                    margin: new EdgeInsets.only(
                        left: 5.0, right: 5.0, top: 80.0, bottom: 5.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black54,width: 0.5),
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
                      ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: carActionLogs.length,
                          itemBuilder: (context, index) {
                            return
                              MessageHistoryItem(carActionLog: carActionLogs[index]);
                          }
                      ),
                    ),
                );
              } else {
                return NoDataWidget(noCarCount: false,);
              }
            },
          );
        }
        else
        {
          return NoDataWidget(noCarCount: false,);
        }
      },
    );
  }

}
