import 'package:ctc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GeneralPage extends StatefulWidget {
  final List<Widget> children;
  final List<Widget> actions;
  const GeneralPage({
    super.key,
    required this.children,
    this.actions = const [],
  });

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(actions: widget.actions),
      body: CompassBackground(
        child: Column(
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context).padding.top +
                  AppBar().preferredSize.height +
                  20,
            ),
            ...widget.children,
          ],
        ),
      ),
    );
  }
}
