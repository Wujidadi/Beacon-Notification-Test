import 'package:ansicolor/ansicolor.dart';

/// 指定 console 訊息的顏色，顏色以 0 ~ 255 RGB 值分別指定（預設值為 RGB 綠色）
String colorMsg(String msg, {int r = 0, int g = 255, int b = 0})
{
    double red = r.toDouble() / 255;
    double green = g.toDouble() / 255;
    double blue = b.toDouble() / 255;

    AnsiPen pen = AnsiPen()..rgb(r: red, g: green, b: blue);

    return pen(msg);
}
