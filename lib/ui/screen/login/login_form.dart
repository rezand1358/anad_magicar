import 'package:anad_magicar/Routes.dart';
import 'package:anad_magicar/authentication/authentication.dart';
import 'package:anad_magicar/bloc/base_class/base_widget_state.dart';
import 'package:anad_magicar/bloc/login/login.dart';
import 'package:anad_magicar/bloc/login/login.dart';
import 'package:anad_magicar/components/BorderedButton.dart';
import 'package:anad_magicar/components/animated_switcher.dart';
import 'package:anad_magicar/components/animstepper/stepper.dart';
import 'package:anad_magicar/components/button.dart';
import 'package:anad_magicar/components/fancy_popup/main.dart';
import 'package:anad_magicar/components/flushbar/flushbar.dart';
import 'package:anad_magicar/components/flushbar/flushbar_helper.dart';
import 'package:anad_magicar/components/loading_indicator.dart';
import 'package:anad_magicar/components/myprogress_dialog.dart';
import 'package:anad_magicar/components/shimmer/myshimmer.dart';
import 'package:anad_magicar/data/rest_ds.dart';
import 'package:anad_magicar/data/rxbus.dart';
import 'package:anad_magicar/firebase/message/firebase_message_handler.dart';
import 'package:anad_magicar/model/apis/api_user_model.dart';
import 'package:anad_magicar/model/change_event.dart';
import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/service/local_auth_service.dart';
import 'package:anad_magicar/service/locator.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/ui/screen/loading_screen.dart';
import 'package:anad_magicar/ui/screen/login/fancy_login/flutter_login.dart';
import 'package:anad_magicar/ui/screen/login/fancy_login/src/widgets/animated_text_form_field.dart';
import 'package:anad_magicar/ui/screen/login/fancy_login/src/widgets/expandable_container.dart';
import 'package:anad_magicar/ui/screen/login/fancy_login_form.dart';
import 'package:anad_magicar/ui/screen/login/fancy_login/src/models/login_data.dart' as logData;
import 'package:anad_magicar/ui/screen/login/finger_print_auth.dart';

import 'package:anad_magicar/ui/screen/login/login_screen.dart';
import 'package:anad_magicar/ui/screen/login/register/fancy_register_form.dart';
import 'package:anad_magicar/ui/screen/login/register/src/models/login_data.dart' as regData;

import 'package:anad_magicar/ui/screen/login/register/flutter_register.dart';
import 'package:anad_magicar/ui/screen/register/register_screen.dart';
import 'package:anad_magicar/widgets/bottom_sheet_custom.dart';
import 'package:anad_magicar/widgets/flash_bar/flash.dart';
import 'package:anad_magicar/widgets/flash_bar/flash_helper.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:anad_magicar/widgets/animated_dialog_box.dart';



class LoginForm extends StatefulWidget
{

  final LoginBloc loginBloc;
  final AuthenticationBloc authenticationBloc;
  final LoginType loginType;
  FireBaseMessageHandler messageHandler;
  LoginForm({
    Key key,
    @required this.loginBloc,
    @required this.authenticationBloc,
    @required this.loginType,
    this.messageHandler,
  }) : super(key: key);

  @override
  _LoginFormState createState() {

    return _LoginFormState();
  }

}

class _LoginFormState extends  BaseState<LoginForm> //State<LoginForm>
      with TickerProviderStateMixin
{

  LoginForm get _widget => widget as LoginForm;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _pvController = PageController(initialPage: 0);
  final LocalAuthenticationService _localAuth = locator<LocalAuthenticationService>();
  LoginBloc get _loginBloc => _widget.loginBloc;
  AnimationController formAnimationController;
  List<Animation> formAnimations;
  Animation buttonAnimation;
  Animation<Offset> pulseAnimation;

  bool signUpDone=false;
  String recCode='';

  int index=1;
  String securityCode='';
  String userName='';
  String mobile='';
  String password='';
  bool isLoginDisabled;
  MyProgressDialog myProgressDialog;
  bool _isLoading=false;
  bool fingerprintSupport=true;
  bool reSendSecurityCode=false;
  TextEditingController _securityCodeTextEditController;

  void registerBus() {
    RxBus.register<ChangeEvent>().listen((ChangeEvent event)  {


      if(event.message=='FINGERPRINT_AUTH')
      {
        fingerprintSupport=false;
        Fluttertoast.showToast(
            msg: Translations.current.noFingerPrintSupport(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      if(event.type=='LOGIN_USERNAME')
        {
         // this.userName=event.message;
        }
      if(event.type=='LOGIN_CLICKED')
        {
         // this.password=event.message;
          //_pvController.jumpToPage(0);

        }
      if(event.type=='SIGNUP_PAGE_SELECT')
        {
          _pvController.jumpToPage(1);

        }
      if(event.type=='LOGIN_PAGE_SELECT'){
        _pvController.jumpToPage(0);
      }
    });
  }
  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  void initFingerPrint() async{
    fingerprintSupport=await _localAuth.init();
  }

  @override
  void initState() {

    super.initState();
    registerBus();
    isLoginDisabled=false;
    formAnimationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );
   /* myProgressDialog=new MyProgressDialog(context: context,
        message: 'در حال ورود به برنامه',
        showPercentage: true);*/
    _loadingController =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 1150),
          reverseDuration: Duration(milliseconds: 300),
        )..value = 1.0;

    _loadingController?.addStatusListener(handleLoadingAnimationStatus);
    _nameTextFieldLoadingAnimationInterval = const Interval(0, .85);
double start = index * 0.1;
double duration = 0.6;
double end = duration + start;
formAnimations=[new Tween<double>(begin: 800.0, end: 0.0).animate(
          new CurvedAnimation(
              parent: formAnimationController,
              curve: new Interval(start, end, curve: Curves.decelerate))),
              new Tween<double>(begin: 800.0, end: 0.0).animate(
          new CurvedAnimation(
              parent: formAnimationController,
              curve: new Interval(start*2, end, curve: Curves.decelerate)))];
    buttonAnimation = new CurvedAnimation(
        parent: formAnimationController,
        curve: Interval(0.7, 1.0, curve: Curves.decelerate));


        pulseAnimation = Tween<Offset>(
          begin: Offset(6, 0),
          end: Offset.zero,
        ).animate(
                    CurvedAnimation(
                      parent: formAnimationController,
                      curve: Interval(
                        0.0,
                        0.6,
                        curve: Curves.ease,
                      ),
                    ),
);
    formAnimationController.forward();

    initFingerPrint();
    initConnectivity();
    _securityCodeTextEditController=new TextEditingController();


    _securityCodeTextEditController.addListener(() {
      final text = _securityCodeTextEditController.text.toLowerCase();
      _securityCodeTextEditController.value = _securityCodeTextEditController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

 @override
  void dispose() {
    formAnimationController.dispose();
    super.dispose();
  }

  _buildFingerPrintLogin() {
    return SlideTransition(
        position: pulseAnimation,
        child:
           /* Expanded(
        child:*/
        /*Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: 0.0,left: 0.0,right: 0.0,top: 0.0),
          height: 68.0,
          width: 68.0,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent[100],style: BorderStyle.solid,width: 1.5),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent
                ],
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(3.0)
              )
          ),
          child:*/
         /* Center(
            child:*/
            IconButton(
              padding: EdgeInsets.all(10.0),
              onPressed: () {

                //_loginBloc.dispatch(new LoginButtonPressed(username: userName,password: ''));
               // myProgressDialog.showProgressDialog();
                isLoginDisabled=true;
              },
              icon: Icon(Icons.fingerprint,color: Colors.redAccent,size: 68.0,),
              alignment: Alignment.center,
              //color: Colors.transparent,
           // ),
         // ),
       // ),
        )





    );
  }
  _buildPatternLogin() {
    return SlideTransition(
        position: pulseAnimation,
        child:

          IconButton(
            padding: EdgeInsets.all(10.0),
            onPressed: (){

              //_loginBloc.dispatch(new LoginButtonPressed(username: userName,password: ''));
              //myProgressDialog.showProgressDialog();
              isLoginDisabled=true;
            },

            icon: Icon(Icons.touch_app,color: Colors.redAccent,size: 68.0,),
             alignment: Alignment.center,
            //color: Colors.transparent,
            // ),
            // ),
         // ),
        ),





    );
  }
_buildLogin() {
    return SlideTransition(
      position: pulseAnimation,
      child:
        Container(
                    margin: EdgeInsets.only(bottom: 2.0,left: 5.0,right: 5.0),
                    height: 38,
                    width: MediaQuery.of(context).size.width/4.0,
                    decoration: BoxDecoration(
                        //borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF76ff03).withAlpha(60),
                            blurRadius: 6.0,
                            spreadRadius: 0.0,
                            offset: Offset(
                              0.0,
                              3.0,
                            ),
                          ),
                        ],
                        border: Border.all(color: Colors.blueAccent[100],style: BorderStyle.solid,width: 0.5),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.transparent
                        ],
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0)
                      )
                    ),
                    child:
                    Center(
                      child:
                      RaisedButton(
                        onPressed: (){

                          _loginBloc.add(new LoginButtonPressed(username: userName,password: password));
                           // myProgressDialog.showProgressDialog();
                            isLoginDisabled=true;
                        },
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                        child: Text(Translations.of(context).login(), style: TextStyle(color: Colors.blueAccent)),
                        color: Colors.transparent,
                      ),
                    ),
            )





    );
  }

  _buildConfirmSecurityCode(String code) {
    return SlideTransition(
        position: pulseAnimation,
        child:
        Container(
          margin: EdgeInsets.only(bottom: 2.0,left: 5.0,right: 5.0,top:5.0),
          height: 38,
          width: MediaQuery.of(context).size.width/2.0,
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF76ff03).withAlpha(60),
                  blurRadius: 6.0,
                  spreadRadius: 0.0,
                  offset: Offset(
                    0.0,
                    3.0,
                  ),
                ),
              ],
              border: Border.all(color: Colors.blueAccent[100],style: BorderStyle.solid,width: 0.5),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent
                ],
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(25.0)
              )
          ),
          child:
          Center(
            child:
            RaisedButton(
              onPressed: (){

                if(code!=null &&
                code.isNotEmpty)
                  {
                    if(code==securityCode)
                      {
                        Navigator.of(context).pushNamed('/register',arguments: mobile);
                      }
                    else
                      {
                        centerRepository.showFancyToast(Translations.current.notValidSecurityCode());
                      }
                  }
              },
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              child: Text(Translations.of(context).confirmrecievecode(), style: TextStyle(color: Colors.blueAccent)),
              color: Colors.transparent,
            ),
          ),
        )

    );
  }

  _buildReSendSecurityCode(String mobil) {
    return SlideTransition(
        position: pulseAnimation,
        child:
        Container(
          margin: EdgeInsets.only(bottom: 2.0,left: 5.0,right: 5.0,top: 5.0),
          height: 38,
          width: MediaQuery.of(context).size.width/2.0,
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF76ff03).withAlpha(60),
                  blurRadius: 6.0,
                  spreadRadius: 0.0,
                  offset: Offset(
                    0.0,
                    3.0,
                  ),
                ),
              ],
              border: Border.all(color: Colors.blueAccent[100],style: BorderStyle.solid,width: 0.5),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent
                ],
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(25.0)
              )
          ),
          child:
          Center(
            child:
            RaisedButton(
              onPressed: (){
                reSendSecurityCode=true;
                _loginBloc.add(new ReSignUpButtonPressed(mobile: mobil));
              },
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              child: Text(Translations.of(context).resendSecurityCode(), style: TextStyle(color: Colors.blueAccent)),
              color: Colors.transparent,
            ),
          ),
        )





    );
  }

  _buildCancel() {
    return SlideTransition(
      position: pulseAnimation,
      child:
      Container(
        margin: EdgeInsets.only(bottom: 2.0,left: 5.0,right: 5.0,top: 5.0),
        height: 38,
        width:MediaQuery.of(context).size.width/2.0,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xFFf06292).withAlpha(60),
                blurRadius: 6.0,
                spreadRadius: 0.0,
                offset: Offset(
                  0.0,
                  3.0,
                ),
              ),
            ],
            border: Border.all(color: Colors.pinkAccent[100],style: BorderStyle.solid,width: 0.5),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.transparent
              ],
            ),
            borderRadius: BorderRadius.all(
                Radius.circular(25.0)
            )
        ),
        child: Center(
          child:
          RaisedButton(
            onPressed: (){

              Navigator.of(context).pushReplacementNamed('/login');
            },
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
            child: Text(Translations.of(context).cancel(), style: TextStyle(color: Colors.blueAccent)),
            color: Colors.transparent,
          ),
        ),
      ),





    );
  }
_buildExit() {
    return SlideTransition(
      position: pulseAnimation,
      child:
        Container(
                      margin: EdgeInsets.only(bottom: 2.0,left: 5.0,right: 5.0,top: 5.0),
                      height: 38,
                      width:MediaQuery.of(context).size.width/2.0,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFf06292).withAlpha(60),
                              blurRadius: 6.0,
                              spreadRadius: 0.0,
                              offset: Offset(
                                0.0,
                                3.0,
                              ),
                            ),
                          ],
                          border: Border.all(color: Colors.pinkAccent[100],style: BorderStyle.solid,width: 0.5),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.transparent
                            ],
                          ),
                          borderRadius: BorderRadius.all(
                              Radius.circular(25.0)
                          )
                      ),
                      child: Center(
                        child:
                        RaisedButton(
                          onPressed: (){

                            SystemNavigator.pop();
                          },
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                          child: Text(Translations.of(context).exit(), style: TextStyle(color: Colors.blueAccent)),
                          color: Colors.transparent,
                        ),
                      ),
                    ),





    );
  }

  _buildUsername(){
    return  SlideTransition(
      position: pulseAnimation,
      child:  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 45,
                    padding: EdgeInsets.only(
                      top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent[100],style: BorderStyle.solid,width: 0.5),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10)
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.transparent,
                          blurRadius: 0.0
                        )
                      ]
                    ),
                    child:
                     TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 4.0,bottom: 0.0,),
                        border: InputBorder.none,
                        icon: Icon(Icons.person_pin,
                            color: Colors.blueAccent[100],
                        ),
                        hintStyle: TextStyle(color: Colors.pinkAccent[100]),
                          hintText: Translations.of(context).userName(),
                      ),
                      onChanged: (value){
                        this.userName=value;
                      },
                    ),


                  ),
    );
  }

  _buildSecurityCode(String code){
    return  SlideTransition(
      position: pulseAnimation,
      child:  Container(
        width: MediaQuery.of(context).size.width/1.2,
        height: 45,
        padding: EdgeInsets.only(
            top: 4,left: 16, right: 16, bottom: 4
        ),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent[100],style: BorderStyle.solid,width: 0.5),
            borderRadius: BorderRadius.all(
                Radius.circular(10)
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 0.0
              )
            ]
        ),
        child:
        TextField(
          controller: _securityCodeTextEditController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 4.0,bottom: 0.0,),
            border: InputBorder.none,
            icon: Icon(Icons.security,
              color: Colors.blueAccent[100],
            ),
            hintStyle: TextStyle(color: Colors.pinkAccent[100]),
            hintText: Translations.of(context).pleaseEnterSecurityCode(),
          ),
          style: TextStyle(color: Colors.black),
          onChanged: (value){
            this.securityCode=value;
          },
        ),

      ),
    );
  }
 _buildPassword(){
    return  SlideTransition(
      position: pulseAnimation,
      child:  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 45,
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent[100],style: BorderStyle.solid,width: 0.5),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.transparent,
                              blurRadius: 0.0
                          )
                        ]
                    ),
                    child:
                    TextField(
                      textAlign: TextAlign.start ,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 4.0,bottom: 0.0,),
                        border: InputBorder.none,
                        icon: Icon(Icons.vpn_key,
                          color: Colors.blueAccent[100],
                        ),
                        hintStyle: TextStyle(color: Colors.pinkAccent[100]),
                        hintText: Translations.of(context).password(),
                      ),
                    ),
                  ),
    );
  }

  showValidateCode() async{
    await animated_dialog_box.showScaleAlertBox(
        title:Center(child: Text(Translations.current.changePasswordTitle())) ,
        context: context,
        firstButton: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          child: Text(Translations.current.yes()),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        secondButton: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.pinkAccent,
          child: Text(Translations.current.exit(),style: TextStyle(color: Colors.white),),
          onPressed: () {
            SystemNavigator.pop(animated: true);
          },
        ),
        icon: Icon(Icons.info_outline,color: Colors.red,),
        yourWidget: Container(
          child: Text(Translations.current.loginAndThenEditYourProfile()),
        ));
  }

  AnimationController _loadingController;
  Interval _nameTextFieldLoadingAnimationInterval;

  String mobileNo='';
  final _passwordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey();

  Widget _buildConfirmSecurityCode2(double width, ) {
    return Form(
        key: _formKey,
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
      Container(
      height: 100.0,
      child:
      AnimatedTextFormField(
      enabled: true,
      width: width,
      loadingController: _loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: Translations.current.pleaseEnterSecurityCode(),
      prefixIcon: Icon(Icons.security),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: (value) {
        if(value==null || value.isEmpty)
          return Translations.current.allFieldsRequired();
        return null;
      } ,
      onSaved: (value) async {
        var result;
        try {
           result = await restDatasource.validateSMSCode(mobileNo, value);
        } catch(ex) {
          //FlashHelper.informationBar(context, message: ex.toString());
          //showValidateCode();
        }
        if((result!=null && result) /*|| (result==null || !result)*/) {
          FlashHelper.informationBar(context, message: Translations.current.passwordHasChanged());
          showValidateCode();
        } else {
          FlashHelper.errorBar(context, message: Translations.current.changePasswordError());
        }
      }
      ),
      ),
      Container(
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Color(0xfffefefe),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(width: 1.0,color: Color(0xfffefefe)),
        ),
        height: 85.0,
        child: FlatButton(
          onPressed: () {
            _formKey.currentState.save();
          },
          child: Button(title: Translations.current.confirmSecurityCode(),
            color: Colors.pinkAccent.value,wid: 150.0,
          ),
        ) ),
      ],
      ),
    );
  }
  _showBottomSheetConfirmCode(BuildContext cntext,)
  {
    double wid=MediaQuery.of(context).size.width*0.80;
    showModalBottomSheetCustom(context: cntext ,
        mHeight: 0.65,
        builder: (BuildContext context) {
      return Builder(
        builder: (context) {
         return _buildConfirmSecurityCode2(wid);
        }
      );
        });
  }

  Future<String> _recoverFunc(String data) async {
    return Future.delayed(new Duration(microseconds: 100)).then((_) {
      if (data != null ) {
        if(isOnline) {
          mobileNo=data;
          SaveUserModel userModel=new SaveUserModel(MobileNo: data,UserId: 0);
          centerRepository.showProgressDialog(context, Translations.current.send());
       var result= restDatasource.forgotPassword(userModel);
       if(result!=null) {
         centerRepository.dismissDialog(context);
         result.then((res){
           if(res.IsSuccessful){
             FlashHelper.successBar(context, message: res.Message);
             _showBottomSheetConfirmCode(context);
             //Navigator.pushReplacementNamed(context, 'login');
           }else
             {
               FlashHelper.errorBar(context, message: res.Message);
               //_showBottomSheetConfirmCode(context);

             }
         });
       }else{
         centerRepository.dismissDialog(context);
         FlashHelper.errorBar(context, message: Translations.current.hasErrors());
       }
        }
        else
        {
          return Translations.current.noConnection();
        }

      }
      else {
        return Translations.current.allLoginFieldsRequired();
      }
      return '';
    });
  }

 Future<String> _loginFunc(logData.LoginData data)
  {
      return Future.delayed(new Duration(microseconds: 100)).then((_) {
        if (data != null &&
            data.name!=null && data.password!=null &&
            data.name.isNotEmpty &&
            data.password.isNotEmpty) {
          if(isOnline) {
            _loginBloc.add(
                new LoginButtonPressed(username: data.name /*userName*/,
                    password: data.password /*password*/));
            isLoginDisabled = true;
          }
          else
          {
            //showSnackLogin(context, Translations.current.noConnection(), false);
            _loginBloc.add(
                new LoginFailed(errorMessage: Translations.current.noConnection()));
            return Translations.current.noConnection();
          }

        }
        else {
          return Translations.current.allLoginFieldsRequired();
        }
        return '';
      });
  }
  Future<String> _loginFuncForRegForm(regData.LoginData data)
  {
    return Future.delayed(new Duration(microseconds: 100)).then((_) {
      if (data != null &&
          data.name!=null && data.password!=null &&
          data.name.isNotEmpty &&
          data.password.isNotEmpty) {
        if(isOnline) {
          _loginBloc.add(
              new LoginButtonPressed(username: data.name /*userName*/,
                  password: data.password /*password*/));
          isLoginDisabled = true;
        }
        else
        {
          //showSnackLogin(context, Translations.current.noConnection(), false);
          _loginBloc.add(
              new LoginFailed(errorMessage: Translations.current.noConnection()));
          return Translations.current.noConnection();
        }

      }
      else {
        return Translations.current.allLoginFieldsRequired();
      }
      return '';
    });

  }

  Future<String> _signUpFunc(logData.LoginData data)
  {
    return Future.delayed(new Duration(microseconds: 100)).then((_) {
      if (data != null &&
          data.mobile!=null &&
      data.mobile.isNotEmpty) {
        if (isOnline) {
          this.mobile = data.mobile;
          _loginBloc.add(new SignUpButtonPressed(mobile: data.mobile));
        }
        else
          {
            _loginBloc.add(new SignUpFailed(errorMessage : Translations.current.noConnection()));
            return Translations.current.noConnection();
          }
      }
      else if(!signUpDone) {
         return Translations.current.hasErrors();
      }
      else {
        return Translations.current.allLoginFieldsRequired();
      }
      return Translations.current.errorinSignUp();
    });

  }

  Future<String> _signUpFuncForRegister(regData.LoginData data)
  {
    return Future.delayed(new Duration(microseconds: 100)).then((_) {
      if (data != null &&
          data.mobile!=null &&
          data.mobile.isNotEmpty) {
        this.mobile=data.mobile;
        _loginBloc.add(new SignUpButtonPressed(mobile: data.mobile));

      }
      else {
        return Translations.current.allLoginFieldsRequired();
      }
      return Translations.current.errorinSignUp();
    });

  }
  _fingerFunc()
  {
    if(fingerprintSupport)
      _localAuth.authenticate();
  }

  _patternFunc()
  {

  }

  showSnackLogin(BuildContext context,String message,bool isLoading)
  {

    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar( duration: new Duration(seconds: 6),
          backgroundColor: Colors.amber,
          elevation: 0.8,
          content:
          Container(
            height: MediaQuery.of(context).size.height/4.3,
            child:
            new Column(

              children: <Widget>[
                isLoading ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new CircularProgressIndicator() ,
                      // new Text(message,style: TextStyle(fontFamily: 'IranSans',fontSize: 20.0),)
                    ]) :
                new Icon(Icons.error_outline,color: Colors.black,),
                Expanded(
                  child:
                  new Text(message,style: TextStyle(fontFamily: 'IranSans',fontSize: 20.0),),),
              ],
            ),
          ),
        ));
  }

  showConfrimSecurityCodePopUp(String recCode)
  {
    final popup = BeautifulPopup(
      context: context,
      template: TemplateAuthentication,
    );
    popup.show(
      title: Translations.current.confirmrecievecode(),
      content: Translations.current.plzEnterRecievedSecurityCode(),
      actions: [
        new Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 100.0,
              child:
                  _buildSecurityCode(recCode),

            ),
            _buildConfirmSecurityCode(recCode),
            //_buildReSendSecurityCode(mobile),
            popup.button(
              label: Translations.current.resendSecurityCode(),
              onPressed: () {
                _loginBloc.add(new ReSignUpButtonPressed(mobile: mobile ));
              },
            ),
            popup.button(
              label: Translations.current.cancel(),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        )
      ],
// bool barrierDismissible = false,
// Widget close,

    );
    return popup;
  }
  Future<bool> _onWillPop(BuildContext ctx) {
    return showDialog(
      context: ctx,
      child: new AlertDialog(
        title: new Text(Translations.current.areYouSureToExitForBackTouchCancel()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: new Text(Translations.current.no()),
          ),
          new FlatButton(
            onPressed: () =>
                SystemNavigator.pop(),
            child: new Text(Translations.current.yes()),
          ),
        ],
      ),
    ) ??
        false;
  }
 Widget  showConfirmBox(String code)
   {
     return new Center(
      child:
       Container(
         margin: EdgeInsets.all(10.0),
         decoration: BoxDecoration(
           color: Color(0xfffefefe),
           borderRadius: BorderRadius.all(Radius.circular(10.0)),
           border: Border.all(width: 1.0,color: Color(0xfffefefe)),
         ),
         height: MediaQuery.of(context).size.height/2.5,
         child:
         new Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: <Widget>[
             _buildSecurityCode(code),
            _buildConfirmSecurityCode(code),
             _buildReSendSecurityCode(mobile),
             _buildCancel(),
            // _buildExit(),
           ],
         ),
       ),
     );
   }
  @override
  Widget build(BuildContext context) {

    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
   return new WillPopScope(
        onWillPop: () async {
          return _onWillPop(context);
        },
        child:
      BlocBuilder<LoginBloc, LoginState>(
      bloc: _loginBloc,
      builder: (
        BuildContext context,
        LoginState state,)
      {
       if(state is LoginInitial ) {
         isLoginDisabled=false;
         //RxBus.post(new ChangeEvent(type: 'LOGIN_LOADING',message: 'در حال ورود به برنامه...'));
       }
       else if(state is SignUpLoading)
         {
            centerRepository.showProgressDialog(context, Translations.current.plzWaiting());
         }
       else if(state is LoginLoading)
         {
           isLoginDisabled=true;
          // RxBus.post(new ChangeEvent(type: 'LOGIN_LOADING',message: 'در حال ورود به برنامه...'));
           centerRepository.showProgressDialog(context, Translations.current.loadingLogin());
          // FlushbarHelper.createLoading(message: 'در حال ورود به برنامه', linearProgressIndicator: LinearProgressIndicator())..show(context);
         }
       else if(state is LoginFailure)
         {
            isLoginDisabled=false;
            centerRepository.dismissDialog(context);
            RxBus.post(new ChangeEvent(type: 'LOGIN_FAILED',message: state.error));
            //FlushbarHelper.createError(message: state.error,title: Translations.current.hasErrors());

           // _showNotificationWithNoBadge(Translations.current.hasErrors(),state.error);

         }
       else if(state is LoginNoConnection)
         {
           //showSnackLogin(context, Translations.current.noConnection(), false);
           centerRepository.dismissDialog(context);
           RxBus.post(new ChangeEvent(type: 'LOGIN_NOCONNECTION',message: state.error));
           isLoginDisabled=false;
           return new LoadingScreen(messageHandler: widget.messageHandler,);
         }
       else if(state is SigUpNoConnection)
       {
         //showSnackLogin(context, Translations.current.noConnection(), false);
         //RxBus.post(new ChangeEvent(type: 'LOGIN_NOCONNECTION',message: state.error));
         centerRepository.dismissDialog(context);
         centerRepository.showFancyToast(state.error);
         isLoginDisabled=false;
         return new LoadingScreen(messageHandler: widget.messageHandler);
       }
       else if(state is LoggedIn ||
               state is LoginDone)
         {
           isLoginDisabled=false;
           return new LoadingScreen(messageHandler: widget.messageHandler);
         }
       else if(state is SignUpDone)
         {
          // RxBus.post(new ChangeEvent(type: 'SIGNUP_DONE',message: state.code));
           centerRepository.dismissDialog(context);
            signUpDone=true;
            securityCode=state.code;
            recCode=state.code;
            //_securityCodeTextEditController.text=recCode.toString();
         }
       else if(state is SignUpFaild)
         {

           centerRepository.dismissDialog(context);
           signUpDone=false;
           RxBus.post(new ChangeEvent(type: 'SIGNUP_FAILD_FOR_RELOGIN',message: 'SIGNUP_FAILD'));

           RxBus.post(new ChangeEvent(type: 'SIGNUP_FAILD',message: state.error));
         }
       else if(state is LoginForAuthenticate){
         return LoadingIndicator();
       }
        return Stack(
          overflow: Overflow.visible,
          //alignment: Alignment.topCenter,

          children: <Widget>[
          Container(
        width: w,
        height: h* 0.3,
        decoration: BoxDecoration(

            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80)
            )
        ),
            child: ClipRRect(
              borderRadius: new BorderRadius.only(bottomLeft: Radius.circular(50.0)),
              child: Image(
                fit: BoxFit.fill,
                image: AssetImage('assets/images/login_back.jpg'),
                width: w,
                height:  h* 0.3,
              ),
            ),
          ),

      Container(
        margin: EdgeInsets.only(top:0),
        alignment: Alignment.topCenter,
        height: h,
        width: MediaQuery.of(context).size.width,
        child: /*Column(
          children: <Widget>[*/
        ListView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.all(0.0),
              width: w,
              height: h* 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget> [
                  Spacer(),
              Container(
                width: MediaQuery.of(context).size.width/1.5,
                height: MediaQuery.of(context).size.height/6.5,
                child:
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/i26.png'),//Icon(Icons.person,
                  ),
              ),
                  Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget> [
                 /* Align(
                    alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 32,
                          right: 32
                        ),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(

                              child:
                               Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4, right: 2,bottom: 2.0,left: 2.0
                                        ),
                                        child: new Container(
                                          width: 140.0,
                                          height: 48.0,
                                          child:
                                          //Image.asset('assets/images/signup.png',scale: 1.0,),
                                          AnimatedSwitcherDeivao(controller: _pvController),

                                          // Image.asset('assets/images/signup.png')
                                        ),
                                     // ),
                                   // ),
                                   // radius: 30.0,
                                    //shape: BoxShape.circle
                                  ),
                                ),


                              onTap: () {
                               // Navigator.pushReplacementNamed(context, '/register');
                              },
                            ),
                          ],
                        ),
                      ),
                  ),*/
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding:  EdgeInsets.only(
                          bottom: 32,
                          right:  MediaQuery.of(context).size.width*0.55
                      ),
                      child: new Container(
                        width: 100.0,
                      height: 48.0,
                      child:
                      StepperTouch(
                        initialValue: 1,
                        direction: Axis.horizontal,
                        withSpring: false,
                        showIcon: false,
                        leftImage: 'assets/images/english.png',
                        rightImage: 'assets/images/iran.png',
                        leftTitle: 'En',
                        rightTitle: 'Fa',
                        onChanged: (int value) {
                          if(value==1)
                            {

                            }
                          else
                            {

                            }
                        },
                      ),
                      ),
                    ),
                    ),
                  ],
                ),
                ],
              ),
            ),

              Container(
                height: MediaQuery.of(context).size.height * 0.65,
                child: PageView(
                  physics: BouncingScrollPhysics(),
                  controller: _pvController,
                  children: <Widget>[

                  signUpDone ? showConfirmBox(recCode) :
                  (widget.loginType==LoginType.PASWWORD ||
                      widget.loginType==LoginType.PATTERN) ?
                  FancyLoginForm(
                      //isSignUp: false,
                      authUser: _loginFunc,
                    onSignup: _signUpFunc,
                    recoverPassword: _recoverFunc,
                    onSubmit: () { /*Navigator.of(context).pushReplacementNamed('/loadingscreen');*/
                    },) :
                      widget.loginType==LoginType.FINGERPRINT ?
                          TouchID() :
                      FancyLoginForm(
                        //isSignUp: false,
                        authUser: _loginFunc,
                        onSignup: _signUpFunc,
                        recoverPassword: _recoverFunc,
                        onSubmit: () {},),
                      signUpDone ? showConfirmBox(recCode) :
                    FancyRegisterForm(
          isSignUp: true,
          authUser: _loginFuncForRegForm,
          onSignup: _signUpFuncForRegister,
          recoverPassword: null,
          onSubmit: () {},
        ),

                  ],
                ),
              ),


          ],
        ),
      ),
       // ),
          ],
        );

      }
    ),
      );
  }

  @override
  void castStatefulWidget() {
    // TODO: implement castStatefulWidget
  }
  void _showTopFlash(String title,String message, {FlashStyle style = FlashStyle.floating}) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 2),
      persistent: false,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          boxShadows: [BoxShadow(blurRadius: 4)],
          barrierBlur: 3.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          style: style,
          position: FlashPosition.top,
          child: FlashBar(
            title: Text(title),
            message: Text(message),
            showProgressIndicator: true,
            primaryAction: FlatButton(
              onPressed: () => controller.dismiss(),
              child: Text(Translations.current.close(), style: TextStyle(color: Colors.amber)),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showNotificationWithNoBadge(String title,String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'no badge channel', 'no badge name', 'no badge description',

        importance: Importance.Max,
        priority: Priority.High,

    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, message, platformChannelSpecifics,
        payload: 'Default_Sound');
  }

  Future<void> _showPublicNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        visibility: NotificationVisibility.Public);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'public notification title',
        'public notification body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showOngoingNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ongoing: true,
        autoCancel: false);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'ongoing notification title',
        'ongoing notification body', platformChannelSpecifics);
  }
   showFloatingFlushbar(BuildContext context) {
   return Flushbar(
      padding: EdgeInsets.all(10.0),
      borderRadius: 8,
      backgroundGradient: LinearGradient(
        colors: [Colors.green.shade800, Colors.greenAccent.shade700],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      // All of the previous Flushbars could be dismissed by swiping down
      // now we want to swipe to the sides
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      // The default curve is Curves.easeOut
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      title: 'This is a floating Flushbar',
      message: 'Lorem ipsum dolor sit amet',
    )..show(context);
  }
}
