import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/settings_service.dart';
import '../../../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return ListView(
            children: [

              // ── থিম ──────────────────────────────────────
              _SectionHeader(title: 'থিম ও রং'),

              // Color picker
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'অ্যাপের রং',
                subtitle: _colorName(settings.themeColor),
                trailing: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: settings.themeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                ),
                onTap: () => _showColorPicker(context, settings),
              ),

              // Dark mode
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'ডিসপ্লে মোড',
                subtitle: settings.themeMode == ThemeMode.light
                    ? 'লাইট মোড'
                    : settings.themeMode == ThemeMode.dark
                        ? 'ডার্ক মোড'
                        : 'সিস্টেম ডিফল্ট',
                onTap: () => _showThemeModeSheet(context, settings),
              ),

              // ── নোটিফিকেশন ────────────────────────────
              _SectionHeader(title: 'নোটিফিকেশন'),

              SwitchListTile(
                secondary: Icon(Icons.notifications_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Push Notification',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('ভাড়া ও নোটিশের alerts'),
                value: settings.notificationsEnabled,
                onChanged: (val) => settings.setNotifications(val),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              SwitchListTile(
                secondary: Icon(Icons.payment_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('ভাড়ার reminder',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('মাস শেষে reminder পাবেন'),
                value: settings.notificationsEnabled,
                onChanged: (val) => settings.setNotifications(val),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // ── অ্যাকাউন্ট ────────────────────────────
              _SectionHeader(title: 'অ্যাকাউন্ট'),

              _SettingsTile(
                icon: Icons.lock_reset_rounded,
                title: 'Password পরিবর্তন',
                subtitle: 'Email এ reset link পাঠানো হবে',
                onTap: () => _showPasswordResetSheet(context),
              ),

              _SettingsTile(
                icon: Icons.security_outlined,
                title: 'Two-Factor Authentication',
                subtitle: 'শীঘ্রই আসছে',
                enabled: false,
                onTap: () {},
              ),

              // ── ডেটা ──────────────────────────────────
              _SectionHeader(title: 'ডেটা ও প্রাইভেসি'),

              _SettingsTile(
                icon: Icons.backup_outlined,
                title: 'ডেটা Backup',
                subtitle: 'Firebase এ auto backup চালু আছে',
                enabled: false,
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.file_download_outlined,
                title: 'ডেটা Export',
                subtitle: 'শীঘ্রই আসছে',
                enabled: false,
                onTap: () {},
              ),

              // ── অ্যাপ সম্পর্কে ────────────────────────
              _SectionHeader(title: 'অ্যাপ সম্পর্কে'),

              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Version',
                subtitle: 'House Manager v1.0.0',
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Privacy Policy',
                subtitle: 'আমাদের privacy policy পড়ুন',
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.star_outline_rounded,
                title: 'App রেট করুন',
                subtitle: 'আপনার মতামত দিন',
                onTap: () {},
              ),

              const SizedBox(height: 16),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Logout',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  String _colorName(Color color) {
    for (final opt in SettingsService.themeOptions) {
      if ((opt['color'] as Color).value == color.value) return opt['name'] as String;
    }
    return 'কাস্টম';
  }

  void _showColorPicker(BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('থিমের রং বেছে নিন',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: SettingsService.themeOptions.map((opt) {
                final color = opt['color'] as Color;
                final isSelected = settings.themeColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    settings.setThemeColor(color);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${opt['name']} থিম সেট হয়েছে — restart এ দেখাবে'),
                        backgroundColor: color,
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                        Text(opt['name'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeModeSheet(BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ডিসপ্লে মোড',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _modeOption(context, settings, ThemeMode.light,
                Icons.light_mode_rounded, 'লাইট মোড', 'সবসময় উজ্জ্বল'),
            _modeOption(context, settings, ThemeMode.dark,
                Icons.dark_mode_rounded, 'ডার্ক মোড', 'সবসময় অন্ধকার'),
            _modeOption(context, settings, ThemeMode.system,
                Icons.brightness_auto_rounded, 'সিস্টেম ডিফল্ট', 'ফোনের setting অনুযায়ী'),
          ],
        ),
      ),
    );
  }

  Widget _modeOption(BuildContext context, SettingsService settings,
      ThemeMode mode, IconData icon, String title, String sub) {
    final selected = settings.themeMode == mode;
    final color = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? color.primary : null),
      title: Text(title, style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? color.primary : null)),
      subtitle: Text(sub),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: color.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        settings.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showPasswordResetSheet(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    bool _sending = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Password পরিবর্তন',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${user.email} এ একটি reset link পাঠানো হবে।',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Email এ link আসবে → click করুন → নতুন password দিন।',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _sending
                      ? null
                      : () async {
                          setModalState(() => _sending = true);
                          final error = await context
                              .read<AuthService>()
                              .sendPasswordReset(user.email);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error ??
                                    'Reset link পাঠানো হয়েছে! Email চেক করুন।'),
                                backgroundColor:
                                    error != null ? Colors.red : Colors.green,
                              ),
                            );
                          }
                        },
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                  label: Text(_sending ? 'পাঠানো হচ্ছে...' : 'Reset Link পাঠান'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('আপনি কি logout করতে চান?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('না')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthService>().logout();
            },
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool enabled;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: ListTile(
        enabled: enabled,
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color.primary, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.5))),
        trailing: trailing ??
            Icon(Icons.chevron_right_rounded,
                color: color.onSurface.withOpacity(0.3)),
        onTap: enabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}