import 'package:ctc/widgets/widgets.dart';
import 'package:flutter/material.dart';

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
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(actions: widget.actions),
      body: CompassBackground(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
