import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';

/// 客戶管理服務
class CustomerService {
  final SupabaseClient _client;

  CustomerService(this._client);

  /// 獲取當前用戶的客戶資料
  Future<Customer?> getCurrentCustomer() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('getCurrentCustomer: 用戶未登入');
        return null;
      }

      print('getCurrentCustomer: 查詢用戶 ${user.id} 的客戶資料');

      final response = await _client
          .from('customers')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      print('getCurrentCustomer: 查詢結果 = $response');

      if (response == null) {
        print('getCurrentCustomer: 找不到客戶資料');
        return null;
      }

      final customer = Customer.fromJson(response);
      print('getCurrentCustomer: 成功獲取客戶資料 - ${customer.name}');
      return customer;
    } catch (e, stackTrace) {
      print('獲取客戶資料失敗詳細錯誤: $e');
      print('堆疊追蹤: $stackTrace');
      // 如果表不存在，返回 null 而不是拋出異常
      if (e.toString().contains('relation "public.customers" does not exist')) {
        print('customers 表尚未創建');
      }
      return null;
    }
  }

  /// 檢查當前用戶是否為客戶
  Future<bool> isCurrentUserCustomer() async {
    final customer = await getCurrentCustomer();
    return customer != null;
  }

  /// 創建客戶資料（註冊流程）
  Future<Customer> createCustomer({
    required String name,
    String? company,
    String? email,
    String? phone,
    String? address,
    String? notes,
  }) async {
    try {
      print('createCustomer: 開始創建客戶資料');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能創建客戶資料');
      }

      print('createCustomer: 當前用戶 ID = ${user.id}');

      // 檢查是否已經有客戶資料
      print('createCustomer: 檢查是否已有客戶資料');
      final existingCustomer = await getCurrentCustomer();
      if (existingCustomer != null) {
        throw Exception('該用戶已經是客戶');
      }

      // 確保有 email
      final customerEmail = email ?? user.email;
      if (customerEmail == null || customerEmail.isEmpty) {
        throw Exception('電子郵件不能為空');
      }

      print('createCustomer: 準備插入資料 - name: $name, email: $customerEmail');

      final newCustomer = Customer(
        userId: user.id,
        name: name,
        company: company,
        email: customerEmail,
        phone: phone,
        address: address,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final jsonData = newCustomer.toJsonForInsert();
      print('createCustomer: 準備插入的 JSON 資料 = $jsonData');

      final response = await _client
          .from('customers')
          .insert(jsonData)
          .select()
          .single();

      print('createCustomer: 插入成功，回應資料 = $response');

      final createdCustomer = Customer.fromJson(response);
      print('createCustomer: 客戶資料創建成功 - ${createdCustomer.name}');
      
      return createdCustomer;
    } catch (e, stackTrace) {
      print('創建客戶資料失敗詳細錯誤: $e');
      print('堆疊追蹤: $stackTrace');
      
      // 提供更友善的錯誤訊息
      if (e.toString().contains('relation "public.customers" does not exist')) {
        throw Exception('資料庫尚未設置客戶表，請先執行 SQL 腳本：docs/database/create_customers_table.sql');
      } else if (e.toString().contains('duplicate key')) {
        throw Exception('該用戶已經是客戶');
      } else if (e.toString().contains('violates foreign key constraint')) {
        throw Exception('用戶 ID 無效或不存在');
      }
      
      rethrow;
    }
  }

  /// 更新客戶資料
  Future<Customer> updateCustomer({
    required String id,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? address,
    String? notes,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能更新客戶資料');
      }

      final updateData = {
        if (name != null) 'name': name,
        if (company != null) 'company': company,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (notes != null) 'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('customers')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return Customer.fromJson(response);
    } catch (e) {
      print('更新客戶資料失敗: $e');
      rethrow;
    }
  }

  /// 獲取所有客戶（僅供員工使用）
  Future<List<Customer>> getAllCustomers() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能查看客戶列表');
      }

      final response = await _client
          .from('customers')
          .select()
          .order('created_at', ascending: false);

      return response.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      print('獲取客戶列表失敗: $e');
      return [];
    }
  }

  /// 根據 ID 獲取客戶資料
  Future<Customer?> getCustomerById(String id) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Customer.fromJson(response);
    } catch (e) {
      print('獲取客戶資料失敗: $e');
      return null;
    }
  }

  /// 根據用戶 ID 獲取客戶資料
  Future<Customer?> getCustomerByUserId(String userId) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Customer.fromJson(response);
    } catch (e) {
      print('根據用戶ID獲取客戶資料失敗: $e');
      return null;
    }
  }

  /// 搜尋客戶（按姓名或公司名稱）
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAllCustomers();
      }

      final response = await _client
          .from('customers')
          .select()
          .or('name.ilike.%$query%,company.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      print('搜尋客戶失敗: $e');
      return [];
    }
  }

  /// 刪除客戶資料（軟刪除 - 實際上是刪除認證帳號，觸發級聯刪除）
  Future<void> deleteCustomer(String id) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能刪除客戶資料');
      }

      // 注意：直接刪除會觸發外鍵級聯刪除
      // 因為 customers.user_id 有 ON DELETE CASCADE
      // 所以刪除 auth.users 會自動刪除 customers 記錄
      await _client.from('customers').delete().eq('id', id);
    } catch (e) {
      print('刪除客戶資料失敗: $e');
      rethrow;
    }
  }
}
