// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';
// import '../../models/user_model.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   UserRole _selectedRole = UserRole.tenant;
//   bool _loading = false;
//   bool _obscure = true;

//   @override
//   void dispose() {
//     _nameCtrl.dispose(); _emailCtrl.dispose();
//     _phoneCtrl.dispose(); _passCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _loading = true);

//     final auth = context.read<AuthService>();
//     final error = await auth.register(
//       name: _nameCtrl.text.trim(),
//       email: _emailCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       password: _passCtrl.text.trim(),
//       role: _selectedRole,
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
//       appBar: AppBar(title: const Text('নতুন Account'), centerTitle: true),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const SizedBox(height: 8),

//               // Role selector
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: color.surfaceVariant,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Row(
//                   children: [
//                     _roleBtn('ভাড়াটিয়া', UserRole.tenant, Icons.person_outline),
//                     _roleBtn('বাড়ীওয়ালা', UserRole.landlord, Icons.home_outlined),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               TextFormField(
//                 controller: _nameCtrl,
//                 decoration: const InputDecoration(labelText: 'পুরো নাম', prefixIcon: Icon(Icons.person_outline)),
//                 validator: (v) => v!.isEmpty ? 'নাম দিন' : null,
//               ),
//               const SizedBox(height: 14),
//               TextFormField(
//                 controller: _emailCtrl,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
//                 validator: (v) => !v!.contains('@') ? 'সঠিক email দিন' : null,
//               ),
//               const SizedBox(height: 14),
//               TextFormField(
//                 controller: _phoneCtrl,
//                 keyboardType: TextInputType.phone,
//                 decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
//                 validator: (v) => v!.length < 11 ? 'সঠিক number দিন' : null,
//               ),
//               const SizedBox(height: 14),
//               TextFormField(
//                 controller: _passCtrl,
//                 obscureText: _obscure,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
//                     onPressed: () => setState(() => _obscure = !_obscure),
//                   ),
//                 ),
//                 validator: (v) => v!.length < 6 ? 'কমপক্ষে ৬ character' : null,
//               ),
//               const SizedBox(height: 32),

//               SizedBox(
//                 width: double.infinity, height: 54,
//                 child: FilledButton(
//                   onPressed: _loading ? null : _register,
//                   style: FilledButton.styleFrom(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                   ),
//                   child: _loading
//                       ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _roleBtn(String label, UserRole role, IconData icon) {
//     final selected = _selectedRole == role;
//     final color = Theme.of(context).colorScheme;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedRole = role),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: selected ? color.primary : Colors.transparent,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 18, color: selected ? Colors.white : color.onSurface.withOpacity(0.6)),
//               const SizedBox(width: 6),
//               Text(label, style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: selected ? Colors.white : color.onSurface.withOpacity(0.6),
//               )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.tenant;
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
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthService>();
    final error = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      role: _selectedRole,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
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
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'নতুন Account',
          style: TextStyle(
              color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
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
                  const SizedBox(height: 12),

                  // ── Role Selector ──
                  Text(
                    'আপনি কে?',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : const Color(0xFFEFF6F1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFFD1E7D9)),
                    ),
                    child: Row(
                      children: [
                        _roleBtn(
                          label: 'ভাড়াটিয়া',
                          role: UserRole.tenant,
                          icon: Icons.person_rounded,
                          primary: primary,
                          isDark: isDark,
                        ),
                        _roleBtn(
                          label: 'বাড়ীওয়ালা',
                          role: UserRole.landlord,
                          icon: Icons.home_rounded,
                          primary: primary,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ব্যক্তিগত তথ্য',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _nameCtrl,
                          label: 'পুরো নাম',
                          icon: Icons.person_outline_rounded,
                          primary: primary,
                          isDark: isDark,
                          validator: (v) =>
                              v!.isEmpty ? 'নাম দিন' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _emailCtrl,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          primary: primary,
                          isDark: isDark,
                          validator: (v) =>
                              !v!.contains('@') ? 'সঠিক email দিন' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _phoneCtrl,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          primary: primary,
                          isDark: isDark,
                          validator: (v) =>
                              v!.length < 11 ? 'সঠিক number দিন' : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'নিরাপত্তা',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 14),
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
                          validator: (v) => v!.length < 6
                              ? 'কমপক্ষে ৬ character'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Register Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _loading ? null : _register,
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
                                Text('Register',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(width: 8),
                                Icon(Icons.check_rounded, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Login link ──
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('আগে থেকেই account আছে? ',
                            style: TextStyle(color: textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Login করুন',
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
    );
  }

  Widget _roleBtn({
    required String label,
    required UserRole role,
    required IconData icon,
    required Color primary,
    required bool isDark,
  }) {
    final selected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white38 : const Color(0xFF6B7280)),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: selected
                      ? Colors.white
                      : (isDark ? Colors.white38 : const Color(0xFF6B7280)),
                ),
              ),
            ],
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