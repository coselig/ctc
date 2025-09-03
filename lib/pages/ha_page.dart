
import 'package:ctc/widgets/ha_page_card.dart';
import 'package:flutter/material.dart';

class HAPage extends StatefulWidget {
  const HAPage({super.key});

  @override
  State<HAPage> createState() => _HAPageState();
}

class _HAPageState extends State<HAPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("test1")),
      body: Container(
        color: Colors.blueGrey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //homeassistant_logo.png
            /*開源整合平台
                啟動智慧生活
                Home Assistant
             */
            HaPageCard(
              title: "",
              subtitle: '''
                開源整合平台
                啟動智慧生活
                Home Assistant''',
              imageName: "homeassistant_logo.png",
            ),
            //homeassistant_phone_dashboard.png
            /*多元設備、一手掌握
                自動化、自定義場景
                成就專屬家庭助理
             */
            HaPageCard(
              title: "",
              subtitle: '''
                多元設備、一手掌握
                自動化、自定義場景
                成就專屬家庭助理''',
              imageName: "homeassistant_phone_dashboard.png",
            ),
          ],
        ),
      ),
    );
  }
}
