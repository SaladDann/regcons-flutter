import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _mantenerSesion = false;
  bool _isLoading = false;

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.orange),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white38, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarSesion();
  }

  Future<void> _cargarSesion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuario = prefs.getString('usuario');
      final mantener = prefs.getBool('mantener_sesion') ?? false;

      if (mantener && usuario != null) {
        _usuarioController.text = usuario;
        setState(() => _mantenerSesion = true);

        final sesionActiva = await _authService.verificarSesionActiva();

        if (sesionActiva && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al cargar sesión: $e');
    }
  }

  Future<void> _login() async {
    final username = _usuarioController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _mostrarError('Por favor, complete todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final usuario = await _authService.login(username, password);

      if (usuario != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('mantener_sesion', _mantenerSesion);

        if (_mantenerSesion) {
          await prefs.setString('usuario', username);
        } else {
          await prefs.remove('usuario');
          await prefs.setBool('mantener_sesion', false);
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        _mostrarError('Usuario o contraseña incorrectos');
      }
    } catch (e) {
      _mostrarError('Error de conexión con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/tapiz_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF1A1C2E)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 15, // UX: Sombra más pronunciada
                  color: const Color(
                    0xCC282C44,
                  ), // UX: Color oscuro con mejor opacidad
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo y Título
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icon/icon_regcons.png',
                              height: 50,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.engineering,
                                    size: 50,
                                    color: Colors.orange,
                                  ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'REGCONS',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Lidera tu construcción',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                        const SizedBox(height: 35),

                        // Inputs
                        TextField(
                          controller: _usuarioController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.orange,
                          decoration: _inputDecoration(
                            label: 'Usuario',
                            icon: Icons.person_outline,
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.orange,
                          decoration: _inputDecoration(
                            label: 'Contraseña',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white60,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          enabled: !_isLoading,
                          onSubmitted: (_) => _login(),
                        ),

                        // Checkbox
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.white38,
                          ),
                          child: CheckboxListTile(
                            value: _mantenerSesion,
                            onChanged: _isLoading
                                ? null
                                : (v) => setState(() => _mantenerSesion = v!),
                            title: const Text(
                              'Mantener sesión activa',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            activeColor: Colors.orange,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón Login
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'INICIAR SESIÓN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botón Registrarse
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () =>
                                      Navigator.pushNamed(context, '/register'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(
                                color: Colors.orange,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Olvidé contraseña
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => _mostrarError('Función en desarrollo.'),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
