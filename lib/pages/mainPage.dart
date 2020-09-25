import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:get_mac/get_mac.dart';
import 'package:beacon_notification_test/helpers/references.dart';
import 'package:beacon_notification_test/helpers/colorMsg.dart';
import 'package:beacon_notification_test/data/beacon.dart';

class MainPage extends StatefulWidget
{
    @override
    _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
{
    /// 初始化
    @override
    void initState() {
        super.initState();
        initPlatformState();
    }

    /// 銷毀
    @override
    void dispose() {
        beaconEventsController.close();
        super.dispose();
    }

    /// 藍牙掃描旗標
    bool isRunning = true;

    /// Beacon 監聽器
    final StreamController<String> beaconEventsController = StreamController<String>.broadcast();

    /// Beacon 資料列表
    Map<String, Beacon> beacons = Map();

    /// 手機的 MAC address
    String deviceMacAddr = 'Unknown';

    /// Platform 訊息皆為非同步，故以非同步方法初始化
    Future<void> initPlatformState() async
    {
        /* 獲取手機 MAC address */
        String _deviceMacAddre;
        try {
            _deviceMacAddre = await GetMac.macAddress;
        } on PlatformException {
            print(colorMsg(deviceMacAddr, r: 240, g: 208, b: 201));
        }
        setState(() {
            deviceMacAddr = _deviceMacAddre;
            print(colorMsg(deviceMacAddr, r: 140, g: 200, b: 50));
        });

        /* 設定 dubug 訊息等級 */
        BeaconsPlugin.setDebugLevel(1);

        /* 開啟 App 時便開始掃描 */
        await BeaconsPlugin.startMonitoring;

        /* 添加 beacon 區域 */
        for (int i = 0; i < myUuid.length; i++)
        {
            await BeaconsPlugin.addRegion("BeaconType${i + 1}", myUuid[i]);
        }

        /* 掃描 beacon */
        BeaconsPlugin.listenToBeacons(beaconEventsController);

        /* 掃描 beacon */
        beaconEventsController.stream.listen((data)
        {
            /* 監聽到的 beacon 資訊非空，亦即確實掃描到了藍牙 beacon */
            if (data.isNotEmpty)
            {
                /* 將字串型態的 device data 轉為物件 */
                Map<String, dynamic> map = jsonDecode(data);

                setState(()
                {
                    /* 只抓取 UUID 合乎限定的 beacon */
                    if (myUuid.contains(map['uuid'].toLowerCase()))
                    {
                        /* 新增 */
                        if (!beacons.containsKey(map['macAddress']))
                        {
                            Beacon beaconData = Beacon(
                                name: map['name'],
                                uuid: map['uuid'],
                                mac: map['macAddress'],
                                major: map['major'],
                                minor: map['minor'],
                                distance: map['distance'],
                                rssi: map['rssi'],
                                txPower: map['txPower'],
                                time: map['scanTime']
                            );
                            beacons.putIfAbsent(map['macAddress'], () => beaconData);
                        }
                        /* 更新 */
                        else
                        {
                            Beacon beaconData = Beacon(
                                name: map['name'],
                                uuid: map['uuid'],
                                mac: map['macAddress'],
                                major: map['major'],
                                minor: map['minor'],
                                distance: map['distance'],
                                rssi: map['rssi'],
                                txPower: map['txPower'],
                                time: map['scanTime']
                            );
                            beacons.update(map['macAddress'], (v) => beaconData);
                        }
                    }
                });
            }
        },
        onDone: () {},
        onError: (error) {
            print("Error: $error");
        });

        /* 設為 true 以背景執行 */
        await BeaconsPlugin.runInBackground(true);

        /* 刪除最後一次掃描已超過一定時間的 beacon */
        Timer.periodic(period, (timer)
        {
            setState(()
            {
                List<String> beaconMacAddrToBeRemoved = <String>[];

                if (isRunning)
                {
                    beacons.forEach((mac, beacon)
                    {
                        DateTime now = DateTime.now();
                        DateTime when = DateTime.parse(beacon.time);
                        Duration diff = now.difference(when);
                        int diffMus = diff.inMicroseconds;
                        if (diffMus > beaconExpiredMus)
                        {
                            beaconMacAddrToBeRemoved.add(mac);
                        }
                    });

                    if (beaconMacAddrToBeRemoved.length > 0)
                    {
                        beacons.removeWhere((mac, beacon) => beaconMacAddrToBeRemoved.contains(mac));
                    }
                }
            });
        });

        if (!mounted) return;
    }

    /// 點擊返回鍵時跳出警告訊息框
    Future<bool> backExitAlert(BuildContext context)
    {
        /// 取消按鈕
        Widget cancelButton = FlatButton(
            child: Text('取消'),
            onPressed: () {
                Navigator.of(context).pop(false);
            }
        );

        /// 確定按鈕
        Widget submitButton = FlatButton(
            child: Text('確定'),
            onPressed: () {
                Navigator.of(context).pop(true);
            }
        );

        /// 警告訊息框
        AlertDialog alert = AlertDialog(
            title: Text('退出 Beacon Scanner'),
            titleTextStyle: TextStyle(
                color: Colors.blue,
                fontSize: 19,
                fontWeight: FontWeight.bold
            ),
            titlePadding: EdgeInsets.fromLTRB(17.5, 12.5, 17.5, 12.5),
            content: Text('確定離開 Beacon Scanner？'),
            contentPadding: EdgeInsets.fromLTRB(17.5, 12.5, 17.5, 12.5),
            actions: <Widget>[
                cancelButton,
                submitButton
            ]
        );

        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
                return alert;
            }
        );
    }

    @override
    Widget build(BuildContext context)
    {
        return WillPopScope(
            onWillPop: () async => backExitAlert(context),
            child: Scaffold(
                appBar: AppBar(
                    title: InkWell(
                        child: Text('TUT 導覽系統')
                    ),
                    centerTitle: true
                ),
                body: Center(
                    child: Text('台南應用科技大學 校園導覽系統')
                )
            )
        );
    }
}
