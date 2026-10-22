import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final favCount = ref.watch(favouritesProvider).length;

    return Drawer(
      backgroundColor: isDark ? cs.surfaceContainerLow : cs.surface,
      child: Column(
        children: [
          // ── Branded header ────────────────────────────────────────────────
          authState.when(
            data: (user) => _DrawerHeader(
              displayName: user?.displayName ?? 'Guest',
              email: user?.email ?? 'Not signed in',
              photoUrl: user?.photoURL,
              isGuest: user == null,
            ),
            loading: () => const _DrawerHeader(
              displayName: 'Loading...',
              email: '',
              isGuest: true,
            ),
            error: (_, __) => const _DrawerHeader(
              displayName: 'Guest',
              email: 'Not signed in',
              isGuest: true,
            ),
          ),

          // ── Menu ─────────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              children: [
                // Main
                _SectionLabel('Main'),
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/');
                  },
                ),
                _DrawerItem(
                  icon: Icons.favorite_rounded,
                  label: 'Favourites',
                  badge: favCount > 0 ? '$favCount' : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/favourites');
                  },
                ),
                _DrawerItem(
                  icon: Icons.compare_arrows_rounded,
                  label: 'Compare Packages',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/compare');
                  },
                ),
                _DrawerItem(
                  icon: Icons.speed_rounded,
                  label: 'Speed Test',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/speedtest');
                  },
                ),
                _DrawerItem(
                  icon: Icons.manage_search_rounded,
                  label: 'Find me a Package',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/find-package');
                  },
                ),
                _DrawerItem(
                  icon: Icons.article_rounded,
                  label: 'Blog / Guides',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/blog');
                  },
                ),
                const SizedBox(height: 4),

                // Support
                _SectionLabel('Support'),
                _DrawerItem(
                  icon: Icons.feedback_rounded,
                  label: 'Feedback',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/feedback');
                  },
                ),
                _DrawerItem(
                  icon: Icons.mail_rounded,
                  label: 'Contact Us',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/contact');
                  },
                ),
                const SizedBox(height: 4),

                // App
                _SectionLabel('App'),
                _DrawerItem(
                  icon: Icons.info_rounded,
                  label: 'About',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/about');
                  },
                ),
                _DrawerItem(
                  icon: Icons.privacy_tip_rounded,
                  label: 'Privacy Policy',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/privacy');
                  },
                ),
                _DrawerItem(
                  icon: Icons.description_rounded,
                  label: 'Terms of Service',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/terms');
                  },
                ),
                const SizedBox(height: 4),

                // Dark mode toggle as a styled tile
                _SectionLabel('Appearance'),
                _ToggleTile(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  label: 'Dark Mode',
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.palette_outlined, size: 18, color: cs.onSurfaceVariant),
                          const SizedBox(width: 10),
                          Text(
                            'Accent Color',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            ref.watch(accentColorProvider).label,
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: AppAccentColor.values.map((accent) {
                          final isSelected = ref.watch(accentColorProvider) == accent;
                          final color = isDark ? accent.darkColor : accent.lightColor;
                          return Tooltip(
                            message: accent.label,
                            child: GestureDetector(
                              onTap: () {
                                ref.read(accentColorProvider.notifier).setAccent(accent);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom: auth ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 16 + MediaQuery.of(context).padding.bottom),
            child: authState.when(
              data: (user) => user == null
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/login');
                        },
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Sign In'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  : _DrawerItem(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      onTap: () async {
                        Navigator.of(context).pop();
                        final repo = ref.read(authRepositoryProvider);
                        await repo.signOut();
                        ref.read(favouriteRepositoryProvider).setLoggedIn(false);
                      },
                      isDestructive: true,
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isGuest;

  const _DrawerHeader({
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [cs.primary.withOpacity(0.25), cs.primary.withOpacity(0.08)]
              : [cs.primary.withOpacity(0.14), cs.primary.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App brand
          Row(
            children: [
              Text(
                'PK',
                style: AppTextStyles.titleLarge.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                ' Packages',
                style: AppTextStyles.titleLarge.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // User info
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primaryContainer,
                  border: Border.all(
                    color: cs.primary.withOpacity(0.3),
                    width: 2,
                  ),
                  image: photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl == null
                    ? Icon(
                        isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                        size: 24,
                        color: cs.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 3),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: cs.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    );
  }
}

// ─── Menu item ────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final String? badge;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? AppColors.error : cs.onSurface;
    final iconBg = isDestructive
        ? AppColors.error.withOpacity(isDark ? 0.15 : 0.08)
        : cs.primary.withOpacity(isDark ? 0.12 : 0.07);
    final iconColor = isDestructive ? AppColors.error : cs.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Toggle tile ──────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = cs.primary.withOpacity(isDark ? 0.12 : 0.07);

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: cs.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
