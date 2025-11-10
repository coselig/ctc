import 'dart:html' as html;

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'employee/attendance/attendance_service.dart';
import 'employee/attendance/leave_request_service.dart';
import 'employee/employee_general_service.dart';

class ExcelExportService {
  final SupabaseClient supabase;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;
  late final LeaveRequestService _leaveRequestService;

  ExcelExportService(this.supabase) {
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
    _leaveRequestService = LeaveRequestService();
  }

  /// 匯出所有員工的打卡記錄到Excel
  Future<void> exportAllAttendanceRecords({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('========== 開始匯出Excel ==========');

      // 獲取所有員工
      print('正在獲取員工列表...');
      final employees = await _employeeService.getAllEmployees();
      print('✓ 找到 ${employees.length} 位員工');

      if (employees.isEmpty) {
        print('❌ 錯誤：沒有員工資料');
        throw Exception('系統中沒有員工資料');
      }

      // 獲取所有打卡記錄（不分員工，一次性查詢）
      print('正在獲取打卡記錄...');
      print(
        '日期範圍: ${startDate != null ? startDate.toString() : "不限"} ~ ${endDate != null ? endDate.toString() : "不限"}',
      );

      final allRecords = await _attendanceService.getAllAttendanceRecords(
        startDate: startDate,
        endDate: endDate,
      );

      print('✓ 總共找到 ${allRecords.length} 筆打卡記錄');

      if (allRecords.isEmpty) {
        print('⚠️ 警告：沒有打卡記錄（將匯出空白Excel）');
      }

      // 顯示每個員工的記錄數
      final recordsByEmployee = <String, int>{};
      for (final record in allRecords) {
        recordsByEmployee[record.employeeId] =
            (recordsByEmployee[record.employeeId] ?? 0) + 1;
      }

      print('各員工記錄分佈:');
      for (final employee in employees) {
        final count = recordsByEmployee[employee.id] ?? 0;
        print('  - ${employee.name}: $count 筆');
      }

      // 建立員工ID到員工資料的映射
      final employeeMap = {for (var emp in employees) emp.id: emp};

      // 創建Excel檔案
      print('開始創建Excel檔案...');
      var excel = Excel.createExcel();

      // 創建打卡記錄工作表
      _createAttendanceSheet(excel, allRecords, employeeMap);

      // 創建統計摘要工作表
      await _createSummarySheet(
        excel,
        allRecords,
        employeeMap,
        startDate,
        endDate,
      );

      // 不再匯出員工列表工作表
      // _createEmployeeSheet(excel, employees);

      // 刪除預設的空白Sheet1（必須在創建其他工作表之後）
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
        print('✓ 已刪除預設的空白工作表 Sheet1');
      }

      // 下載檔案
      _downloadExcelFile(excel, '打卡記錄匯出');
    } catch (e) {
      print('匯出Excel失敗: $e');
      rethrow;
    }
  }

  /// 匯出單一員工的打卡記錄到Excel
  Future<void> exportEmployeeAttendanceRecords({
    required Employee employee,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('========== 開始匯出個人打卡記錄 ==========');
      print('員工: ${employee.name} (${employee.employeeId})');

      // 獲取該員工的打卡記錄
      print('正在獲取打卡記錄...');
      print(
        '日期範圍: ${startDate != null ? startDate.toString() : "不限"} ~ ${endDate != null ? endDate.toString() : "不限"}',
      );

      final records = await _attendanceService.getAllAttendanceRecords(
        employeeId: employee.id,
        startDate: startDate,
        endDate: endDate,
      );

      print('✓ 找到 ${records.length} 筆打卡記錄');

      if (records.isEmpty) {
        print('⚠️ 警告：沒有打卡記錄（將匯出空白Excel）');
      }

      // 創建Excel檔案
      print('開始創建Excel檔案...');
      var excel = Excel.createExcel();

      // 創建打卡記錄工作表（只有該員工）
      final employeeMap = {employee.id: employee};
      _createAttendanceSheet(excel, records, employeeMap);

      // 刪除預設的空白Sheet1
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
        print('✓ 已刪除預設的空白工作表 Sheet1');
      }

      // 下載檔案
      _downloadExcelFile(excel, '${employee.name}_打卡記錄');
    } catch (e) {
      print('匯出Excel失敗: $e');
      rethrow;
    }
  }

  /// 創建打卡記錄工作表
  void _createAttendanceSheet(
    Excel excel,
    List<AttendanceRecord> records,
    Map<String?, Employee> employeeMap,
  ) {
    print('創建打卡記錄工作表，共 ${records.length} 筆記錄');
    var sheet = excel['打卡記錄'];

    // 設定標題列
    final headers = [
      '日期',
      '員工編號',
      '員工姓名',
      '部門',
      '上班時間',
      '下班時間',
      '工作時數',
      '工時差',
      '備註',
    ];

    print('設定標題列...');

    // 寫入標題
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue200,
        horizontalAlign: HorizontalAlign.Center,
      );
      print('  設定標題[$i]: ${headers[i]}');
    }
    print('標題列已設定');

    // 按日期排序記錄
    if (records.isNotEmpty) {
      records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
      print('記錄已排序');
    } else {
      print('⚠️ 沒有打卡記錄');
    }

    // 寫入資料
    print('開始寫入 ${records.length} 筆資料...');
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final employee = employeeMap[record.employeeId];
      final rowIndex = i + 1;

      print(
        '寫入第 $rowIndex 列: ${employee?.name ?? "未知"} - ${_formatDate(record.checkInTime)}',
      );

      // 日期
      final dateValue = _formatDate(record.checkInTime);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(
        dateValue,
      );
      print('  日期: $dateValue');

      // 員工編號
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(
        employee?.employeeId ?? '',
      );

      // 員工姓名
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(
        employee?.name ?? '未知',
      );

      // 部門
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(
        employee?.department ?? '未設定',
      );

      // 上班時間
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = TextCellValue(
        _formatTime(record.checkInTime),
      );

      // 下班時間
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = TextCellValue(
        record.checkOutTime != null ? _formatTime(record.checkOutTime!) : '未打卡',
      );

      // 工作時數 - 根據上下班時間差計算
      final workHours = _calculateWorkHours(record);
      // 四捨五入到小數點後兩位
      final workHoursRounded = double.parse(workHours.toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(
        workHoursRounded,
      );

      // 工時差（實際工時 - 標準9小時）
      final hoursDiff = workHours - 9.0;
      // 四捨五入到小數點後兩位
      final hoursDiffRounded = double.parse(hoursDiff.toStringAsFixed(2));
      final hoursDiffCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
      );
      hoursDiffCell.value = DoubleCellValue(hoursDiffRounded);
      
      // 根據工時差設定顏色
      if (hoursDiffRounded < 0) {
        // 工時不足，標示為紅色
        hoursDiffCell.cellStyle = CellStyle(
          backgroundColorHex: ExcelColor.red100,
        );
      } else if (hoursDiffRounded > 0) {
        // 工時超過，標示為綠色
        hoursDiffCell.cellStyle = CellStyle(
          backgroundColorHex: ExcelColor.green100,
        );
      }

      // 備註
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
          .value = TextCellValue(
        record.notes ?? '',
      );
    }

    print('打卡記錄工作表完成，共寫入 ${records.length} 筆資料');

    // 在底部添加員工統計匯總
    if (records.isNotEmpty) {
      _addEmployeeSummarySection(sheet, records.length, employeeMap);
    }

    // 設定欄寬
    sheet.setColumnWidth(0, 12); // 日期
    sheet.setColumnWidth(1, 10); // 員工編號
    sheet.setColumnWidth(2, 12); // 員工姓名
    sheet.setColumnWidth(3, 12); // 部門
    sheet.setColumnWidth(4, 10); // 上班時間
    sheet.setColumnWidth(5, 10); // 下班時間
    sheet.setColumnWidth(6, 10); // 工作時數
    sheet.setColumnWidth(7, 10); // 工時差
    sheet.setColumnWidth(8, 30); // 備註
  }

  /// 創建統計摘要工作表
  Future<void> _createSummarySheet(
    Excel excel,
    List<AttendanceRecord> records,
    Map<String?, Employee> employeeMap,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    print('創建統計摘要工作表...');
    var sheet = excel['統計摘要'];

    // 標題
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('員工出勤統計摘要');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
    );

    // 統計每個員工的資料
    final employeeStats = <String, Map<String, dynamic>>{};

    for (final record in records) {
      final employeeId = record.employeeId;
      if (!employeeStats.containsKey(employeeId)) {
        final employee = employeeMap[employeeId];
        employeeStats[employeeId] = {
          'name': employee?.name ?? '未知',
          'department': employee?.department ?? '未設定',
          'employeeNumber': employee?.employeeId ?? '',
          'totalDays': 0,
          'totalHours': 0.0,
          'expectedHours': 0.0, // 預期工時 (打卡天數 * 9小時)
        };
      }

      final stats = employeeStats[employeeId]!;
      stats['totalDays'] += 1;

      // 根據上下班時間差計算工作時數
      final workHours = _calculateWorkHours(record);
      stats['totalHours'] += workHours;

      // 累計預期工時 (每天9小時)
      stats['expectedHours'] += 9.0;
    }

    // 獲取每個員工的請假資料
    final leaveDaysMap = <String, double>{};
    if (startDate != null && endDate != null) {
      for (final employeeId in employeeStats.keys) {
        try {
          final leaveRequests = await _leaveRequestService
              .getEmployeeLeaveRequests(
                employeeId,
                status: LeaveRequestStatus.approved,
                startDate: startDate,
                endDate: endDate,
              );

          double totalLeaveDays = 0.0;
          for (final request in leaveRequests) {
            totalLeaveDays += request.totalDays;
          }
          leaveDaysMap[employeeId] = totalLeaveDays;
        } catch (e) {
          print('獲取員工 $employeeId 請假資料失敗: $e');
          leaveDaysMap[employeeId] = 0.0;
        }
      }
    }

    // 設定標題列
    final headers = ['員工編號', '員工姓名', '部門', '總工作時數', '總工時差', '期間請假天數'];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.green200,
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // 寫入統計資料
    var rowIndex = 3;
    employeeStats.forEach((employeeId, stats) {
      final leaveDays = leaveDaysMap[employeeId] ?? 0.0;

      // 請假時數 = 請假天數 × 9小時
      final leaveHours = leaveDays * 9.0;

      // 調整後的預期工時 = 原預期工時 - 請假時數
      final adjustedExpectedHours = stats['expectedHours'] - leaveHours;

      // 總工時差 = 實際工作時數 - 調整後的預期工時
      final hoursDiff = stats['totalHours'] - adjustedExpectedHours;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(
        stats['employeeNumber'],
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(
        stats['name'],
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(
        stats['department'],
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = DoubleCellValue(
        stats['totalHours'],
      );

      // 工時差，用顏色標示
      final hoursDiffCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
      );
      hoursDiffCell.value = DoubleCellValue(hoursDiff);
      if (hoursDiff < 0) {
        // 工時不足，標示為紅色
        hoursDiffCell.cellStyle = CellStyle(
          backgroundColorHex: ExcelColor.red100,
        );
      } else if (hoursDiff > 0) {
        // 工時超過，標示為綠色
        hoursDiffCell.cellStyle = CellStyle(
          backgroundColorHex: ExcelColor.green100,
        );
      }

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = DoubleCellValue(
        leaveDays,
      );

      rowIndex++;
    });

    // 設定欄寬
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 15);
    }
  }

  /// 在打卡記錄工作表底部添加員工統計匯總（使用Excel公式）
  void _addEmployeeSummarySection(
    Sheet sheet,
    int dataRowCount,
    Map<String?, Employee> employeeMap,
  ) {
    print('添加員工統計匯總區...');

    // 計算起始行（資料列 + 標題列 + 空行）
    final summaryStartRow = dataRowCount + 2;

    // 添加區塊標題
    final titleCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryStartRow),
    );
    titleCell.value = TextCellValue('📊 員工統計匯總');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );

    // 合併標題單元格（A到I列）
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryStartRow),
      CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: summaryStartRow),
    );

    // 統計表標題列
    final summaryHeaderRow = summaryStartRow + 2;
    final summaryHeaders = [
      '員工編號',
      '員工姓名',
      '部門',
      '打卡天數',
      '總工作時數',
      '總工時差',
      '平均每日時數',
    ];

    for (var i = 0; i < summaryHeaders.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: summaryHeaderRow),
      );
      cell.value = TextCellValue(summaryHeaders[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.green200,
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // 獲取唯一的員工列表
    final uniqueEmployees = employeeMap.values.toSet().toList();
    uniqueEmployees.sort((a, b) => a.employeeId.compareTo(b.employeeId));

    print('開始寫入 ${uniqueEmployees.length} 位員工的統計公式...');

    // 為每個員工創建一行統計資料（使用Excel公式）
    for (var i = 0; i < uniqueEmployees.length; i++) {
      final employee = uniqueEmployees[i];
      final rowIndex = summaryHeaderRow + 1 + i;

      // 員工編號
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(
        employee.employeeId,
      );

      // 員工姓名
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(
        employee.name,
      );

      // 部門
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(
        employee.department,
      );

      // 打卡天數 - 使用COUNTIF公式統計該員工的記錄數
      // 公式: =COUNTIF(B$2:B$[dataRowCount+1], A[rowIndex])
      final countFormula = FormulaCellValue(
        'COUNTIF(B\$2:B\$${dataRowCount + 1},A${rowIndex + 1})',
      );
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
              )
              .value =
          countFormula;

      // 總工作時數 - 使用SUMIF公式加總該員工的工作時數
      // 公式: =SUMIF(B$2:B$[dataRowCount+1], A[rowIndex], G$2:G$[dataRowCount+1])
      final workHoursFormula = FormulaCellValue(
        'SUMIF(B\$2:B\$${dataRowCount + 1},A${rowIndex + 1},G\$2:G\$${dataRowCount + 1})',
      );
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
              )
              .value =
          workHoursFormula;

      // 總工時差 - 使用SUMIF公式加總該員工的工時差
      // 公式: =SUMIF(B$2:B$[dataRowCount+1], A[rowIndex], H$2:H$[dataRowCount+1])
      final hoursDiffFormula = FormulaCellValue(
        'SUMIF(B\$2:B\$${dataRowCount + 1},A${rowIndex + 1},H\$2:H\$${dataRowCount + 1})',
      );
      final hoursDiffCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
      );
      hoursDiffCell.value = hoursDiffFormula;

      // 平均每日時數 - 總工作時數除以打卡天數
      // 公式: =IF(D[rowIndex]>0, E[rowIndex]/D[rowIndex], 0)
      final avgFormula = FormulaCellValue(
        'IF(D${rowIndex + 1}>0,E${rowIndex + 1}/D${rowIndex + 1},0)',
      );
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
              )
              .value =
          avgFormula;

      print('  ${employee.name}: 已添加統計公式');
    }

    // 添加總計行
    final totalRow = summaryHeaderRow + uniqueEmployees.length + 1;

    // "總計" 標籤
    final totalLabelCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow),
    );
    totalLabelCell.value = TextCellValue('📈 總計');
    totalLabelCell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.yellow,
    );

    // 合併總計標籤（A到C列）
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow),
    );

    // 總打卡天數 - SUM公式
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow))
        .value = FormulaCellValue(
      'SUM(D${summaryHeaderRow + 2}:D${summaryHeaderRow + uniqueEmployees.length + 1})',
    );

    // 總工作時數 - SUM公式
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: totalRow))
        .value = FormulaCellValue(
      'SUM(E${summaryHeaderRow + 2}:E${summaryHeaderRow + uniqueEmployees.length + 1})',
    );

    // 總工時差 - SUM公式
    final totalHoursDiffCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: totalRow),
    );
    totalHoursDiffCell.value = FormulaCellValue(
      'SUM(F${summaryHeaderRow + 2}:F${summaryHeaderRow + uniqueEmployees.length + 1})',
    );

    // 平均每日時數 - AVERAGE公式
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: totalRow))
        .value = FormulaCellValue(
      'AVERAGE(G${summaryHeaderRow + 2}:G${summaryHeaderRow + uniqueEmployees.length + 1})',
    );

    // 應用樣式到總計行
    for (var col = 3; col <= 6; col++) {
      sheet
          .cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: totalRow),
          )
          .cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.yellow,
      );
    }

    print('✓ 員工統計匯總完成（共 ${uniqueEmployees.length} 位員工 + 總計行）');
  }

  /// 下載Excel檔案
  void _downloadExcelFile(Excel excel, String baseName) {
    print('開始編碼Excel檔案...');

    // 檢查工作表
    print('Excel工作表列表: ${excel.tables.keys.toList()}');
    for (var tableName in excel.tables.keys) {
      final sheet = excel.tables[tableName];
      if (sheet != null) {
        print('工作表 "$tableName": ${sheet.maxRows} 列 x ${sheet.maxColumns} 欄');

        // 檢查前幾個單元格
        if (sheet.maxRows > 0 && sheet.maxColumns > 0) {
          print('  檢查單元格內容:');
          for (
            var row = 0;
            row < (sheet.maxRows < 3 ? sheet.maxRows : 3);
            row++
          ) {
            for (
              var col = 0;
              col < (sheet.maxColumns < 3 ? sheet.maxColumns : 3);
              col++
            ) {
              final cell = sheet.cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
              );
              print('    [$row,$col] = "${cell.value}"');
            }
          }
        }
      }
    }

    final bytes = excel.encode();
    if (bytes == null) {
      print('❌ Excel編碼失敗');
      throw Exception('無法編碼Excel檔案');
    }

    print('✓ Excel檔案大小: ${bytes.length} bytes');

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${baseName}_$timestamp.xlsx';

    print('準備下載檔案: $fileName');

    // 創建Blob並下載
    final blob = html.Blob([
      bytes,
    ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);

    print('✓ Excel檔案已下載');
  }

  /// 格式化日期
  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd').format(dateTime);
  }

  /// 格式化時間
  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// 計算工作時數（根據上下班時間差）
  double _calculateWorkHours(AttendanceRecord record) {
    if (record.checkOutTime == null) {
      return 0.0;
    }

    final duration = record.checkOutTime!.difference(record.checkInTime);
    final hours = duration.inMinutes / 60.0;

    // 確保不為負數
    return hours > 0 ? hours : 0.0;
  }
}
