import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  
  // متحكمات الحقول لعرض البيانات
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // دالة جلب بيانات المستخدم الحقيقية من السيرفر
  Future<void> _fetchUserData() async {
    try {
      // نطلب بيانات العميل رقم 1 (للتجربة، لاحقاً نأخذ رقم العميل من جلسة الدخول)
      final response = await http.get(Uri.parse('https://dodgy-unshaken-gentile.ngrok-free.dev/api/users/1'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['data'];

        setState(() {
          _nameController.text = user['full_name'];
          _phoneController.text = user['phone_number'];
          _locationController.text = user['location_gps'] ?? 'لم يتم تحديد العنوان'; // إذا لم يكن هناك عنوان
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ خطأ في جلب بيانات الملف الشخصي: $e');
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('الملف الشخصي 👤', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(_nameController.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                
                _buildProfileItem(Icons.person, 'الاسم الكامل', _nameController),
                const SizedBox(height: 15),
                _buildProfileItem(Icons.phone, 'رقم الهاتف', _phoneController),
                const SizedBox(height: 15),
                _buildProfileItem(Icons.location_on, 'العنوان الافتراضي', _locationController),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      // سيتم برمجتها لاحقاً لإرسال التعديلات للسيرفر
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ تم حفظ التعديلات')),
                      );
                    },
                    child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
    );
  }

  // دالة مساعدة لرسم حقول الإدخال
  Widget _buildProfileItem(IconData icon, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}