import 'package:flutter/material.dart';

/// 月份年份選擇器對話框
/// 
/// 用於在應用程式中統一選擇年月的 UI 元件
/// 
/// 使用方式:
/// ```dart
/// final result = await showMonthYearPicker(
///   context: context,
///   initialYear: 2025,
///   initialMonth: 10,
/// );
/// if (result != null) {
///   print('選擇的日期: ${result.year}/${result.month}');
/// }
/// ```
Future<DateTime?> showMonthYearPicker({
  required BuildContext context,
  required int initialYear,
  required int initialMonth,
  bool disableFutureMonths = true,
  int startYear = 2020,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => MonthYearPickerDialog(
      initialYear: initialYear,
      initialMonth: initialMonth,
      disableFutureMonths: disableFutureMonths,
      startYear: startYear,
    ),
  );
}

/// 月份年份選擇器 Widget
class MonthYearPickerDialog extends StatefulWidget {
  /// 初始年份
  final int initialYear;
  
  /// 初始月份
  final int initialMonth;
  
  /// 是否禁用未來的月份（預設為 true）
  final bool disableFutureMonths;
  
  /// 起始年份（預設為 2020）
  final int startYear;

  const MonthYearPickerDialog({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    this.disableFutureMonths = true,
    this.startYear = 2020,
  });

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int selectedYear;
  late int selectedMonth;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;
    selectedMonth = widget.initialMonth;
  }

  /// 檢查月份是否應該被禁用
  bool _isMonthDisabled(int year, int month) {
    if (!widget.disableFutureMonths) return false;
    
    // 如果是未來的月份，則禁用
    if (year > now.year) return true;
    if (year == now.year && month > now.month) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = now.year;
    final years = List.generate(
      currentYear - widget.startYear + 1,
      (index) => currentYear - index,
    );

    return AlertDialog(
      title: const Text('選擇月份'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Row(
          children: [
            // 年份選擇
            Expanded(
              child: Column(
                children: [
                  Text(
                    '年份',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: years.length,
                      itemBuilder: (context, index) {
                        final year = years[index];
                        final isSelected = year == selectedYear;
                        return ListTile(
                          dense: true,
                          title: Text(
                            '$year',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              selectedYear = year;
                              // 如果選擇的月份在新年份中是未來月份，重置為當前月份
                              if (_isMonthDisabled(
                                selectedYear,
                                selectedMonth,
                              )) {
                                selectedMonth = now.month;
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(),
            // 月份選擇
            Expanded(
              child: Column(
                children: [
                  Text(
                    '月份',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final month = index + 1;
                        final isSelected = month == selectedMonth;
                        final isDisabled = _isMonthDisabled(
                          selectedYear,
                          month,
                        );
                        return ListTile(
                          dense: true,
                          enabled: !isDisabled,
                          title: Text(
                            '$month 月',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isDisabled
                                  ? Colors.grey
                                  : isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                          selected: isSelected,
                          onTap: isDisabled
                              ? null
                              : () {
                                  setState(() {
                                    selectedMonth = month;
                                  });
                                },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(DateTime(selectedYear, selectedMonth, 1));
          },
          child: const Text('確認'),
        ),
      ],
    );
  }
}
