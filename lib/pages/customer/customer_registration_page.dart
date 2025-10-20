import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/customer_service.dart';

/// 客戶註冊頁面
/// 新用戶註冊後填寫客戶資料
class CustomerRegistrationPage extends StatefulWidget {
  const CustomerRegistrationPage({super.key});

  @override
  State<CustomerRegistrationPage> createState() => _CustomerRegistrationPageState();
}

class _CustomerRegistrationPageState extends State<CustomerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  late final CustomerService _customerService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService(Supabase.instance.client);
    _loadUserEmail();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserEmail() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      print('_loadUserEmail: 當前用戶 = ${user?.email}');
      if (user?.email != null) {
        _emailController.text = user!.email!;
        print('_loadUserEmail: Email 已設置為 ${user.email}');
      } else {
        print('_loadUserEmail: 用戶沒有 email');
      }
    } catch (e) {
      print('_loadUserEmail 錯誤: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      print('_submitForm: 表單驗證失敗');
      return;
    }

    print('_submitForm: 開始提交表單');
    setState(() => _isLoading = true);

    try {
      print('_submitForm: 呼叫 createCustomer');
      await _customerService.createCustomer(
        name: _nameController.text.trim(),
        company: _companyController.text.trim().isEmpty 
            ? null 
            : _companyController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      print('_submitForm: 客戶創建成功');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('客戶資料建立成功！'),
            backgroundColor: Colors.green,
          ),
        );
        // 返回上一頁或導向客戶主頁
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      print('_submitForm 錯誤: $e');
      print('堆疊追蹤: $stackTrace');
      
      if (mounted) {
        String errorMessage = '建立失敗';
        
        // 解析錯誤訊息
        final errorStr = e.toString();
        if (errorStr.contains('customers" does not exist')) {
          errorMessage = '❌ 資料庫尚未設置\n\n請在 Supabase Dashboard 執行以下步驟：\n'
              '1. 打開 SQL Editor\n'
              '2. 執行 create_customers_table.sql\n'
              '3. 確認 customers 表已創建';
        } else if (errorStr.contains('該用戶已經是客戶')) {
          errorMessage = '您已經是客戶了！';
        } else if (errorStr.contains('電子郵件不能為空')) {
          errorMessage = '請提供有效的電子郵件地址';
        } else if (errorStr.contains('duplicate key')) {
          errorMessage = '此用戶已註冊為客戶';
        } else if (errorStr.contains('foreign key constraint')) {
          errorMessage = '用戶資料異常，請重新登入';
        } else {
          errorMessage = '建立失敗：${errorStr.replaceAll('Exception: ', '')}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: errorStr.contains('customers" does not exist')
                ? SnackBarAction(
                    label: '查看說明',
                    textColor: Colors.white,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('設置說明'),
                          content: const SingleChildScrollView(
                            child: Text(
                              '請按照以下步驟在 Supabase 創建 customers 表：\n\n'
                              '1. 登入 Supabase Dashboard\n'
                              '2. 選擇您的專案\n'
                              '3. 點擊左側 SQL Editor\n'
                              '4. 點擊 New Query\n'
                              '5. 複製 docs/database/create_customers_table.sql 的內容\n'
                              '6. 貼上並點擊 Run\n'
                              '7. 確認執行成功\n\n'
                              '完成後請重新提交表單。',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('知道了'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('完善客戶資料'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 標題說明
                      Text(
                        '歡迎成為我們的客戶',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '請填寫以下資料，以便我們為您提供更好的服務',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(175),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // 姓名（必填）
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '姓名 *',
                          hintText: '請輸入您的姓名',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '請輸入姓名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 公司名稱（選填）
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: '公司名稱',
                          hintText: '請輸入公司名稱（選填）',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 電子郵件
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: '電子郵件 *',
                          hintText: 'email@example.com',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '請輸入電子郵件';
                          }
                          if (!value.contains('@')) {
                            return '請輸入有效的電子郵件';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 電話
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: '聯絡電話',
                          hintText: '0912-345-678',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 地址
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: '地址',
                          hintText: '請輸入地址（選填）',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 備註
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: '備註',
                          hintText: '其他需要說明的事項（選填）',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 提交按鈕
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '完成註冊',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 說明文字
                      Text(
                        '* 為必填欄位',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
