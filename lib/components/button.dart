import 'package:flutter/material.dart';
import 'package:anad_magicar/translation_strings.dart';

class Button extends StatelessWidget {

  final String title;
  double wid;
  int color=0xff3949ab;
  Color clr;
  Button({this.wid, this.title,this.color,this.clr});
  @override
  Widget build(BuildContext context) {
    return ( new Padding(
      padding: EdgeInsets.only(right: 0.0,left: 0.0) ,
        child:
        new Container(
      width: wid,
      height: 40.0,
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: clr!=null ? clr : Color(this.color),
        border: new Border.all(width: 0.5,color: clr!=null ? clr : Color(this.color)),
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
      ),
      child: new Text(
        this.title,
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: color!=null ? Color(color) : Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.3,
        ),
      ),
        ),
    ));
  }
}
