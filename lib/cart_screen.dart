import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({super.key, required this.cartItems});

  // دالة إرسال الطلب للسيرفر
  Future<void> _submitOrder(BuildContext context, double total) async {
    // تجهيز بيانات الطلب (نفترض أن رقم العميل 1 للتجربة)
    final orderData = {
      'user_id': 1,
      'items': cartItems.map((item) => {
        'product_id': item['id'],
        'quantity_kg': 1 // للتجربة، نعتبر الكمية 1 كيلو لكل منتج
      }).toList()
    };

    try {
      final response = await http.post(
        Uri.parse('https://dodgy-unshaken-gentile.ngrok-free.dev/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      final result = json.decode(response.body);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${result['message']}')),
        );
        Navigator.pop(context); // العودة للرئيسية بعد نجاح الطلب
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ تعذر الاتصال بالسيرفر')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    for (var item in cartItems) {
      totalPrice += double.parse(item['price'].toString());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('سلة المشتريات 🛒', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('السلة فارغة حالياً', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Text(item['image'], style: const TextStyle(fontSize: 30)),
                          title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item['price']} ل.س'),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('المجموع الكلي:', style: TextStyle(color: Colors.grey)),
                          Text('$totalPrice ل.س', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[700])),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: () => _submitOrder(context, totalPrice),
                        child: const Text('تأكيد الطلب', style: TextStyle(fontSize: 18)),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}