import 'dart:html' as html;
import 'package:excel/excel.dart';

/// 簡單的Excel測試匯出
void testExcelExport() {
  print('========== 測試Excel匯出 ==========');
  
  try {
    // 創建Excel
    var excel = Excel.createExcel();
    
    // 獲取工作表
    var sheet = excel['測試'];
    
    // 方法1: 使用 TextCellValue
    print('測試方法1: TextCellValue');
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('標題1');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('標題2');
    
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('資料1');
    sheet.cell(CellIndex.indexByString('B2')).value = TextCellValue('資料2');
    
    // 方法2: 使用 IntCellValue
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('數字');
    sheet.cell(CellIndex.indexByString('C2')).value = IntCellValue(123);
    
    // 方法3: 使用 DoubleCellValue
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('小數');
    sheet.cell(CellIndex.indexByString('D2')).value = DoubleCellValue(45.67);
    
    print('✓ 單元格已設定');
    
    // 編碼
    final bytes = excel.encode();
    if (bytes == null) {
      print('❌ 編碼失敗');
      return;
    }
    
    print('✓ Excel編碼成功，大小: ${bytes.length} bytes');
    
    // 下載
    final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'test_excel.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    print('✓ 測試Excel已下載');
    
  } catch (e) {
    print('❌ 錯誤: $e');
    print('堆疊追蹤: ${StackTrace.current}');
  }
}
