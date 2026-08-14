import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'cart_screen.dart';
import 'register_screen.dart';
import 'orders_screen.dart';
import 'driver_dashboard.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AgroApp());
}

class AgroApp extends StatelessWidget {
  const AgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الإمداد الزراعي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green[700],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // ضبط اتجاه التطبيق بالكامل للغة العربية
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      
      // ==========================================
      // نظام المسارات (العمود الفقري للمستقبل)
      // ==========================================
      initialRoute: '/login', // أول شاشة تفتح في التطبيق
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/chat': (context) => const ChatScreen(),
        '/driver_dashboard': (context) => const DriverDashboard(),
      },
    );
  }
}

// ==========================================
// مكعب الشاشة الرئيسية (واجهة عرض المنتجات)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // القائمة التي ستستقبل البيانات من قاعدة البيانات
  List<dynamic> realProducts = [];
  bool isLoading = true; // مؤشر تحميل
  List<Map<String, dynamic>> myCart = [];

  @override
  void initState() {
    super.initState();
    _fetchProductsFromDatabase(); // جلب البيانات فور فتح التطبيق
  }

  // دالة الاتصال بالسيرفر
  Future<void> _fetchProductsFromDatabase() async {
    try {
      // نطلب البيانات من سيرفر الباك إند
      final response = await http.get(Uri.parse('https://dodgy-unshaken-gentile.ngrok-free.dev/api/products'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          realProducts = data['data']; // تخزين المنتجات القادمة من SQL
          isLoading = false; // إيقاف مؤشر التحميل
        });
      }
    } catch (e) {
      print('❌ خطأ في الاتصال بالسيرفر: $e');
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
        title: const Text('طازج من المزرعة 🌿', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen(cartItems: myCart)),
                  );
                },
              ),
              if (myCart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(myCart.length.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                )
            ],
          )
        ],
      ),
      
      // القائمة الجانبية
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              accountName: const Text('العميل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: const Text('0933XXXXXX'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('الرئيسية'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('الملف الشخصي'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('طلباتي السابقة'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('تواصل معنا / المحادثة'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delivery_dining, color: Colors.orange),
              title: const Text('دخول كابتن التوصيل'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/driver_dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      
      // عرض مؤشر تحميل أو شبكة المنتجات الحقيقية
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : realProducts.isEmpty 
          ? const Center(child: Text('لا يوجد منتجات متاحة حالياً'))
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: realProducts.length,
                itemBuilder: (context, index) {
                  final product = realProducts[index];
                  return Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // أيقونة تعبيرية بناءً على التصنيف
                        Text(product['category'] == 'fruits' ? '🍎' : '🥗', style: const TextStyle(fontSize: 50)),
                        const SizedBox(height: 10),
                        Text(product['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('${product['price_per_kg']} ل.س / كغ', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            setState(() {
                              myCart.add({
                                'id': product['id'],
                                'name': product['name'],
                                'price': product['price_per_kg'],
                                'image': product['category'] == 'fruits' ? '🍎' : '🥗',
                              });
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تمت إضافة ${product['name']} للسلة ✅'), duration: const Duration(seconds: 1)),
                            );
                          },
                          child: const Text('أضف للسلة'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ==========================================
// مكعب وهمي (Placeholder) لحجز مكان الشاشات المستقبلية
// ==========================================
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.orange[300]),
            const SizedBox(height: 20),
            Text('شاشة "$title"', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('سيتم تركيب هذا المكعب قريباً 🚀', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة للرئيسية'),
            )
          ],
        ),
      ),
    );
  }
}