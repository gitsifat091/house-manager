// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';

// class ChangePasswordScreen extends StatefulWidget {
//   const ChangePasswordScreen({super.key});

//   @override
//   State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
// }

// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _currentCtrl = TextEditingController();
//   final _newCtrl = TextEditingController();
//   final _confirmCtrl = TextEditingController();
//   bool _loading = false;
//   bool _obscureCurrent = true;
//   bool _obscureNew = true;
//   bool _obscureConfirm = true;

//   @override
//   void dispose() {
//     _currentCtrl.dispose();
//     _newCtrl.dispose();
//     _confirmCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _loading = true);

//     final error = await context.read<AuthService>().changePassword(
//       currentPassword: _currentCtrl.text.trim(),
//       newPassword: _newCtrl.text.trim(),
//     );

//     if (mounted) {
//       setState(() => _loading = false);
//       if (error != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(error), backgroundColor: Colors.red),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Password সফলভাবে পরিবর্তন হয়েছে! ✅'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final color = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Password পরিবর্তন'), centerTitle: true),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const SizedBox(height: 8),

//               // Email info card
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: color.primaryContainer,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: color.primary.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(Icons.lock_outline_rounded,
//                           color: color.primary, size: 22),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Password Update',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: color.primary)),
//                           Text(user.email,
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   color: color.primary.withOpacity(0.7))),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 28),

//               // Current Password
//               _buildLabel('Current Password'),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _currentCtrl,
//                 obscureText: _obscureCurrent,
//                 decoration: InputDecoration(
//                   hintText: 'বর্তমান password দিন',
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureCurrent
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined),
//                     onPressed: () =>
//                         setState(() => _obscureCurrent = !_obscureCurrent),
//                   ),
//                 ),
//                 validator: (v) =>
//                     v!.isEmpty ? 'বর্তমান password দিন' : null,
//               ),
//               const SizedBox(height: 20),

//               // New Password
//               _buildLabel('New Password'),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _newCtrl,
//                 obscureText: _obscureNew,
//                 decoration: InputDecoration(
//                   hintText: 'নতুন password দিন',
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureNew
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined),
//                     onPressed: () =>
//                         setState(() => _obscureNew = !_obscureNew),
//                   ),
//                 ),
//                 validator: (v) {
//                   if (v!.isEmpty) return 'নতুন password দিন';
//                   if (v.length < 6) return 'কমপক্ষে ৬ character';
//                   if (v == _currentCtrl.text) {
//                     return 'নতুন password বর্তমানটার মতো হতে পারবে না';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Confirm New Password
//               _buildLabel('Confirm New Password'),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _confirmCtrl,
//                 obscureText: _obscureConfirm,
//                 decoration: InputDecoration(
//                   hintText: 'নতুন password আবার দিন',
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureConfirm
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined),
//                     onPressed: () =>
//                         setState(() => _obscureConfirm = !_obscureConfirm),
//                   ),
//                 ),
//                 validator: (v) {
//                   if (v!.isEmpty) return 'Password নিশ্চিত করুন';
//                   if (v != _newCtrl.text) return 'Password মিলছে না';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 32),

//               // Password strength indicator
//               if (_newCtrl.text.isNotEmpty)
//                 _PasswordStrength(password: _newCtrl.text),

//               const SizedBox(height: 16),

//               // Submit button
//               SizedBox(
//                 width: double.infinity,
//                 height: 54,
//                 child: FilledButton(
//                   onPressed: _loading ? null : _submit,
//                   style: FilledButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                   ),
//                   child: _loading
//                       ? const SizedBox(
//                           width: 22,
//                           height: 22,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Text('Save Changes',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(text,
//           style: const TextStyle(
//               fontSize: 14, fontWeight: FontWeight.w600)),
//     );
//   }
// }

// class _PasswordStrength extends StatelessWidget {
//   final String password;
//   const _PasswordStrength({required this.password});

//   int get _strength {
//     int score = 0;
//     if (password.length >= 6) score++;
//     if (password.length >= 10) score++;
//     if (password.contains(RegExp(r'[A-Z]'))) score++;
//     if (password.contains(RegExp(r'[0-9]'))) score++;
//     if (password.contains(RegExp(r'[!@#$%^&*]'))) score++;
//     return score;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final strength = _strength;
//     final labels = ['', 'খুব দুর্বল', 'দুর্বল', 'মোটামুটি', 'শক্তিশালী', 'খুব শক্তিশালী'];
//     final colors = [
//       Colors.grey,
//       Colors.red,
//       Colors.orange,
//       Colors.yellow.shade700,
//       Colors.lightGreen,
//       Colors.green,
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: List.generate(5, (i) {
//             return Expanded(
//               child: Container(
//                 height: 4,
//                 margin: const EdgeInsets.only(right: 4),
//                 decoration: BoxDecoration(
//                   color: i < strength
//                       ? colors[strength]
//                       : Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             );
//           }),
//         ),
//         const SizedBox(height: 6),
//         if (strength > 0)
//           Text(
//             'Password strength: ${labels[strength]}',
//             style: TextStyle(
//                 fontSize: 12,
//                 color: colors[strength],
//                 fontWeight: FontWeight.w500),
//           ),
//       ],
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _newCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final error = await context.read<AuthService>().changePassword(
          currentPassword: _currentCtrl.text.trim(),
          newPassword: _newCtrl.text.trim(),
        );

    if (mounted) {
      setState(() => _loading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(error)),
            ]),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Password সফলভাবে পরিবর্তন হয়েছে!'),
            ]),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.read<AuthService>().currentUser!;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── Hero AppBar ──────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: color.primary,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text('Password পরিবর্তন',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.primary, color.primary.withOpacity(0.75)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 36),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2),
                            ),
                            child: const Icon(Icons.lock_reset_rounded,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Form Body ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // ── Security tip card ──
                        _TipCard(color: color),
                        const SizedBox(height: 24),

                        // ── Current Password ──
                        _FieldLabel('বর্তমান Password'),
                        const SizedBox(height: 8),
                        _PassField(
                          controller: _currentCtrl,
                          hint: 'বর্তমান password দিন',
                          obscure: _obscureCurrent,
                          onToggle: () =>
                              setState(() => _obscureCurrent = !_obscureCurrent),
                          validator: (v) =>
                              v!.isEmpty ? 'বর্তমান password দিন' : null,
                          color: color,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),

                        // ── New Password ──
                        _FieldLabel('নতুন Password'),
                        const SizedBox(height: 8),
                        _PassField(
                          controller: _newCtrl,
                          hint: 'নতুন password দিন',
                          obscure: _obscureNew,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          validator: (v) {
                            if (v!.isEmpty) return 'নতুন password দিন';
                            if (v.length < 6) return 'কমপক্ষে ৬ character দিন';
                            if (v == _currentCtrl.text) {
                              return 'নতুন password আগেরটার মতো হতে পারবে না';
                            }
                            return null;
                          },
                          color: color,
                          isDark: isDark,
                        ),

                        // ── Live Strength ──
                        if (_newCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _PasswordStrengthBar(password: _newCtrl.text),
                        ],
                        const SizedBox(height: 20),

                        // ── Confirm Password ──
                        _FieldLabel('Password নিশ্চিত করুন'),
                        const SizedBox(height: 8),
                        _PassField(
                          controller: _confirmCtrl,
                          hint: 'নতুন password আবার দিন',
                          obscure: _obscureConfirm,
                          onToggle: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (v) {
                            if (v!.isEmpty) return 'Password নিশ্চিত করুন';
                            if (v != _newCtrl.text) return 'Password মিলছে না';
                            return null;
                          },
                          color: color,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 32),

                        // ── Submit ──
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: _loading ? null : _submit,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded,
                                          size: 20),
                                      SizedBox(width: 8),
                                      Text('Save Changes',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tip Card ──────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final ColorScheme color;
  const _TipCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tips_and_updates_outlined,
                color: color.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'শক্তিশালী password এ uppercase, number ও special character ব্যবহার করুন।',
              style: TextStyle(
                  fontSize: 12,
                  color: color.primary.withOpacity(0.8),
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2)),
    );
  }
}

// ── Password Field ────────────────────────────────────────────────────────────

class _PassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final ColorScheme color;
  final bool isDark;

  const _PassField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: isDark ? Colors.white30 : Colors.grey.shade400,
            fontSize: 14),
        prefixIcon: Icon(Icons.lock_outline_rounded,
            color: color.primary.withOpacity(0.7), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: isDark ? Colors.white38 : Colors.grey.shade500),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
      ),
    );
  }
}

// ── Password Strength Bar ─────────────────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  int get _score {
    int s = 0;
    if (password.length >= 6) s++;
    if (password.length >= 10) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#$%^&*]'))) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final labels = ['', 'খুব দুর্বল', 'দুর্বল', 'মোটামুটি', 'শক্তিশালী', 'খুব শক্তিশালী'];
    final colors = [
      Colors.grey,
      Colors.red,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.lightGreen,
      Colors.green,
    ];
    final barColor = colors[score];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: i < score ? barColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: barColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              labels[score],
              style: TextStyle(
                  fontSize: 12,
                  color: barColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}