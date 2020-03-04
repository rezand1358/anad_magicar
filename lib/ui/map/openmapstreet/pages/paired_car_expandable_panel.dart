import 'package:anad_magicar/common/constants.dart';
import 'package:anad_magicar/components/button.dart';
import 'package:anad_magicar/components/flutter_form_builder/flutter_form_builder.dart';
import 'package:anad_magicar/components/send_data.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/model/apis/api_message.dart';
import 'package:anad_magicar/model/apis/paired_car.dart';
import 'package:anad_magicar/model/apis/slave_paired_car.dart';
import 'package:anad_magicar/model/cars/car.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/widgets/bottom_sheet_custom.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:anad_magicar/utils/dart_helper.dart';
import 'package:anad_magicar/widgets/animated_dialog_box.dart';

class PairedCarsExpandPanel extends StatefulWidget {

  ApiPairedCar pairedCar;
  int carId;
  //Map<int,List<Map<String,dynamic>>> cars;
  List<ApiPairedCar> cars;
  PairedCarsExpandPanel({Key key, this.pairedCar,this.cars,this.carId}) : super(key: key);

  @override
  PairedCarsExpandPanelState createState() {
    // TODO: implement createState
    return new PairedCarsExpandPanelState();
  }
}

class PairedCarsExpandPanelState extends State<PairedCarsExpandPanel> {

  bool isRead=false;
  List<ApiPairedCar> groupedCars=new List();
  List<int> carIds=new List();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autoValidate=false;
  ApiMessage newPaired;


  Widget createCollapsed(ApiPairedCar car,int carsCount) {
    return  new Padding(padding: EdgeInsets.only(right: 10.0),
      child:
      Column(
        children: <Widget>[
          createHeader(car),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(DartHelper.isNullOrEmptyString( carsCount.toString()),style: TextStyle(fontSize: 16.0),)

            ],
          ),
        ],
      ),);

  }

  Widget createExpanded(List<SlavedCar> cars) {
    return  Container(
      height: 250.0,
      child:
      ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return
            Card(
              margin: new EdgeInsets.only(
                  left: 5.0, right: 5.0, top: 8.0, bottom: 5.0),
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white, width: 0.0),
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 0.0,
              child:
              GestureDetector(
                onTap: () {

                },
                child:
                new Container(
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Color(0xffe0e0e0),
                    borderRadius: new BorderRadius.all(
                        new Radius.circular(5.0)),
                  ),
                  child:
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Padding(padding: EdgeInsets.only(right: 10.0,left: 20.0),
                        child:
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(Translations.current.carId(),
                              style: TextStyle(fontSize: 16.0),),
                            new Padding(
                              padding: EdgeInsets.only(right: 10.0, left: 5.0),
                              child: Text(cars[index].CarId.toString(),
                                style: TextStyle(fontSize: 16.0),
                                overflow: TextOverflow.fade, softWrap: true,),),
                          ],),),
                      new Padding(padding: EdgeInsets.only(right: 10.0,left: 20.0),
                        child:
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.only(right: 10.0, left: 20.0),
                              child:
                              Text(DartHelper.isNullOrEmptyString(cars[index].BrandTitle), style: TextStyle(
                                  fontSize: 16.0),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,),),
                          ],
                        ),),
                      new Padding(padding: EdgeInsets.only(right: 10.0,left: 20.0),
                        child:
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              DartHelper.isNullOrEmptyString(cars[index].CarModelTitle),
                              style: TextStyle(fontSize: 16.0),),
                            Text(
                              DartHelper.isNullOrEmptyString(DartHelper.isNullOrEmptyString(cars[index].CarModelDetailTitle)),
                              style: TextStyle(fontSize: 16.0),),
                          ],
                        ),
                      ),
                      new Padding(padding: EdgeInsets.only(right: 10.0,left: 20.0),
                        child:
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(Translations.current.carcolor(),
                              style: TextStyle(fontSize: 16.0),),
                            new Padding(
                              padding: EdgeInsets.only(right: 10.0, left: 5.0),
                              child: Text(DartHelper.isNullOrEmptyString(cars[index].Color),
                                style: TextStyle(fontSize: 16.0),
                                overflow: TextOverflow.fade, softWrap: true,),),
                          ],),),
                    ],
                  ),
                ),
              ),
            );
        },
      ),
    );
  }

  Widget createHeader(ApiPairedCar car) {
    var carinfo=centerRepository.getCars().where((c)=>c.carId==car.master).toList();
    Car c;
    if(carinfo!=null && carinfo.length>0){
      c=carinfo.first;
    }
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[


        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Padding(padding: EdgeInsets.only(right: 10.0,left: 10.0),
              child: Text(Translations.current.carToRequestForPair()),),
            new Padding(padding: EdgeInsets.only(right: 10.0,left: 20.0),
              child: Container(
                width: 22.0,
                height: 22.0,
                child:

            new Padding(padding: EdgeInsets.only(right: 10.0,left: 10.0),
              child:
              Text(DartHelper.isNullOrEmptyString(c.pelaueNumber)) ),),),

          ],
        ),
        new Padding(padding: EdgeInsets.only(right: 10.0),
          child:
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: new BorderRadius.all(
                      new Radius.circular(5.0)),
                ),
                child:
                 Text(Translations.current.carPairedCounts(),style: TextStyle(color: Colors.white,fontSize: 12.0),),
                ),
              Text(car.slaves!=null ? car.slaves.length.toString() : '0',style: TextStyle(color: Colors.white,fontSize: 12.0),),
            ],
          ),
        ),
      ],
    );

  }

  changeSmsStatus(ApiMessage message) async {
    var result=await restDatasource.changeMessageStatus(message.MessageId, ApiMessage.MESSAGE_STATUS_AS_READ_TAG);
    if(result!=null){
      if(result.IsSuccessful){
        setState(() {
          isRead=true;
        });
      }
      else
      {
        setState(() {
          isRead=false;
        });
      }
    }
  }









  @override
  void initState() {

    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: widget.cars.length,
      itemBuilder: (context, index) {
       // int masterId=widget.cars[index].master;
        List<SlavedCar> newList=widget.cars[index].slaves;
        ApiPairedCar pairedCar=widget.cars[index];
        return
          ExpandableNotifier(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: ScrollOnExpand(
                child: Card(
                  color: Colors.blueAccent.withOpacity(0.2),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expandable(
                        collapsed: createCollapsed(pairedCar,newList.length),
                        expanded: createExpanded(newList),
                      ),

                      Divider(height: 1,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Builder(
                            builder: (context) {
                              var controller = ExpandableController.of(context);

                              return FlatButton(
                                child: controller.expanded ? Icon(
                                    Icons.arrow_drop_up) :
                                Icon(Icons.arrow_drop_down_circle),
                                onPressed: () {
                                  controller.toggle();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
      },
    );
  }
}
