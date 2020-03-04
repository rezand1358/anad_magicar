

import 'package:anad_magicar/service/network_checker.dart';

enum connectionState{ ONLINE,OFFLINE}

abstract class FetchConnection {

  NetworkCheck networkCheck;

  onOnline();
  onOffline();



  validateConnection()
  {
    networkCheck=new NetworkCheck();
    networkCheck.checkInternet(fetchPrefrence);
  }

  fetchPrefrence(bool isNetworkPresent) {
    if(isNetworkPresent){
        onOnline();
    }else{
      onOffline();
    }
  }

  FetchConnection({
   this.networkCheck,
  }){
    validateConnection();
  }

}
