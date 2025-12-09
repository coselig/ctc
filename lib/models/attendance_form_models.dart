import 'package:flutter/material.dart';
import 'attendance_leave_request.dart';
import 'attendance_record.dart';
import 'employee.dart';

/// 補打卡表單模式
enum AttendanceFormMode {
  /// 管理層直接補打卡（立即生效）
  managerDirect,

  /// 員工申請補打卡（需審核）
  employeeRequest,

  /// 代理打卡（管理層為其他員工補打卡）
  proxyAttendance,
}

/// 補打卡表單數據
class AttendanceFormData {
  final DateTime date;
  final String punchType; // 'checkIn', 'checkOut', 'fullDay'
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String location;
  final String reason;
  final String? notes;

  const AttendanceFormData({
    required this.date,
    required this.punchType,
    this.checkInTime,
    this.checkOutTime,
    required this.location,
    required this.reason,
    this.notes,
  });
}

/// 補打卡表單配置
class AttendanceFormConfig {
  final AttendanceFormMode mode;
  final Employee targetEmployee; // 目標員工
  final Employee? currentUser; // 當前操作用戶（代理打卡時使用）
  final AttendanceRecord? existingRecord; // 現有打卡記錄
  final AttendanceLeaveRequest? editingRequest; // 正在編輯的申請
  final DateTime? initialDate; // 初始日期（從月曆選擇時使用）
  final Function(AttendanceFormData) onSubmit;
  final VoidCallback? onCancel;

  const AttendanceFormConfig({
    required this.mode,
    required this.targetEmployee,
    this.currentUser,
    this.existingRecord,
    this.editingRequest,
    this.initialDate,
    required this.onSubmit,
    this.onCancel,
  });

  /// 是否為編輯模式
  bool get isEditing => editingRequest != null;

  /// 標題文字
  String get title {
    switch (mode) {
      case AttendanceFormMode.managerDirect:
        return '手動補打卡';
      case AttendanceFormMode.employeeRequest:
        return isEditing ? '編輯補打卡申請' : '新增補打卡申請';
      case AttendanceFormMode.proxyAttendance:
        return '代理打卡 - ${targetEmployee.name}';
    }
  }

  /// 提交按鈕文字
  String get submitButtonText {
    switch (mode) {
      case AttendanceFormMode.managerDirect:
        return '確認補打卡';
      case AttendanceFormMode.employeeRequest:
        return isEditing ? '更新申請' : '提交補打卡申請';
      case AttendanceFormMode.proxyAttendance:
        return '確認打卡';
    }
  }

  /// 是否顯示提示信息
  bool get showModeHint => mode == AttendanceFormMode.employeeRequest;

  /// 提示信息文字
  String get modeHintText {
    switch (mode) {
      case AttendanceFormMode.managerDirect:
        return '直接補打卡，立即生效';
      case AttendanceFormMode.employeeRequest:
        return '此為員工補打卡申請，提交後需等待管理員審核';
      case AttendanceFormMode.proxyAttendance:
        return '代理打卡，為員工補登打卡記錄';
    }
  }
}
