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
      
      // 工作時數 - 確保不顯示負數,取絕對值且最小為0
      final workHours = record.workHours != null
          ? (record.workHours! < 0 ? 0.0 : record.workHours!)
          : 0.0;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(
        workHours,
      );
      
      // 加班時數（超過8小時為加班，且確保不為負數）
      final overtimeHours = workHours > 8.0 ? (workHours - 8.0) 
          : 0.0;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = DoubleCellValue(overtimeHours);
      
      // 狀態 - 標示補打卡記錄
      String status;
      if (record.isManualEntry) {
        // 補打卡記錄
        if (record.checkOutTime == null) {
          status = '補登(未完成)';
        } else if (workHours >= 8.0) {
          status = '補登(正常)';
        } else {
          status = '補登(早退)';
        }
      } else {
        // 正常打卡記錄
        if (record.checkOutTime == null) {
          status = '工作中';
        } else if (workHours >= 8.0) {
          status = '正常';
        } else {
          status = '早退';
        }
      }

      final statusCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
      );
      statusCell.value = TextCellValue(status);

      // 如果是補打卡,設定背景色為黃色提醒
      if (record.isManualEntry) {
        statusCell.cellStyle = CellStyle(
          backgroundColorHex: ExcelColor.yellow,
          bold: true,
        );
      }
      
      // 打卡地點
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
          .value = TextCellValue(record.location ?? '');
      
      // 備註
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
          .value = TextCellValue(record.notes ?? '');
    }
    
    print('打卡記錄工作表完成，共寫入 ${records.length} 筆資料');
    
    // 在底部添加員工統計匯總
    if (records.isNotEmpty) {
      _addEmployeeSummarySection(sheet, records.length, employeeMap);
    }
    
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
      
      // 確保工作時數不為負數
      final workHours = record.workHours != null
          ? (record.workHours! < 0 ? 0.0 : record.workHours!)
          : 0.0;
      stats['totalHours'] += workHours;
      
      // 計算加班時數（確保不為負數）
      if (workHours > 8.0) {
        stats['totalOvertime'] += (workHours - 8.0);
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

    // 合併標題單元格（A到K列）
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryStartRow),
      CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: summaryStartRow),
    );

    // 統計表標題列
    final summaryHeaderRow = summaryStartRow + 2;
    final summaryHeaders = [
      '員工編號',
      '員工姓名',
      '部門',
      '打卡天數',
      '總工作時數',
      '總加班時數',
      '平均每日時數',
      '完整打卡天數',
      '未完整天數',
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

      // 總加班時數 - 使用SUMIF公式加總該員工的加班時數
      // 公式: =SUMIF(B$2:B$[dataRowCount+1], A[rowIndex], H$2:H$[dataRowCount+1])
      final overtimeFormula = FormulaCellValue(
        'SUMIF(B\$2:B\$${dataRowCount + 1},A${rowIndex + 1},H\$2:H\$${dataRowCount + 1})',
      );
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
              )
              .value =
          overtimeFormula;

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

      // 完整打卡天數 - 統計該員工"正常"或"早退"狀態的天數
      // 公式: =COUNTIFS(B$2:B$[dataRowCount+1], A[rowIndex], I$2:I$[dataRowCount+1], "正常") +
      //       COUNTIFS(B$2:B$[dataRowCount+1], A[rowIndex], I$2:I$[dataRowCount+1], "早退")
      final completeDaysFormula = FormulaCellValue(
        'COUNTIFS(B\$2:B\$${dataRowCount + 1},A${rowIndex + 1},I\$2:I\$${dataRowCount + 1},"正常")+COUNTIFS(B\$2:B\$${dataRowCount + 1},A${rowIndex + 1},I\$2:I\$${dataRowCount + 1},"早退")',
      );
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
              )
              .value =
          completeDaysFormula;

      // 未完整天數 - 統計該員工"工作中"狀態的天數
      // 公式: =COUNTIFS(B$2:B$[dataRowCount+1], A[rowIndex], I$2:I$[dataRowCount+1], "工作中")
      final incompleteDaysFormula = FormulaCellValue(
        'COUNTIFS(B\$2:B\$${dataRowCount + 1},A${rowIndex + 1},I\$2:I\$${dataRowCount + 1},"工作中")',
      );
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
              )
              .value =
          incompleteDaysFormula;

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

    // 總加班時數 - SUM公式
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: totalRow))
        .value = FormulaCellValue(
      'SUM(F${summaryHeaderRow + 2}:F${summaryHeaderRow + uniqueEmployees.length + 1})',
    );

    // 平均每日時數 - AVERAGE公式
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: totalRow))
        .value = FormulaCellValue(
      'AVERAGE(G${summaryHeaderRow + 2}:G${summaryHeaderRow + uniqueEmployees.length + 1})',
    );

    // 應用樣式到總計行
    for (var col = 3; col < 7; col++) {
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
