import 'package:flutter/material.dart';

class FloorPlanSelectorPage extends StatelessWidget {
  const FloorPlanSelectorPage({
    super.key,
    required this.onFloorPlanSelected,
  });

  final Function(String) onFloorPlanSelected;

  @override
  Widget build(BuildContext context) {
    // 假設我們有多個設計圖
    final floorPlans = [
      {'name': '1樓平面圖', 'asset': 'assets/floorplan.png'},
      {'name': '2樓平面圖', 'asset': 'assets/floorplan2.png'},
      {'name': '3樓平面圖', 'asset': 'assets/floorplan3.png'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇設計圖'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: floorPlans.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => onFloorPlanSelected(floorPlans[index]['asset']!),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.asset(
                      floorPlans[index]['asset']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      floorPlans[index]['name']!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
