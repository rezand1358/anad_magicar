import 'dart:async';

import 'dart:convert';
import 'package:anad_magicar/repository/pref_repository.dart';
import 'package:anad_magicar/repository/user/user_repo.dart';
import 'package:anad_magicar/translation_strings.dart';
import 'package:anad_magicar/utils/check_status_connection.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class  NetworkUtil {

 static StreamSubscription _connectionChangeStream;
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();
  static bool hasInternet=true;
  String finalCookie='';
  NetworkUtil.internal();
  factory NetworkUtil() {
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);

      if(hasInternet)
    return _instance;
      return null;
  }

 static void connectionChanged(dynamic hasConnection) {
   hasInternet=hasConnection;
 }
 void _updateCookieViaDio(Response response) {
   List<String> allSetCookie = response.headers['set-cookie'] ;

   if (allSetCookie != null) {
     cookie=allSetCookie;

    // var setCookies = allSetCookie.split(';');

     //var setCookies = allSetCookie.split(',');

     for (var setCookie in allSetCookie) {
       var setCookies = setCookie.split(';');
       for (var sc in setCookies) {
         if (sc.startsWith('ClientId') ||
             sc.startsWith('Vision_AUTH') ) {
           _setCookie(sc);
         }
         else {
           var cookies = setCookie.split(',');
           for (var cookie in cookies) {
             if(!cookie.startsWith('ClientId'))
               _setCookie(cookie);
           }
         }
       }
     }

     //headers['cookie'] = _generateCookieHeader();
   }
 }

  void _updateCookie(http.Response response) {
   String allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
        cooki2=allSetCookie;

        var setCookies = allSetCookie.split(';');

       // var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        //var setCookies = setCookie.split(';');
          if (setCookie.startsWith('ClientId')) {
            _setCookie(setCookie);
          }
          else {
            var cookies = setCookie.split(',');
            for (var cookie in cookies) {
              //if(!cookie.startsWith('ClientId'))
                _setCookie(cookie);
            }
          }

      }

      //headers['cookie'] = _generateCookieHeader();
    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires')
          return;

        this.cookies[key] = value;
      }
    }
  }
 Future<String> getToken() async
  {
    String vision_auth=await userRepository.getCookie();
    String v_clientId=await userRepository.getCookieClientId();
    token=vision_auth;
    clientId=v_clientId;
    //return vision_auth;
    /*if(token==null || token.isEmpty)
      return defaultAdminToken;*/
   return prefix_clientid+ v_clientId+";"+prefix_token+vision_auth;
  }

  String getCookie()
  {
    return prefix_clientid+ clientId+";"+prefix_token+token;
  }



  String defaultAdminToken='ClientId=UUUU,84132484-0f04-4989-a769-cfa68e43b3d1; ASP.NET_SessionId=xeepdbdibbhxqzrkbs3gyj0f; Vision_AUTH=9FDD19519F4B52490B657BD137E2F22218FE3267753DDEF25B9BA40F8C4D8290618665D5838EFF1E33EB24D9EF4137230EA13E25F37A04060290FC9DCD0B703B6B142666C3B5F89F2E8FA41F7CA6D7F6FFE4C0B6C45620AE0F30119F9E86F90C0F906CCB80E6BB0B950DF2C68DC5123DB3A57E7E697E03B46A9E8B1EC5D7578CB60C87773D51B3D5E1265BB40B01C96B9D2AFFFC0E85CAE429678992B29D03B61893C0FFC852BA6112DD6B09E8A39864C5A4AAFA45605133FF6CAB68D27DC056';

  final JsonDecoder _decoder = new JsonDecoder();
  final JsonEncoder _encoder=new JsonEncoder();

  static String content="application/json;charset=utf-8";
  static List<String> cookie=new List();
  String cooki2;
  static String token="";
  static String clientId="";
  static String expire="";

  static String prefix_token="Vision_AUTH=";
  static String prefix_clientid="ClientId=";

  static Map<String,String> fheaders=new Map();
  Map<String, String> cookies = {};

  UserRepository userRepository=new UserRepository();
 Future<T> getUriWithCooki<T>(Uri uri,{Map<String,String> theaders}) {
   if(hasInternet) {
     if (theaders == null) {
       fheaders.putIfAbsent("Content-Type", () => content);
     }

     fheaders.putIfAbsent('Cookie', () =>
     (token != null && token.isNotEmpty)
         ? getCookie()
         : getToken());

     if(fheaders.containsKey("content-type"))
       fheaders.remove("content-type");

     return http.get(uri, headers: theaders == null ? fheaders : theaders)
         .then((http.Response response) {
       final String res = response.body;
       final int statusCode = response.statusCode;
       final Map<String, String> headers = response.headers;


       if (statusCode < 200 || statusCode > 400 || json == null) {
         throw new Exception(res /*Translations.current.errorFetchData()*/);
       }

       return _decoder.convert(res);
     });
   }
   else
     {

     }
 }

  Future<T> getUri<T>(Uri uri,{Map<String,String> theaders}) {
    if(theaders==null)
    {
      fheaders.putIfAbsent("Content-Type",()=> content);
    }
    if(fheaders!=null && fheaders.containsKey('Cookie'))
        fheaders.remove('Cookie');
    if(fheaders.containsKey("content-type"))
      fheaders.remove("content-type");

    //fheaders.putIfAbsent('Cookie', ()=>token.isNotEmpty ? getCookie() :  getToken());
    return http.get(uri,headers: theaders==null ?  fheaders : theaders).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      final Map<String,String> headers=response.headers;


      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception(res/*Translations.current.errorFetchData()*/);
      }

      if(headers["set-cookie"]!=null &&
          headers["set-cookie"].isNotEmpty)
        {
         // _updateCookie(response);
          token=cookies['Vision_AUTH'];
          clientId=cookies['ClientId'];

          if(token!=null &&
          clientId!=null) {
            userRepository.persistCookie(token,clientId);
          }
        }
      return _decoder.convert(res);
    });
  }

  Future<T> getWithDio<T>(String url,{Map<String,String> theaders,Map<String,String> params}) async
  {
    Response response;

    BaseOptions options = new BaseOptions(
        connectTimeout: 50000,
        receiveTimeout: 30000,
      contentType: "application/json; charset=utf-8",
    );
    Dio dio = new Dio(options);
    response = await dio.get(url, queryParameters: params,options: Options(
        headers: theaders,method: 'GET'));
    var res = response.data;
    final int statusCode = response.statusCode;
    //final Map<String,String> headers=response.headers;
    Headers headers=response.headers;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception(Translations.current.errorFetchData());
    }

    if(headers["set-cookie"]!=null &&
        headers["set-cookie"].isNotEmpty)
    {
      _updateCookieViaDio(response);
      token=cookies['Vision_AUTH'];
      clientId=cookies['ClientId'];

      if(token!=null &&
          clientId!=null) {
        userRepository.persistCookie(token,clientId);
      }
    }
    return res;//_decoder.convert(res);
  }
  Future<T> get<T>(String url,{Map<String,String> theaders,String body}) async {
    if(theaders==null)
      {
        fheaders.putIfAbsent("Content-Type",()=> content);
      }

    if(token==null || token.isEmpty)
        finalCookie=await getToken();

    fheaders.putIfAbsent('Cookie', ()=>(token!=null && token.isNotEmpty) ? getCookie() :  finalCookie);
    if(fheaders.containsKey("content-type"))
      fheaders.remove("content-type");

    return http.get(url,headers: theaders==null ?  fheaders : theaders,).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception(res);
      }
      return _decoder.convert(res);
    });
  }

  Future<T>  post<T>(String url, {Map<String,String> headers,Map<String,dynamic> body,Encoding encoding}) async {


    fheaders.putIfAbsent("Content-Type",()=> content);
    if(token==null || token.isEmpty)
      finalCookie=await getToken();

    fheaders.putIfAbsent('Cookie', ()=>(token!=null && token.isNotEmpty) ? getCookie() : finalCookie);
    if(fheaders.containsKey("content-type"))
      fheaders.remove("content-type");

    return http
        .post(url, body:_encoder.convert( body), headers: fheaders, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception(Translations.current.errorFetchData());
      }
      return  _decoder.convert(res);
    });
  }

  Future<T>  postWithParams<T>(String url, {Map<String,String> headers,Map<String,String> body,Encoding encoding}) async {

   fheaders.putIfAbsent("Content-Type",()=> content);
   if(token==null || token.isEmpty)
     finalCookie=await getToken();

   fheaders.putIfAbsent('Cookie', ()=>(token!=null && token.isNotEmpty) ? getCookie() : finalCookie);
   if(fheaders.containsKey("content-type"))
     fheaders.remove("content-type");

   Response response;

   BaseOptions options = new BaseOptions(
     connectTimeout: 50000,
     receiveTimeout: 30000,
     contentType: "application/json; charset=utf-8",
   );
   Dio dio = new Dio(options);
   response = await dio.post(url, queryParameters:  body ,options: Options(
       headers: fheaders,method: 'POST'));
   var res = response.data;
   final int statusCode = response.statusCode;
   //final Map<String,String> headers=response.headers;
   Headers headers=response.headers;

   if (statusCode < 200 || statusCode > 400 || json == null) {
     throw new Exception(Translations.current.errorFetchData());
   }

   return res;//_decoder.convert(res);
 }

 Future<String>  postForMap(String url, {Map<String,String> headers,dynamic mbody,Encoding encoding}) {

   if(headers==null)
     fheaders.putIfAbsent("Content-Type",()=> content);
   else
   {
     headers.forEach((k,v){
       fheaders.putIfAbsent(k, ()=>v);
     });
   }
   if(fheaders.containsKey("content-type"))
     fheaders.remove("content-type");

   //headers.putIfAbsent("Content-Type",()=> content);
   return http
       .post(url, body: mbody, headers: fheaders, encoding: encoding)
       .then((http.Response response) {
     final String res = response.body;
     final int statusCode = response.statusCode;

     if (statusCode < 200 || statusCode > 400 || json == null) {
       throw new Exception("Error while fetching data");
     }
     return res;
   });
 }

 Future<T>  postNoCookie<T>(String url, {Map<String,String> headers,Map<String,dynamic> body,Encoding encoding}) {

   fheaders.putIfAbsent("Content-Type",()=> content);
   //fheaders.putIfAbsent('Cookie', ()=>token.isNotEmpty ? getCookie() : getToken());
   if(fheaders.containsKey('Cookie'))
      fheaders.remove('Cookie');
   if(fheaders.containsKey("content-type"))
     fheaders.remove("content-type");

   return http
       .post(url, body:_encoder.convert( body), headers: fheaders, encoding: encoding)
       .then((http.Response response) {
     final String res = response.body;
     final int statusCode = response.statusCode;
     final Map<String,String> rheaders=response.headers;

     if( rheaders!=null &&
         rheaders["set-cookie"]!=null &&
         rheaders["set-cookie"].isNotEmpty)
     {
        _updateCookie(response);
       token=cookies['Vision_AUTH'];
       clientId=cookies['ClientId'];

       if(token!=null &&
           clientId!=null) {
         userRepository.persistCookie(token,clientId);
       }
     }
     if (statusCode < 200 || statusCode > 400 || json == null) {
       throw new Exception(Translations.current.errorFetchData());
     }
     return  _decoder.convert(res);
   });
 }
}
