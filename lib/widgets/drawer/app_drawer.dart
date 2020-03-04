import 'package:anad_magicar/components/CircleImage.dart';
import 'package:anad_magicar/components/button.dart';
import 'package:anad_magicar/components/flutter_form_builder/flutter_form_builder.dart';
import 'package:anad_magicar/components/send_data.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/date/helper/shamsi_date.dart';
import 'package:anad_magicar/model/apis/service_result.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/model/viewmodel/map_vm.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/repository/user/user_repo.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/ui/map/openmapstreet/pages/home.dart';
import 'package:anad_magicar/ui/screen/car/car_page.dart';
import 'package:anad_magicar/ui/screen/profile/profile2.dart';
import 'package:anad_magicar/ui/screen/setting/native_settings_screen.dart';
import 'package:anad_magicar/ui/screen/setting/security_settings_form.dart';
import 'package:anad_magicar/ui/screen/user/user_page.dart';
import 'package:anad_magicar/utils/date_utils.dart';
import 'package:anad_magicar/widgets/bottom_sheet_custom.dart';
import 'package:anad_magicar/widgets/persian_datepicker/persian_datepicker.dart';
import 'package:flutter/material.dart';
import 'package:anad_magicar/widgets/animated_dialog_box.dart';

class AppDrawer extends StatelessWidget {

  String currentRoute;
  String userName;
  String imageUrl;
  Function carPageTap;
  int carId;
  AppDrawer({Key key,this.userName,this.imageUrl,this.currentRoute,this.carPageTap,this.carId}) : super(key: key);


  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autoValidate=false;
  String days='3';
  final TextEditingController textEditingController = TextEditingController();
  String fromDate='';
  String toDate='';
  PersianDatePickerWidget persianDatePicker;

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


  _showBottomSheetDates(BuildContext cntext)
  {
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
                    FlatButton(
                      child: Button(wid: 140.0,color: Colors.pinkAccent.value,title: Translations.current.doFilter(),),
                      onPressed: () {
                        //notyDateFilterBloc.updateValue(new ChangeEvent(fromDate: fromDate,toDate: toDate));
                        Navigator.pushNamed(context, MapPageState.route,arguments: new MapVM(
                            carId: carId ,
                            carCounts: null,
                            cars: null, fromDate: fromDate, toDate: toDate, forReport: true));


                      },
                    )
                  ],
                )
              ],
            );
        });

  }

  showFilterDate(BuildContext context, bool from) {
    return _showBottomSheetDates(context);
  }

  _onValueChanged(String value){
    days=value;
  }

  _logout(BuildContext context) async {
    ServiceResult result = await restDatasource.logoutUser();
    if (result != null) {

      if(result.IsSuccessful) {
        centerRepository.showFancyToast(Translations.current.logoutSuccessful());
        UserRepository userRepo = new UserRepository();
        userRepo
            .deleteToken(); //(username: widget.user.mobile,password: widget.user.password,code: widget.user.code);
        await prefRepository.setLoginStatus(true);
        await prefRepository.setLoginTypeStatus(LoginType.PASWWORD);

        Navigator.pushReplacementNamed(context, '/login');
      }
      else{
        if(result.Message!=null)
          centerRepository.showFancyToast(result.Message);
        else
          centerRepository.showFancyToast(Translations.current.hasErrors());
      }
    }
  }

  _showReportBasedOnDays(BuildContext context,String dys) {
    fromDate=DateTimeUtils.getDateJalaliWithAddDays((-1)* int.tryParse( dys));
    toDate=DateTimeUtils.getDateJalali();
    Navigator.pushNamed(context, MapPageState.route,arguments: new MapVM(carId: carId,
        carCounts: null, cars: null,
        fromDate: fromDate, toDate: toDate, forReport: true));
  }

  _showBottomSheetReport(BuildContext cntext)
  {
    double wid=MediaQuery.of(cntext).size.width*0.75;
    showModalBottomSheetCustom(context: cntext ,
        mHeight: 0.75,
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
            onPressed: (){ showFilterDate(context, true);},
            child: Button(title: Translations.current.fromDateToDate(),wid: wid,color: Colors.blueAccent.value,),
          )
          ),

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width*0.80,
          height: 250,
          child:

          new ListView (
          physics: BouncingScrollPhysics(),
          children: <Widget>[
          Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.all(0.0),
          width: MediaQuery.of(context).size.width*0.80,
          height: 200,
          child:
          Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
          FormBuilderTextField(
          initialValue: '3',
          attribute: "Days",
          decoration: InputDecoration(
          labelText: Translations.current.fromLastDays(),
          ),
          onChanged: (value) => _onValueChanged(value),
          valueTransformer: (text) => text,
          validators: [
          FormBuilderValidators.required(),
          ],
          keyboardType: TextInputType.numberWithOptions(signed: false,decimal: false),
          ),

          ),


          new GestureDetector(
          onTap: () {
            _showReportBasedOnDays(context, days);
          },

          child: new Container(
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
            _showReportBasedOnDays(context, days);
          },
          child: Button(title: Translations.current.showReportBaseOnDays(),wid: wid,color: Colors.blueAccent.value,),
          )
          ),

          ),
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
  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                image:  AssetImage('assets/images/login_back.jpg'))),
        child: Stack(children: <Widget>[
          Positioned(
              top: 20.0,
              right: 10.0,
              child: new Container(
                width: 80.0,
                height: 80.0,
                decoration: new BoxDecoration(
                  // Circle shape
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    // The border you want
                    border: new Border.all(
                      width: 1.0,
                      color: Colors.white,
                    ),
                    // The shadow you want
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5.0,
                      ),
                    ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius:100.0,
                child:
                Image.asset(imageUrl,width: 60.0,height: 60.0,),),
              )
    ),
          Positioned(
              top: 100.0,
              right: 10.0,
              child: new Container(
                //width: 80.0,
                height: 50.0,
                /*decoration: new BoxDecoration(
                  // Circle shape
                   // shape: BoxShape.circle,
                    color: Colors.transparent,
                    // The border you want
                    border: new Border.all(
                      width: 0.0,
                      color: Colors.white,
                    ),
                    // The shadow you want
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 0.0,
                      ),
                    ]
                ),*/
                child: Text(userName,style: TextStyle(color: Colors.white,fontSize: 35.0),
                  ),
              )
          ),
        ]),
    );
  }
  Widget _createDrawerItem(
      {BuildContext context, IconData icon, String text, bool isSelected,GestureTapCallback onTap}) {
    return ListTile(
      selected: isSelected ,
      subtitle: null,
      title: Container(
        height: 38.0,
        color: isSelected ? Colors.blueAccent.withOpacity(0.5) : Theme.of(context).appBarTheme.color,
        child:
      Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Drawer(
      key: _scaffoldKey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(context: context, icon: Icons.person_add,text: Translations.current.users(),isSelected: currentRoute==UserPageState.route, onTap: (){ Navigator.pushReplacementNamed(context, UserPageState.route);}),
          _createDrawerItem(context: context,icon: Icons.directions_car, text: Translations.current.car(),isSelected: currentRoute==CarPageState.route, onTap: (){carPageTap();}),
          _createDrawerItem(context: context,icon: Icons.security, text: Translations.current.security(),isSelected: currentRoute==SecuritySettingsFormState.route, onTap: (){ Navigator.pushReplacementNamed(context, SecuritySettingsFormState.route,arguments: true);}),
          Divider(),
          _createDrawerItem(context: context,icon: Icons.settings, text: Translations.current.settings(),isSelected: currentRoute==SettingsScreenState.route, onTap: (){Navigator.pushReplacementNamed(context, SettingsScreenState.route);}),
          _createDrawerItem(context: context,icon: Icons.person_pin, text: Translations.current.profile(),isSelected: currentRoute==ProfileTwoPageState.route, onTap: (){Navigator.pushReplacementNamed(context, ProfileTwoPageState.route,arguments: centerRepository.getUserInfo());}),
         /* _createDrawerItem(context: context,icon: Icons.report, text: Translations.current.report(),isSelected: currentRoute=='', onTap: (){
            //if(_scaffoldKey.currentState.isDrawerOpen){
              Navigator.pop(context);
            //}
            _showReportSheet(context);
          }),*/
          _createDrawerItem(context: context,icon: Icons.exit_to_app,isSelected: false, text: Translations.current.exit(),onTap: () async{
            await animated_dialog_box.showScaleAlertBox(
                title:Center(child: Text(Translations.current.logoutAccount())) ,
                context: context,
                firstButton: MaterialButton(
                  // FIRST BUTTON IS REQUIRED
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: Colors.white,
                  child: Text(Translations.current.yes()),
                  onPressed: () {
                    _logout(context);
                  },
                ),
                secondButton: MaterialButton(
                  // OPTIONAL BUTTON
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: Colors.white,
                  child: Text(Translations.current.no()),
                  onPressed: () {

                    Navigator.of(context).pop();
                  },
                ),
                icon: Icon(Icons.info_outline,color: Colors.red,), // IF YOU WANT TO ADD ICON
                yourWidget: Container(
                  child: Text(Translations.current.areYouSureToExit()),
                ));
          }),
          Divider(),
          ListTile(
            title: Text('1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
