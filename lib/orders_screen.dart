import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> myOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyOrders();
  }

  // دالة جلب الطلبات من قاعدة البيانات
  Future<void> _fetchMyOrders() async {
    try {
      // نطلب فواتير العميل رقم 1 (للتجربة، لاحقاً نأخذ رقم العميل الحقيقي من تسجيل الدخول)
      final response = await http.get(Uri.parse('https://dodgy-unshaken-gentile.ngrok-free.dev/api/orders/user/1'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          myOrders = data['data']; // تخزين الفواتير الحقيقية
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ خطأ في جلب الطلبات: $e');
      setState(() { isLoading = false; });
    }
  }

  // دالة مساعدة لترجمة وتلوين حالة الطلب القادمة من السيرفر
  Map<String, dynamic> _getStatusDetails(String status) {
    switch (status) {
      case 'pending':
        return {'text': 'قيد الانتظار ⏳', 'color': Colors.orange};
      case 'processing':
        return {'text': 'يتم التجهيز 📦', 'color': Colors.blue};
      case 'on_the_way':
        return {'text': 'في الطريق 🚚', 'color': Colors.purple};
      case 'delivered':
        return {'text': 'تم التوصيل ✅', 'color': Colors.green};
      default:
        return {'text': 'غير معروف', 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('طلباتي السابقة 📜', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : myOrders.isEmpty
              ? const Center(
                  child: Text('لم تقم بأي طلب حتى الآن', style: TextStyle(fontSize: 18, color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: myOrders.length,
                  itemBuilder: (context, index) {
                    final order = myOrders[index];
                    final statusDetails = _getStatusDetails(order['status']);
                    // تنسيق التاريخ القادم من قاعدة البيانات
                    final orderDate = DateTime.parse(order['created_at']).toLocal();
                    final formattedDate = '${orderDate.year}/${orderDate.month}/${orderDate.day}';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // السطر الأول: رقم الطلب وحالته
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('الطلب #${order['id']}', 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: statusDetails['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    statusDetails['text'],
                                    style: TextStyle(color: statusDetails['color'], fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            
                            // السطر الثاني: التاريخ والمبلغ
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(formattedDate, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                Text('${order['total_price']} ل.س', 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
                              ],
                            ),
                            
                            const SizedBox(height: 15),
                            
                            // زر لتتبع الطلب إذا كان في الطريق
                            if (order['status'] == 'on_the_way')
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.map),
                                  label: const Text('تتبع الكابتن المباشر'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('سيتم فتح الخريطة المباشرة...')),
                                    );
                                  },
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}