import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _selectedPlan;
  final _cardNumber = TextEditingController();
  final _expiryDate = TextEditingController();
  final _cvv = TextEditingController();
  int _step = 0;
  String? _error;
  String? _success;
  final _auth = AuthService();

  static const primaryGreen = Color(0xFF1e4d2b);
  static const primaryGreenDark = Color(0xFF2d6b3f);
  static const accentOrange = Color(0xFFf59e0b);
  static const successGreen = Color(0xFF16a34a);
  static const errorRed = Color(0xFFdc2626);
  static const lightGray = Color(0xFFF9FAFB);
  static const borderGray = Color(0xFFe5e7eb);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _cardNumber.dispose();
    _expiryDate.dispose();
    _cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F0E1),
              Color(0xFFEDE4D1),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryGreen, primaryGreenDark],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Crear Cuenta',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Completa tu registro en 3 sencillos pasos',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                expandedHeight: 200,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildStepIndicator(),
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildStepContent(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Datos personales', 'Plan', 'Pago'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        steps.length,
        (index) => Expanded(
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index <= _step ? primaryGreen : Colors.white,
                  border: Border.all(
                    color: index <= _step ? primaryGreen : borderGray,
                    width: 2,
                  ),
                  boxShadow: index <= _step
                      ? [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 12)]
                      : [],
                ),
                child: Center(
                  child: index < _step
                      ? Icon(Icons.check, color: Colors.white, size: 24)
                      : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: index <= _step ? Colors.white : Color(0xFF64748b),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: index <= _step ? FontWeight.w700 : FontWeight.w500,
                  color: index <= _step ? Color(0xFF1e293b) : Color(0xFF64748b),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_step == 0) _personalForm(),
            if (_step == 1) _planForm(),
            if (_step == 2) _paymentForm(),
            const SizedBox(height: 24),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: errorRed.withOpacity(0.1),
                  border: Border.all(color: errorRed.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: errorRed, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: errorRed, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            if (_success != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.1),
                  border: Border.all(color: successGreen.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: successGreen, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _success!,
                        style: TextStyle(color: successGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prev,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: borderGray, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, size: 18, color: Color(0xFF374151)),
                          const SizedBox(width: 8),
                          Text('Anterior', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _step == 2 ? _submit : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _step == 2 ? 'Completar' : 'Siguiente',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Icon(_step == 2 ? Icons.check : Icons.arrow_forward, size: 18, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_step == 2) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: RichText(
                    text: TextSpan(
                      text: '¿Ya tienes cuenta? ',
                      style: TextStyle(color: Color(0xFF6b7280)),
                      children: [
                        TextSpan(
                          text: 'Inicia sesión',
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _personalForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Datos Personales',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1e293b),
        ),
      ),
      const SizedBox(height: 24),
      _buildTextField(
        controller: _name,
        label: 'Nombre Completo',
        hint: 'Juan Pérez',
        icon: Icons.person_outline,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _email,
        label: 'Correo Electrónico',
        hint: 'correo@ejemplo.com',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _password,
        label: 'Contraseña',
        hint: '••••••••',
        icon: Icons.lock_outline,
        obscureText: true,
      ),
    ],
  );

  Widget _planForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Selecciona un Plan',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1e293b),
        ),
      ),
      const SizedBox(height: 24),
      _buildPlanCard(
        title: 'Free',
        price: 'S/.0.00',
        period: 'Siempre',
        icon: Icons.people_outline,
        features: [
          'Contacta con compradores',
          'Ver catálogo',
        ],
        disabledFeatures: [
          'Sin reservas de auto',
          'Características limitadas',
        ],
        isSelected: _selectedPlan == 'Free',
        onTap: () => setState(() => _selectedPlan = 'Free'),
      ),
      const SizedBox(height: 16),
      _buildPlanCard(
        title: 'Mensual',
        price: 'S/.50',
        period: '/mes',
        icon: Icons.calendar_today_outlined,
        features: [
          'Acceso completo 30 días',
          'Soporte técnico',
          'Actualizaciones incluidas',
        ],
        isSelected: _selectedPlan == 'Mensual',
        onTap: () => setState(() => _selectedPlan = 'Mensual'),
      ),
      const SizedBox(height: 16),
      _buildPlanCard(
        title: 'Anual',
        price: 'S/.250.00',
        period: '/año',
        icon: Icons.event_note_outlined,
        isBest: true,
        features: [
          'Acceso completo 365 días',
          'Soporte prioritario',
          'Actualizaciones incluidas',
          'Características exclusivas',
        ],
        isSelected: _selectedPlan == 'Anual',
        onTap: () => setState(() => _selectedPlan = 'Anual'),
      ),
    ],
  );

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required IconData icon,
    required List<String> features,
    List<String>? disabledFeatures,
    required bool isSelected,
    required VoidCallback onTap,
    bool isBest = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryGreen : borderGray,
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Color(0xFFF0F9F4) : Colors.white,
          boxShadow: isSelected
              ? [BoxShadow(color: primaryGreen.withOpacity(0.15), blurRadius: 20)]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBest)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentOrange, Color(0xFFf97316)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'RECOMENDADO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Row(
              children: [
                Icon(icon, size: 32, color: primaryGreen),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1e293b),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                text: price,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1e293b),
                ),
                children: [
                  TextSpan(
                    text: period,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748b),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: successGreen),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500))),
                ],
              ),
            )),
            if (disabledFeatures != null) ...[
              ...disabledFeatures.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 18, color: errorRed),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature, style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _paymentForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Información de Pago',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1e293b),
        ),
      ),
      const SizedBox(height: 24),
      if (_selectedPlan == 'Free')
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: successGreen.withOpacity(0.1),
            border: Border.all(color: successGreen.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Este plan es gratuito, no se requiere información de pago',
            style: TextStyle(
              color: successGreen,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        )
      else ...[
        _buildTextField(
          controller: _cardNumber,
          label: 'Número de Tarjeta',
          hint: '4532 1234 5678 9010',
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _expiryDate,
                label: 'Fecha de Expiración',
                hint: 'MM/YY',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _cvv,
                label: 'CVV',
                hint: '123',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border.all(color: borderGray),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen del Pago',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1e293b),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Plan seleccionado:', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500)),
                  Text(_selectedPlan ?? '', style: TextStyle(color: Color(0xFF1e293b), fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: borderGray),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: TextStyle(color: Color(0xFF1e293b), fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(
                    _selectedPlan == 'Mensual' ? 'S/.50' : _selectedPlan == 'Anual' ? 'S/.250.00' : 'S/.0.00',
                    style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ],
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Color(0xFF6b7280), size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderGray, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderGray, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryGreen, width: 2),
            ),
            filled: true,
            fillColor: lightGray,
          ),
        ),
      ],
    );
  }

  void _next() {
    setState(() {
      _error = null;
      _success = null;
    });
    _fadeController.reset();

    if (_step == 0) {
      if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty || !_isEmail(_email.text)) {
        setState(() => _error = 'Completa los datos correctamente');
        return;
      }
    } else if (_step == 1) {
      if (_selectedPlan == null) {
        setState(() => _error = 'Selecciona un plan');
        return;
      }
    }

    setState(() => _step++);
    _fadeController.forward();
  }

  void _prev() {
    setState(() {
      _error = null;
      _success = null;
      _step--;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _success = null;
    });
    
    if (_selectedPlan != 'Free' && (_cardNumber.text.isEmpty || _expiryDate.text.isEmpty || _cvv.text.isEmpty)) {
      setState(() => _error = 'Completa la información de pago');
      return;
    }

    final userData = {
      'name': _name.text,
      'email': _email.text,
      'password': _password.text,
      'plan': _selectedPlan
    };

    try {
      final result = await _auth.register(userData);
      if (result['success'] == true) {
        setState(() => _success = 'Registro exitoso');
        if (mounted) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          });
        }
      } else {
        setState(() => _error = (result['message'] ?? 'Registro fallido').toString());
      }
    } catch (e) {
      setState(() => _error = 'Registro fallido');
    }
  }

  bool _isEmail(String s) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
}