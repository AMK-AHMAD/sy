import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool isOnline = true;
  bool isLoading = true;
  List<dynamic> availableOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableOrders();
  }

  // دالة لجلب الطلبات المتاحة للتوصيل من السيرفر
  Future<void> _fetchAvailableOrders() async {
    setState(() { isLoading = true; });
    try {
      // في نظام حقيقي، سنقوم بإنشاء مسار (Route) في الباك إند مخصص لجلب الطلبات التي تحتاج توصيل
      // وبما أننا لم نقم ببرمجة مسار مخصص للسائق في Backend بعد، سنقوم بحيلة ذكية:
      // سنجلب جميع طلبات العميل رقم 1، ونفلترها هنا لنعرض فقط الطلبات "قيد الانتظار" (pending)
      final response = await http.get(Uri.parse('https://dodgy-unshaken-gentile.ngrok-free.dev/api/orders/user/1'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // فلترة الطلبات: عرض الطلبات المتاحة فقط للسائق
        List<dynamic> allOrders = data['data'];
        List<dynamic> pendingOrders = allOrders.where((order) => order['status'] == 'pending' || order['status'] == 'processing').toList();

        setState(() {
          availableOrders = pendingOrders;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ خطأ في جلب طلبات السائق: $e');
      setState(() { isLoading = false; });
    }
  }

  // دالة لتغيير حالة الطلب إلى "في الطريق"
  Future<void> _acceptOrder(int orderId) async {
    try {
      final response = await http.put(
        Uri.parse('https://dodgy-unshaken-gentile.ngrok-free.dev/api/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': 'on_the_way',
          'driver_id': 2 // نفترض أن رقم السائق هو 2
        }),
      );

      final result = json.decode(response.body);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم قبول الطلب! توجه للعميل الآن')),
        );
        // تحديث القائمة لإزالة الطلب الذي تم قبوله
        _fetchAvailableOrders(); 
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ تعذر قبول الطلب')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        title: const Text('لوحة الكابتن 🛵', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Row(
            children: [
              Text(isOnline ? 'متاح' : 'مشغول', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Switch(
                value: isOnline,
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.black26,
                onChanged: (value) {
                  setState(() {
                    isOnline = value;
                    if (isOnline) _fetchAvailableOrders(); // تحديث الطلبات عند العودة للعمل
                  });
                },
              ),
            ],
          )
        ],
      ),
      body: !isOnline
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.snooze, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text('أنت الآن في وضع "مشغول"', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  const Text('قم بتفعيل حسابك لاستقبال طلبات جديدة'),
                ],
              ),
            )
          : isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : availableOrders.isEmpty
                  ? const Center(child: Text('لا يوجد طلبات متاحة للتوصيل حالياً', style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: availableOrders.length,
                      itemBuilder: (context, index) {
                        final order = availableOrders[index];
                        // تفاصيل وهمية للعميل في الوقت الحالي لأن جدول الطلبات لا يحتوي تفاصيل العنوان
                        final customerName = 'العميل رقم ${order['user_id']}';
                        const deliveryFee = '2500 ل.س'; // أجرة توصيل افتراضية

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.orange[200]!, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('طلب جديد: #${order['id']}', 
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        deliveryFee,
                                        style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.grey, size: 20),
                                    const SizedBox(width: 8),
                                    Text(customerName, style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.receipt_long, color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Text('قيمة الفاتورة: ${order['total_price']} ل.س'),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[600],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('قبول الطلب'),
                                        onPressed: () => _acceptOrder(order['id']),
                                      ),
                                    ),
                                  ],
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