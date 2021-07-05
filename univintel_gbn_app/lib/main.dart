import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:univintel_gbn_app/pages/root.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:appcenter/appcenter.dart';
// import 'package:appcenter_analytics/appcenter_analytics.dart';
// import 'package:appcenter_crashes/appcenter_crashes.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/foundation.dart' show TargetPlatform;

void main() => runApp(UnivIntelApp());



class UnivIntelApp extends StatefulWidget {
  @override
  _UnivIntelState createState() => _UnivIntelState();

}

class _UnivIntelState extends State<UnivIntelApp> {
  String _appSecret;
  bool areCrashesEnabled = false;

  _UnivIntelState() {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    _appSecret = ios
        ? "1471eaea-d149-4a16-a6d9-17386ec31f76"
        : "1471eaea-d149-4a16-a6d9-17386ec31f76";
  }

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    var mainColor = Color.fromRGBO(129, 176, 213, 1); //Color.fromRGBO(57, 164, 255, 1)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(23, 36, 45, 1)
      )
    );
    return MaterialApp(
        localizationsDelegates: [
          UnivIntelLocaleDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'Univintel',
        theme: ThemeData(
          dividerColor: Color.fromRGBO(18, 33, 36, 1),
          cursorColor: mainColor,
          textSelectionHandleColor: mainColor,
          textSelectionColor: mainColor,
          selectedRowColor: mainColor,
          tabBarTheme: TabBarTheme(indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: mainColor)
          ),),
          toggleableActiveColor: mainColor,
          accentColor: mainColor,
          focusColor: mainColor,
          brightness: Brightness.dark,
          backgroundColor: Color.fromRGBO(35, 47, 61, 1),
          scaffoldBackgroundColor: Color.fromRGBO(26, 38, 50, 1),
          buttonTheme: ButtonThemeData(
            buttonColor: mainColor,
            //shape: RoundedRectangleBorder(),
            //textTheme: ButtonTextTheme.accent
          ),
          bottomAppBarColor: Color.fromRGBO(28, 44, 57, 1),
          appBarTheme: AppBarTheme(
            color: Color.fromRGBO(28, 44 , 57, 1),
            elevation: 1
          ),
          textTheme: TextTheme(subtitle1: TextStyle(fontSize: 19)),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: mainColor),
            labelStyle: TextStyle(color: mainColor),
            errorStyle: TextStyle(color: Color.fromRGBO(207, 118, 121, 1)),
            errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(207, 118, 121, 1))
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: mainColor)),
            ),
        ),
        home: RootPage(),
        supportedLocales: [
          const Locale('en', ''), // English
          const Locale('ru', ''), // Russian
        ]
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    //await AppCenter.start(_appSecret, [AppCenterAnalytics.id, AppCenterCrashes.id]);
 }
}