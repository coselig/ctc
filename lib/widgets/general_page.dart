import 'package:ctc/widgets/widgets.dart';
import 'package:flutter/material.dart';

class GeneralPage extends StatefulWidget {
  final List<Widget> children;
  final List<Widget> actions;
  final String? title;
  const GeneralPage({
    super.key,
    required this.children,
    this.actions = const [],
    this.title,
  });

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  @override
  Widget build(BuildContext context) {
    // 根據主題設定背景色
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE8E0D6);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: TransparentAppBar(
        title: widget.title != null ? Text(widget.title!) : null,
        actions: widget.actions,
      ),
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
              // 添加底部 padding 避免背景不夠延伸
              SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
            ],
          ),
        ),
      ),
    );
  }
}
