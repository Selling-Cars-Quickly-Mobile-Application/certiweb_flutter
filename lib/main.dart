import 'package:flutter/material.dart';
import 'public/pages/register/register_page.dart';
import 'certifications/components/dashboard/dashboard_page.dart';
import 'certifications/components/reservation/reservation.dart';
import 'public/pages/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'public/services/auth_service.dart';
import 'certifications/components/admin-certification/admin-certification.dart';
import 'public/pages/login/admin_login_page.dart';
import 'public/pages/profile/profile.dart';
import 'public/pages/info/support.dart';
import 'public/pages/info/terms-of-use.dart';
import 'public/pages/history/history.dart';
import 'public/pages/car-list/CarList.dart';
import 'public/pages/car-detail/CarDetail.dart';
import 'public/pages/car-detail/car_pdf_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CertiWeb',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const _StartupPage(),
      routes: {
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/reservation': (context) => const ReservationPage(),
        '/admin-login': (context) => const AdminLoginPage(),
        '/admin-certification': (context) => const AdminCertificationPage(),
        '/profile': (context) => const ProfilePage(),
        '/history': (context) => const HistoryPage(),
        '/support': (context) => const SupportPage(),
        '/terms-of-use': (context) => const TermsOfUsePage(),
        '/cars': (context) => const CarListPage(),
        '/car-detail': (context) => const CarDetailPage(),
        '/car-pdf': (context) => const CarPdfViewerPage(),
      },
      onGenerateRoute: (settings) {
        //car-detail/:id
        if (settings.name != null && settings.name!.startsWith('/car-detail/')) {
          final id = settings.name!.split('/').last;
          if (id.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => const CarDetailPage(),
              settings: RouteSettings(arguments: {'id': id}),
            );
          }
        }
        return null;
      },
    );
  }
}

class _StartupPage extends StatefulWidget {
  const _StartupPage();

  @override
  State<_StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<_StartupPage> {
  @override
  void initState() {
    super.initState();
    _decideStart();
  }

  Future<void> _decideStart() async {
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();

    final rememberMe = prefs.getBool('rememberMe') ?? false;
    if (!rememberMe) {
      await prefs.remove('authToken');
      await prefs.remove('currentUser');
      await prefs.remove('currentSession');
      await prefs.remove('adminToken');
      await prefs.remove('currentAdmin');
    }
    
    final termsAccepted = prefs.getBool('termsAccepted') ?? false;
    if (!termsAccepted) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/terms-of-use', 
        (route) => false,
        arguments: {'mode': 'accept'}
      );
      return;
    }

    final adminToken = prefs.getString('adminToken');
    final token = prefs.getString('authToken');
    if (!mounted) return;
    if (adminToken != null && adminToken.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/admin-certification');
      return;
    }
    if (token != null) {
      final ok = await AuthService().refreshSession();
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacementNamed(context, '/dashboard');
        return;
      }
    }
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text(widget.title),
      ),
      body: Center(
        
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
