import 'package:anad_magicar/bloc/values/notify_value.dart';
import 'package:anad_magicar/bloc/widget_events/ButtonDefinition.dart';
import 'package:anad_magicar/components/button.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/model/apis/api_message.dart';
import 'package:anad_magicar/model/message.dart';
import 'package:anad_magicar/ui/screen/message_app/message_app_item.dart';
import 'package:flutter/material.dart';
import 'package:anad_magicar/utils/dart_helper.dart';
import '../../../translation_strings.dart';

class NewMessageItem extends StatefulWidget {

  MessageDetailVM detailVM;
  NewMessageItem({Key key,this.detailVM}) : super(key: key);

  @override
  _NewMessageItemState createState() {
    return _NewMessageItemState();
  }
}

class _NewMessageItemState extends State<NewMessageItem> {

  String messageBody='';
  String messageSubject='';
  Color readColors=Colors.pinkAccent.withOpacity(0.5);
  int msgRead=0;
  NotyBloc<Message> statusMessageNoty;
  String tick_url='assets/images/tick.png';
  @override
  void initState() {
    super.initState();
    statusMessageNoty=new NotyBloc<Message>();
  }

  @override
  void dispose() {
    statusMessageNoty.dispose();
    super.dispose();
  }

  changeSmsStatus(ApiMessage message,int index) async {
    var result=await restDatasource.changeMessageStatus(message.MessageId, ApiMessage.MESSAGE_STATUS_AS_READ_TAG);
    if(result!=null){
      if(result.IsSuccessful){
        widget.detailVM.changeStatusNoty.updateValue(new Message(type: 'STATUS_CHANGED_AS_READ',index: message.MessageId));
        statusMessageNoty.updateValue(new Message(type:'MSG_READ',index: index));
      }
      else
      {

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

    body:
      new Padding(padding: EdgeInsets.only(top: 70.0),
        child:
             new Column(
               children: <Widget>[

      Container(
      height: MediaQuery.of(context).size.height*0.75,
      child:
      ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: widget.detailVM.messages.length,
        itemBuilder: (context, index) {
          return StreamBuilder<Message>(
            stream: statusMessageNoty.noty ,
            builder: (context,snapshot)
            {
              if(snapshot.hasData && snapshot.data!=null) {
                if(snapshot.data.type=='MSG_READ') {
                  readColors=Colors.green;
                  msgRead=snapshot.data.index;
                  tick_url='assets/images/d_tick.png';

                  widget.detailVM.messages[msgRead].MessageStatusConstId=ApiMessage.MESSAGE_STATUS_AS_READ_TAG;
                }
              } else{
                 if(widget.detailVM.messages[index].MessageStatusConstId==ApiMessage.MESSAGE_STATUS_AS_READ_TAG) {
                    readColors=Colors.green;
                    tick_url='assets/images/d_tick.png';
                  }
                else {
                  readColors=Colors.grey;
                  tick_url='assets/images/tick.png';
                }
              }
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
                      changeSmsStatus(widget.detailVM.messages[index],index);
                    },
                    child:
                    new Container(
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                        //color: ,
                        borderRadius: new BorderRadius.all(
                            new Radius.circular(5.0)),
                      ),
                      child:
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Padding(padding: EdgeInsets.only(right: 10.0),
                            child:
                            new Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: <Widget>[
                                Text(Translations.current.messageDate(),
                                  style: TextStyle(fontSize: 16.0),),
                                new Padding(
                                  padding: EdgeInsets.only(
                                      right: 10.0, left: 5.0),
                                  child: Text(
                                    widget.detailVM.messages[index].MessageDate.toString(),
                                    style: TextStyle(fontSize: 16.0),
                                    overflow: TextOverflow.fade,
                                    softWrap: true,),),
                              ],),),
                          new Padding(padding: EdgeInsets.only(right: 10.0),
                            child:
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Padding(
                                  padding: EdgeInsets.only(
                                      right: 10.0, left: 20.0),
                                  child:
                                  Text(widget.detailVM.messages[index].MessageBody,
                                    style: TextStyle(
                                        fontSize: 16.0),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,),),
                              ],
                            ),),
                          new Padding(padding: EdgeInsets.only(right: 10.0),
                            child:
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  DartHelper.isNullOrEmptyString(
                                      widget.detailVM.messages[index].Description),
                                  style: TextStyle(fontSize: 16.0),),
                              ],
                            ),
                          ),
                          new Padding(padding: EdgeInsets.only(right: 10.0),
                            child:
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  width:24.0,
                                  height: 24.0,
                                    child:
                                    ( widget.detailVM.messages[index].MessageStatusConstId==ApiMessage.MESSAGE_STATUS_AS_READ_TAG ) ?
                                       Image.asset('assets/images/d_tick.png',color: Colors.green,) :
                                       Image.asset('assets/images/tick.png',color: Colors.grey,) ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                );
            },
          );
        },
      ),
      ),
                 FlatButton(
                   onPressed: () {
                     Navigator.pop(context);
                   },
                   child: Button(title: Translations.current.goBack(),color: Colors.white.value,clr:Colors.pinkAccent,wid: 100.0,),
                 ),
      ],
             ),
      ),

    );
  }
}
