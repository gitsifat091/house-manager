import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../services/settings_service.dart';
import '../../../services/auth_service.dart';
import '../auth/change_password_screen.dart';
import '../../../models/user_model.dart'; // UserRole enum এর জন্য

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    final authService = context.read<AuthService>();
    final user = authService.currentUser; // এটা UserModel
    final name = user?.name ?? 'ব্যবহারকারী';
    final email = user?.email ?? '';
    final role = user?.role == UserRole.landlord ? 'বাড়ীওয়ালা' : 'ভাড়াটিয়া';

    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: bg,
          body: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App Bar ──────────────────────────────────
                
                SliverAppBar(
                  expandedHeight: 190,
                  collapsedHeight: 60,
                  pinned: true,
                  backgroundColor: bg,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // ✅ title এখন AppBar এ সরাসরি, FlexibleSpaceBar এ নয়
                  title: Text(
                    'সেটিংস',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: true,
                  flexibleSpace: FlexibleSpaceBar(
                    // ✅ title: null — আর কোনো title নেই এখানে
                    background: _buildProfileBg(
                      primary: primary,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      name: name,
                      email: email,
                      role: role,
                    ),
                  ),
                ),

                // ── Settings Body ─────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── থিম ও রং ──
                      _sectionHeader('🎨  থিম ও রং', textSecondary),
                      _card(cardBg, divider, [
                        _navTile(
                          icon: Icons.palette_outlined,
                          iconBg: primary,
                          title: 'অ্যাপের রং',
                          subtitle: _colorName(settings.themeColor),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          trailing: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: settings.themeColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: settings.themeColor
                                        .withOpacity(0.4),
                                    blurRadius: 6)
                              ],
                            ),
                          ),
                          onTap: () =>
                              _showColorPicker(context, settings),
                        ),
                        _divider(divider),
                        _navTile(
                          icon: settings.themeMode == ThemeMode.dark
                              ? Icons.dark_mode_outlined
                              : settings.themeMode == ThemeMode.light
                                  ? Icons.light_mode_outlined
                                  : Icons.brightness_auto_rounded,
                          iconBg: const Color(0xFF5B4FBF),
                          title: 'ডিসপ্লে মোড',
                          subtitle:
                              settings.themeMode == ThemeMode.light
                                  ? 'লাইট মোড'
                                  : settings.themeMode == ThemeMode.dark
                                      ? 'ডার্ক মোড'
                                      : 'সিস্টেম ডিফল্ট',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () =>
                              _showThemeModeSheet(context, settings),
                        ),
                      ]),

                      const SizedBox(height: 12),

                      // ── নোটিফিকেশন ──
                      _sectionHeader('🔔  নোটিফিকেশন', textSecondary),
                      _card(cardBg, divider, [
                        _switchTile(
                          icon: Icons.notifications_outlined,
                          iconBg: const Color(0xFFD97706),
                          title: 'Push Notification',
                          subtitle: 'ভাড়া ও নোটিশের alerts',
                          value: settings.notificationsEnabled,
                          primary: primary,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onChanged: (v) =>
                              settings.setNotifications(v),
                        ),
                        _divider(divider),
                        _switchTile(
                          icon: Icons.credit_card_outlined,
                          iconBg: const Color(0xFF0891B2),
                          title: 'ভাড়ার Reminder',
                          subtitle: 'মাস শেষে reminder পাবেন',
                          value: settings.notificationsEnabled,
                          primary: primary,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onChanged: (v) =>
                              settings.setNotifications(v),
                        ),
                      ]),

                      const SizedBox(height: 12),

                      // ── অ্যাকাউন্ট ──
                      _sectionHeader('🔐  অ্যাকাউন্ট', textSecondary),
                      _card(cardBg, divider, [
                        _navTile(
                          icon: Icons.lock_outline_rounded,
                          iconBg: primary,
                          title: 'Password পরিবর্তন',
                          subtitle:
                              'Current password দিয়ে নতুন সেট করুন',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ChangePasswordScreen()),
                          ),
                        ),
                        _divider(divider),
                        _navTile(
                          icon: Icons.shield_outlined,
                          iconBg: const Color(0xFF6B7280),
                          title: 'Two-Factor Authentication',
                          subtitle: 'শীঘ্রই আসছে',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          disabled: true,
                          badge: 'শীঘ্রই',
                          onTap: null,
                        ),
                      ]),

                      const SizedBox(height: 12),

                      // ── ডেটা ও প্রাইভেসি ──
                      _sectionHeader(
                          '🗄️  ডেটা ও প্রাইভেসি', textSecondary),
                      _card(cardBg, divider, [
                        _navTile(
                          icon: Icons.cloud_upload_outlined,
                          iconBg: const Color(0xFF6B7280),
                          title: 'ডেটা Backup',
                          subtitle:
                              'Firebase এ auto backup চালু আছে',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          disabled: true,
                          badge: 'Auto',
                          onTap: null,
                        ),
                        _divider(divider),
                        _navTile(
                          icon: Icons.download_outlined,
                          iconBg: const Color(0xFF6B7280),
                          title: 'ডেটা Export',
                          subtitle: 'শীঘ্রই আসছে',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          disabled: true,
                          badge: 'শীঘ্রই',
                          onTap: null,
                        ),
                      ]),

                      const SizedBox(height: 12),

                      // ── অ্যাপ সম্পর্কে ──
                      _sectionHeader(
                          'ℹ️  অ্যাপ সম্পর্কে', textSecondary),
                      _card(cardBg, divider, [
                        _navTile(
                          icon: Icons.info_outline_rounded,
                          iconBg: primary,
                          title: 'Version',
                          subtitle: 'House Manager v1.0.0',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationName: 'House Manager',
                            applicationVersion: 'v1.0.0',
                            applicationIcon: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.home_rounded,
                                  color: Colors.white, size: 32),
                            ),
                            children: const [
                              Text(
                                  'বাড়ি ভাড়া ব্যবস্থাপনার জন্য তৈরি একটি সম্পূর্ণ সমাধান।\n'),
                              Text(
                                  'বাড়ীওয়ালা ও ভাড়াটিয়া উভয়ের জন্য সহজ ও কার্যকর।'),
                            ],
                          ),
                        ),
                        _divider(divider),
                        _navTile(
                          icon: Icons.description_outlined,
                          iconBg: const Color(0xFF0891B2),
                          title: 'Privacy Policy',
                          subtitle: 'আমাদের privacy policy পড়ুন',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => _showPrivacyPolicy(context),
                        ),
                        _divider(divider),
                        _navTile(
                          icon: Icons.star_outline_rounded,
                          iconBg: const Color(0xFFD97706),
                          title: 'App রেট করুন',
                          subtitle: 'আপনার মতামত দিন',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => _showRateDialog(context),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // ── Logout ──
                      GestureDetector(
                        onTap: () => _confirmLogout(context),
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.5),
                                width: 1.5),
                            color: Colors.red
                                .withOpacity(isDark ? 0.08 : 0.04),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded,
                                  color: Colors.red, size: 20),
                              SizedBox(width: 10),
                              Text('Logout',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Profile Background ────────────────────────────────────
  Widget _buildProfileBg({
    required Color primary,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required String name,
    required String email,
    required String role,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
              : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          // padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(email,
                        style: TextStyle(
                            color: textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: primary.withOpacity(0.3),
                            width: 1),
                      ),
                      child: Text(role,
                          style: TextStyle(
                              color: primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── UI Builder Helpers ────────────────────────────────────

  Widget _sectionHeader(String title, Color color) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(title,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      );

  Widget _card(Color bg, Color divColor, List<Widget> children) =>
      Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: children),
      );

  Widget _divider(Color color) => Padding(
        padding: const EdgeInsets.only(left: 70),
        child: Divider(height: 1, color: color),
      );

  Widget _navTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Color textPrimary,
    required Color textSecondary,
    Widget? trailing,
    bool disabled = false,
    String? badge,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: disabled
                      ? iconBg.withOpacity(0.35)
                      : iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: Colors.white
                        .withOpacity(disabled ? 0.6 : 1.0),
                    size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: disabled
                                ? textPrimary.withOpacity(0.4)
                                : textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: textSecondary
                                .withOpacity(disabled ? 0.5 : 1.0),
                            fontSize: 12)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                )
              else if (trailing != null)
                trailing
              else if (!disabled)
                Icon(Icons.chevron_right_rounded,
                    color: textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required Color primary,
    required Color textPrimary,
    required Color textSecondary,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: textSecondary, fontSize: 12)),
                ],
              ),
            ),
            CupertinoSwitch(
              value: value,
              activeColor: primary,
              onChanged: onChanged,
            ),
          ],
        ),
      );

  // ── Working Functions ─────────────────────────────────────

  String _colorName(Color color) {
    for (final opt in SettingsService.themeOptions) {
      if ((opt['color'] as Color).value == color.value) {
        return opt['name'] as String;
      }
    }
    return 'কাস্টম';
  }

  void _showColorPicker(BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('থিমের রং বেছে নিন',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: SettingsService.themeOptions.map((opt) {
                final color = opt['color'] as Color;
                final isSelected =
                    settings.themeColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    settings.setThemeColor(color);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${opt['name']} থিম সেট হয়েছে — restart এ দেখাবে'),
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
                          color: isSelected
                              ? Colors.white
                              : Colors.transparent,
                          width: 3),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8)
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20),
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

  void _showThemeModeSheet(
      BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ডিসপ্লে মোড',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _modeOption(context, settings, ThemeMode.light,
                Icons.light_mode_rounded, 'লাইট মোড', 'সবসময় উজ্জ্বল'),
            _modeOption(context, settings, ThemeMode.dark,
                Icons.dark_mode_rounded, 'ডার্ক মোড', 'সবসময় অন্ধকার'),
            _modeOption(
                context,
                settings,
                ThemeMode.system,
                Icons.brightness_auto_rounded,
                'সিস্টেম ডিফল্ট',
                'ফোনের setting অনুযায়ী'),
          ],
        ),
      ),
    );
  }

  Widget _modeOption(
      BuildContext context,
      SettingsService settings,
      ThemeMode mode,
      IconData icon,
      String title,
      String sub) {
    final selected = settings.themeMode == mode;
    final color = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? color.primary : null),
      title: Text(title,
          style: TextStyle(
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? color.primary : null)),
      subtitle: Text(sub),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: color.primary)
          : null,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      onTap: () {
        settings.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    final auth = context.read<AuthService>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout করবেন?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content:
            const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            child: const Text('হ্যাঁ, Logout'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            const Text('Privacy Policy',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: const [
                  _PolicySection(
                      title: '১. তথ্য সংগ্রহ',
                      body: 'আমরা আপনার নাম, ফোন নম্বর, ইমেইল এবং NID নম্বর সংগ্রহ করি। এই তথ্যগুলো শুধুমাত্র বাড়ি ভাড়া ব্যবস্থাপনার জন্য ব্যবহার করা হয়।'),
                  _PolicySection(
                      title: '২. তথ্য ব্যবহার',
                      body: 'সংগৃহীত তথ্য ভাড়াটিয়া ও বাড়ীওয়ালার মধ্যে যোগাযোগ এবং পেমেন্ট ট্র্যাকিংয়ের জন্য ব্যবহৃত হয়। তৃতীয় পক্ষের সাথে কোনো তথ্য শেয়ার করা হয় না।'),
                  _PolicySection(
                      title: '৩. তথ্য সুরক্ষা',
                      body: 'আপনার সকল তথ্য Firebase এর নিরাপদ সার্ভারে এনক্রিপ্টেড আকারে সংরক্ষিত হয়। আমরা industry-standard security practices অনুসরণ করি।'),
                  _PolicySection(
                      title: '৪. তথ্য মুছে ফেলা',
                      body: 'আপনি যেকোনো সময় আপনার অ্যাকাউন্ট মুছে ফেলার অনুরোধ করতে পারেন। অ্যাকাউন্ট মুছলে সকল ব্যক্তিগত তথ্য স্থায়ীভাবে মুছে যাবে।'),
                  _PolicySection(
                      title: '৫. যোগাযোগ',
                      body: 'Privacy সংক্রান্ত যেকোনো প্রশ্নের জন্য আমাদের সাথে যোগাযোগ করুন।'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    int rating = 0;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('App রেট করুন',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('House Manager কেমন লাগলো?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () =>
                        setDialogState(() => rating = i + 1),
                  ),
                ),
              ),
              if (rating > 0) ...[
                const SizedBox(height: 8),
                Text(
                  rating == 5
                      ? 'অসাধারণ! 🎉'
                      : rating == 4
                          ? 'খুব ভালো! 😊'
                          : rating == 3
                              ? 'মোটামুটি 🙂'
                              : rating == 2
                                  ? 'উন্নতি দরকার 😐'
                                  : 'হতাশাজনক 😞',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('পরে'),
            ),
            if (rating > 0)
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('ধন্যবাদ আপনার মতামতের জন্য! 🙏'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Submit'),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Widget ───────────────────────────────────────────

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                  height: 1.6)),
        ],
      ),
    );
  }
}