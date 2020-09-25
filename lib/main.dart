import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:beacon_notification_test/pages/mainPage.dart';

void main()
{
    /* 視覺輔助排版工具 */
    debugPaintSizeEnabled = false;

    /* 主程式進入點 */
    runApp(BeaconNotifyApp());
}

class BeaconNotifyApp extends StatefulWidget
{
    @override
    _BeaconNotifyAppState createState() => _BeaconNotifyAppState();
}

class _BeaconNotifyAppState extends State<BeaconNotifyApp>
{
    @override
    Widget build(BuildContext context)
    {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MainPage()
        );
    }
}
