# 功能清單

## flutter

- 產品型錄&設計圖
- 產品成本計算
- flutter 字體更改  Iansui

    -------

    1. [Iansui-Regular.ttf](https://github.com/ButTaiwan/iansui?utm_source=chatgpt.com)
    2. /assets/fonts/Iansui-Regular.ttf
    3. 打開 pubspec.yaml，加入字體設定

    ```yaml
    flutter:
    fonts:
        - family: Iansui
        fonts:
        - asset: assets/fonts/Iansui-Regular.ttf
    ```

- 在 Flutter 中使用字體

    ```dart
    import 'package:flutter/material.dart';

    void main() {
    runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
        theme: ThemeData(
            fontFamily: 'Iansui', // 全局使用 Iansui
        ),
        home: const Scaffold(
            body: Center(
            child: Text(
                '哈囉！Iansui 字體測試',
                style: TextStyle(fontSize: 30),
            ),
            ),
        ),
        );
    }
    }
    ```

-------

## 其他

- autocad 轉 excel
