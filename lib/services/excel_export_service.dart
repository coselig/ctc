import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/attendance_service.dart';
import '../services/employee_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExcelExportService {
  final SupabaseClient supabase;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;

  ExcelExportService(this.supabase) {
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
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
      final employeeMap = {
        for (var emp in employees) emp.id: emp,
      };

      // 創建Excel檔案
      print('開始創建Excel檔案...');
      var excel = Excel.createExcel();
      
      // 創建打卡記錄工作表
      _createAttendanceSheet(excel, allRecords, employeeMap);
      
      // 創建統計摘要工作表
      _createSummarySheet(excel, allRecords, employeeMap);
      
      // 創建員工列表工作表
      _createEmployeeSheet(excel, employees);
      
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
      '加班時數',
      '狀態',
      '打卡地點',
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
        '寫入第 ${rowIndex} 列: ${employee?.name ?? "未知"} - ${_formatDate(record.checkInTime)}',
      );
      
      // 日期
      final dateValue = _formatDate(record.checkInTime);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(
        dateValue,
      );
      print('  日期: $dateValue');
      
      // 員工編號
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(employee?.employeeId ?? '');
      
      // 員工姓名
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(employee?.name ?? '未知');
      
      // 部門
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(employee?.department ?? '未設定');
      
      // 上班時間
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = TextCellValue(_formatTime(record.checkInTime));
      
      // 下班時間
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = TextCellValue(
            record.checkOutTime != null ? _formatTime(record.checkOutTime!) : '未打卡',
          );
      
      // 工作時數
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(record.workHours ?? 0.0);
      
      // 加班時數（假設超過8小時為加班）
      final overtimeHours = (record.workHours ?? 0.0) > 8.0 
          ? (record.workHours! - 8.0) 
          : 0.0;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = DoubleCellValue(overtimeHours);
      
      // 狀態
      String status;
      if (record.checkOutTime == null) {
        status = '工作中';
      } else if ((record.workHours ?? 0) >= 8.0) {
        status = '正常';
      } else {
        status = '早退';
      }
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
          .value = TextCellValue(status);
      
      // 打卡地點
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
          .value = TextCellValue(record.location ?? '');
      
      // 備註
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
          .value = TextCellValue(record.notes ?? '');
    }
    
    print('打卡記錄工作表完成，共寫入 ${records.length} 筆資料');
    
    // 設定欄寬
    sheet.setColumnWidth(0, 12);  // 日期
    sheet.setColumnWidth(1, 10);  // 員工編號
    sheet.setColumnWidth(2, 12);  // 員工姓名
    sheet.setColumnWidth(3, 12);  // 部門
    sheet.setColumnWidth(4, 10);  // 上班時間
    sheet.setColumnWidth(5, 10);  // 下班時間
    sheet.setColumnWidth(6, 10);  // 工作時數
    sheet.setColumnWidth(7, 10);  // 加班時數
    sheet.setColumnWidth(8, 10);  // 狀態
    sheet.setColumnWidth(9, 30);  // 打卡地點
    sheet.setColumnWidth(10, 30); // 備註
  }

  /// 創建統計摘要工作表
  void _createSummarySheet(
    Excel excel,
    List<AttendanceRecord> records,
    Map<String?, Employee> employeeMap,
  ) {
    print('創建統計摘要工作表...');
    var sheet = excel['統計摘要'];
    
    // 標題
    sheet.cell(CellIndex.indexByString('A1')).value = 
        TextCellValue('員工出勤統計摘要');
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
          'totalOvertime': 0.0,
          'completeDays': 0,
          'incompleteDays': 0,
        };
      }
      
      final stats = employeeStats[employeeId]!;
      stats['totalDays'] += 1;
      stats['totalHours'] += record.workHours ?? 0.0;
      
      if ((record.workHours ?? 0.0) > 8.0) {
        stats['totalOvertime'] += (record.workHours! - 8.0);
      }
      
      if (record.checkOutTime != null) {
        stats['completeDays'] += 1;
      } else {
        stats['incompleteDays'] += 1;
      }
    }
    
    // 設定標題列
    final headers = [
      '員工編號',
      '員工姓名',
      '部門',
      '總打卡天數',
      '完整打卡天數',
      '未完整天數',
      '總工作時數',
      '總加班時數',
      '平均每日時數',
    ];
    
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
      final avgHours = stats['totalDays'] > 0 
          ? stats['totalHours'] / stats['totalDays'] 
          : 0.0;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(stats['employeeNumber']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(stats['name']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(stats['department']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = IntCellValue(stats['totalDays']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = IntCellValue(stats['completeDays']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = IntCellValue(stats['incompleteDays']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(stats['totalHours']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = DoubleCellValue(stats['totalOvertime']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
          .value = DoubleCellValue(avgHours);
      
      rowIndex++;
    });
    
    // 設定欄寬
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 15);
    }
  }

  /// 創建員工列表工作表
  void _createEmployeeSheet(Excel excel, List<Employee> employees) {
    print('創建員工列表工作表，共 ${employees.length} 位員工');
    var sheet = excel['員工列表'];
    
    // 設定標題列
    final headers = [
      '員工編號',
      '姓名',
      '部門',
      '職位',
      '電子郵件',
      '電話',
      '雇用日期',
      '狀態',
    ];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.orange200,
        horizontalAlign: HorizontalAlign.Center,
      );
    }
    
    // 寫入員工資料
    for (var i = 0; i < employees.length; i++) {
      final employee = employees[i];
      final rowIndex = i + 1;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(employee.employeeId);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(employee.name);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(employee.department);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(employee.position);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = TextCellValue(employee.email ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = TextCellValue(employee.phone ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = TextCellValue(_formatDate(employee.hireDate));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = TextCellValue(employee.status.displayName);
    }
    
    // 設定欄寬
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 15);
    }
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
    final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
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
}
