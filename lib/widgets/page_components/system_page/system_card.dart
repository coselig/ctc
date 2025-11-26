import 'dart:math';

import 'package:flutter/material.dart';

class SystemCard extends StatelessWidget {
  const SystemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.page,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double minSide = min(constraints.maxWidth, constraints.maxHeight);
        double iconSize = min(48, minSide * 0.3);
        double padding = min(16, minSide * 0.1);
        double spacing = min(8, minSide * 0.07);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // 根據 page widget 類型對應到 route 名稱
              String? routeName;
              final type = page.runtimeType.toString();
              switch (type) {
                case 'AttendancePage':
                  routeName = '/attendance';
                  break;
                case 'AttendanceStatsPage':
                  routeName = '/attendanceStats';
                  break;
                case 'PhotoRecordPage':
                  routeName = '/photoRecord';
                  break;
                case 'ProjectManagementPage':
                  routeName = '/projectManagement';
                  break;
                case 'UploadPdfPage':
                  routeName = '/uploadPdf';
                  break;
                case 'UploadAssetPage':
                  routeName = '/uploadAsset';
                  break;
                case 'EmployeeManagementPage':
                  routeName = '/employeeManagement';
                  break;
                case 'HRReviewPage':
                  routeName = '/hrReview';
                  break;
                default:
                  // fallback: 仍然用原本方式
                  routeName = null;
              }
              if (routeName != null) {
                Navigator.of(context).pushNamed(routeName);
              } else {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => page));
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: iconSize, color: color),
                ),
                SizedBox(height: spacing),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget _buildSystemCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required Widget page,
//   }) {
//     double x = sqrt(
//       sqrt(
//         pow(MediaQuery.of(context).size.width * 0.1, 2) +
//             pow(MediaQuery.of(context).size.height * 0.1, 2),
//       ),
//     );
//     return Card(
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: () {
//           Navigator.of(
//             context,
//           ).push(MaterialPageRoute(builder: (context) => page));
//         },
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(x),
//               decoration: BoxDecoration(
//                 color: color.withAlpha(25),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, size: 3 * x, color: color),
//             ),
//             SizedBox(height: 0.2 * x),
//             Text(
//               title,
//               style: Theme.of(
//                 context,
//               ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: Theme.of(
//                 context,
//               ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }