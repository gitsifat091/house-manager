import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final error = await context
        .read<AuthService>()
        .sendPasswordReset(_emailCtrl.text.trim());

    if (mounted) {
      setState(() {
        _loading = false;
        if (error == null) _sent = true;
      });
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password ভুলে গেছি'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
          emailCtrl: _emailCtrl,
          formKey: _formKey,
          loading: _loading,
          onSend: _send,
          color: color,
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final GlobalKey<FormState> formKey;
  final bool loading;
  final VoidCallback onSend;
  final ColorScheme color;

  const _FormView({
    required this.emailCtrl,
    required this.formKey,
    required this.loading,
    required this.onSend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: color.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_reset_rounded,
                size: 46, color: color.primary),
          ),
          const SizedBox(height: 24),

          const Text('Password Reset',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'আপনার registered email দিন।\nসেখানে একটি reset link পাঠানো হবে।',
            style: TextStyle(
                color: color.onSurface.withOpacity(0.6), height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),

          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'example@gmail.com',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email দিন';
              if (!v.contains('@')) return 'সঠিক email দিন';
              return null;
            },
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: loading ? null : onSend,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded),
              label: Text(
                loading ? 'পাঠানো হচ্ছে...' : 'Reset Link পাঠান',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(height: 40),

        // Success icon
        Container(
          width: 100, height: 100,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              size: 52, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 28),

        const Text('Email পাঠানো হয়েছে!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.email_rounded, color: color.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(email,
                    style: TextStyle(
                        color: color.primary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'উপরের email এ একটি reset link পাঠানো হয়েছে।\n\n'
          '১. Email inbox খুলুন\n'
          '২. "Reset your password" email খুঁজুন\n'
          '৩. Link এ click করুন\n'
          '৪. নতুন password দিন',
          style: TextStyle(
              color: color.onSurface.withOpacity(0.7), height: 1.8),
        ),
        const SizedBox(height: 12),
        Text(
          'Spam/Junk folder ও check করুন।',
          style: TextStyle(
              fontSize: 12, color: color.onSurface.withOpacity(0.5)),
        ),
        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Login এ ফিরে যান',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}