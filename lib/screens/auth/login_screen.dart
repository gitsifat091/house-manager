// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';
// import 'register_screen.dart';
// import 'forgot_password_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   bool _loading = false;
//   bool _obscure = true;

//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _loading = true);

//     final auth = context.read<AuthService>();
//     final error = await auth.login(
//       email: _emailCtrl.text.trim(),
//       password: _passCtrl.text.trim(),
//     );

//     if (mounted) {
//       setState(() => _loading = false);
//       if (error != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(error), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 48),
//                 // Logo / Header
//                 Container(
//                   width: 64, height: 64,
//                   decoration: BoxDecoration(
//                     color: color.primary,
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: const Icon(Icons.home_rounded, color: Colors.white, size: 36),
//                 ),
//                 const SizedBox(height: 24),
//                 Text('স্বাগতম!', style: TextStyle(
//                   fontSize: 28, fontWeight: FontWeight.bold, color: color.onSurface,
//                 )),
//                 const SizedBox(height: 6),
//                 Text('আপনার account এ login করুন', style: TextStyle(
//                   fontSize: 15, color: color.onSurface.withOpacity(0.6),
//                 )),
//                 const SizedBox(height: 40),

//                 // Email
//                 TextFormField(
//                   controller: _emailCtrl,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: Icon(Icons.email_outlined),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.isEmpty) return 'Email দিন';
//                     if (!v.contains('@')) return 'সঠিক email দিন';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Password
//                 TextFormField(
//                   controller: _passCtrl,
//                   obscureText: _obscure,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
//                       onPressed: () => setState(() => _obscure = !_obscure),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.isEmpty) return 'Password দিন';
//                     if (v.length < 6) return 'কমপক্ষে ৬ character';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 32),

//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () => Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => const ForgotPasswordScreen(),
//                     )),
//                     child: Text('Password ভুলে গেছেন?',
//                         style: TextStyle(color: color.primary)),
//                   ),
//                 ),

//                 // Login Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 54,
//                   child: FilledButton(
//                     onPressed: _loading ? null : _login,
//                     style: FilledButton.styleFrom(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                     ),
//                     child: _loading
//                         ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                         : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Register link
//                 Center(
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Account নেই? ', style: TextStyle(color: color.onSurface.withOpacity(0.6))),
//                       GestureDetector(
//                         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
//                         child: Text('Register করুন', style: TextStyle(
//                           color: color.primary, fontWeight: FontWeight.w600,
//                         )),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthService>();
    final error = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _loading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(error)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // ── Logo ──
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, primary.withOpacity(0.75)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.home_rounded,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 28),

                    // ── Title ──
                    Text(
                      'স্বাগতম!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'আপনার account এ login করুন',
                      style: TextStyle(fontSize: 15, color: textSecondary),
                    ),
                    const SizedBox(height: 36),

                    // ── Form Card ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Email field
                          _buildField(
                            controller: _emailCtrl,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            primary: primary,
                            isDark: isDark,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email দিন';
                              if (!v.contains('@')) return 'সঠিক email দিন';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password field
                          _buildField(
                            controller: _passCtrl,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscure,
                            primary: primary,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: textSecondary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password দিন';
                              if (v.length < 6) return 'কমপক্ষে ৬ character';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Forgot password ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                        child: const Text('Password ভুলে গেছেন?',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Login Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _loading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Login',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Register link ──
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Account নেই? ',
                              style: TextStyle(color: textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            ),
                            child: Text(
                              'Register করুন',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primary,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final fieldBg = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFF8FAFB);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: textColor, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor, fontSize: 14),
        prefixIcon: Icon(icon, color: primary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}