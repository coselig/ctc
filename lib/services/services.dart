/// 統一匯出所有服務
/// 使用方式: import 'package:ctc/services/services.dart';
library services;

// ==================== 客戶相關服務 ====================
export 'customer/customer_service.dart';
export 'employee/attendance/attendance_leave_request_service.dart';
// ==================== 出勤相關服務 ====================
export 'employee/attendance/attendance_service.dart';
// ==================== 公司相關服務 ====================
export 'employee/attendance/company_location_service.dart';
export 'employee/attendance/holiday_service.dart';
// ==================== 請假相關服務 ====================
export 'employee/attendance/leave_request_service.dart';
// ==================== 員工相關服務 ====================
export 'employee/employee_general_service.dart';
// ==================== 資料處理服務 ====================
export 'excel_export_service.dart';
export 'floor_plans_service.dart';
// ==================== 權限相關服務 ====================
export 'general/permission_service.dart';
export 'general/registered_user_service.dart';
export 'general/user_permission_service.dart';
export 'general/user_preferences_service.dart';
// ==================== 使用者相關服務 ====================
export 'general/user_service.dart';
export 'image_service.dart';
// ==================== 招募相關服務 ====================
export 'job_vacancy_service.dart';
// ==================== 相片相關服務 ====================
export 'photo_record_system/photo_record_service.dart';
export 'general/photo_upload_service.dart';
