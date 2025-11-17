import 'package:flutter/material.dart';
import '../../../../public/services/auth_service.dart';
import '../../../services/user_service.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> with TickerProviderStateMixin {
  String _userName = 'Usuario';
  final _userService = UserService();
  final _auth = AuthService();
  bool _menuOpen = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _load();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final u = await _userService.getCurrentUser();
      setState(() => _userName = (u['name'] ?? 'Usuario').toString());
    } catch (_) {}
  }

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
    if (_menuOpen) {
      _slideController.forward();
      _insertOverlay();
    } else {
      _slideController.reverse();
      _removeOverlay();
    }
  }

  void _closeSidebar() {
    setState(() => _menuOpen = false);
    _slideController.reverse();
    _removeOverlay();
  }

  void _navigateTo(String route) {
    _closeSidebar();
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1e4d2b), Color(0xFF2d5a3d)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'CertiWeb',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                if (!isMobile) ...[
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
                IconButton(
                  onPressed: _toggleMenu,
                  icon: Icon(
                    _menuOpen ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_menuOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
        
        Positioned(
          top: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: 350,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Column(
              children: [
                // Sidebar header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1e4d2b), Color(0xFF2d5a3d)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Menú',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _closeSidebar,
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),
                // Sidebar content
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Navigation section
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
                        child: Text(
                          'Navegación'.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF666666),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.directions_car,
                        title: 'Vehículos certificados',
                        subtitle: 'Explora vehículos certificados',
                        onTap: () => _navigateTo('/cars'),
                      ),
                      _buildMenuItem(
                        icon: Icons.add_circle,
                        title: 'Certificar vehículo',
                        subtitle: 'Certifica tu vehículo',
                        onTap: () => _navigateTo('/reservation'),
                      ),
                      const Divider(),
                      
                      // Account section
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                        child: Text(
                          'Cuenta'.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF666666),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.person,
                        title: 'Perfil',
                        subtitle: 'Gestiona tu perfil',
                        onTap: () => _navigateTo('/profile'),
                      ),
                      _buildMenuItem(
                        icon: Icons.history,
                        title: 'Historial',
                        subtitle: 'Historial de actividades',
                        onTap: () => _navigateTo('/history'),
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Soporte',
                        subtitle: 'Ayuda y soporte',
                        onTap: () => _navigateTo('/support'),
                      ),
                      _buildMenuItem(
                        icon: Icons.description,
                        title: 'Términos de uso',
                        subtitle: 'Términos y condiciones',
                        onTap: () => _navigateTo('/terms-of-use'),
                      ),
                      const Divider(),
                      
                      // Logout section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildLogoutMenuItem(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1e4d2b),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Color(0xFFCCCCCC),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutMenuItem() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEECCCC), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _auth.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFFE53935),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _insertOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(builder: (context) {
      return Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _closeSidebar,
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.white,
              elevation: 8,
              child: SizedBox(
                width: 350,
                height: MediaQuery.of(context).size.height,
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1e4d2b), Color(0xFF2d5a3d)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16), overflow: TextOverflow.ellipsis),
                          const Text('Menú', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ]),
                      ),
                      IconButton(onPressed: _closeSidebar, icon: const Icon(Icons.close, color: Colors.white), iconSize: 24),
                    ]),
                  ),
                  Expanded(
                    child: ListView(padding: EdgeInsets.zero, children: [
                      Padding(padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8), child: Text('Navegación'.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF666666), letterSpacing: 0.5))),
                      _buildMenuItem(icon: Icons.directions_car, title: 'Vehículos certificados', subtitle: 'Explora vehículos certificados', onTap: () => _navigateTo('/cars')),
                      _buildMenuItem(icon: Icons.add_circle, title: 'Certificar vehículo', subtitle: 'Certifica tu vehículo', onTap: () => _navigateTo('/reservation')),
                      const Divider(),
                      Padding(padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8), child: Text('Cuenta'.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF666666), letterSpacing: 0.5))),
                      _buildMenuItem(icon: Icons.person, title: 'Perfil', subtitle: 'Gestiona tu perfil', onTap: () => _navigateTo('/profile')),
                      _buildMenuItem(icon: Icons.history, title: 'Historial', subtitle: 'Historial de actividades', onTap: () => _navigateTo('/history')),
                      _buildMenuItem(icon: Icons.help_outline, title: 'Soporte', subtitle: 'Ayuda y soporte', onTap: () => _navigateTo('/support')),
                      _buildMenuItem(icon: Icons.description, title: 'Términos de uso', subtitle: 'Términos y condiciones', onTap: () => _navigateTo('/terms-of-use')),
                      const Divider(),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: _buildLogoutMenuItem()),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]);
    });
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
