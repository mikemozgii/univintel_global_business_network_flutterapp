library gbn.globals;

import 'package:univintel_gbn_app/services/api.dart';

ApiService apiService = ApiService();

String currentUserToken = "";

final String apiHost = 'https://www.univintel.com/mobileapi/';
// Don't commit local path
//final String apiHost = 'http://10.0.2.2:5000/';

void setCurrentUserToken(String token){
  currentUserToken = token;
}

void resetCurrentUserToken(){
  currentUserToken = "";
}
