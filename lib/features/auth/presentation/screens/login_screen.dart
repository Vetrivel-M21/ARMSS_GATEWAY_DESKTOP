import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device_auth/device_account_binding_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/updates/app_update_service.dart';
import '../../../portal_auth/presentation/controllers/portal_auth_controllers.dart';
import '../../../portal_auth/presentation/screens/portal_forgot_password_screen.dart';
import '../../../portal_auth/presentation/screens/portal_register_screen.dart';

/// The one login screen for the whole app. Local ledger accounts (username)
/// and self-registered portal accounts (email) both log in here: local login
/// is tried first, and only falls back to a portal-account login if that
/// fails — a person only ever has one or the other.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isCapsLockOn = false;
  String? _errorMessage;
  BoundAccount? _boundAccount;

  @override
  void initState() {
    super.initState();
    _checkBoundAccount();
    _checkInitialCapsLock();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  void _checkInitialCapsLock() {
    try {
      final isCaps = HardwareKeyboard.instance.lockModesEnabled.contains(KeyboardLockMode.capsLock);
      if (isCaps != _isCapsLockOn) {
        setState(() => _isCapsLockOn = isCaps);
      }
    } catch (_) {}
  }

  bool _handleKeyEvent(KeyEvent event) {
    try {
      final isCaps = HardwareKeyboard.instance.lockModesEnabled.contains(KeyboardLockMode.capsLock);
      if (isCaps != _isCapsLockOn && mounted) {
        setState(() => _isCapsLockOn = isCaps);
      }
    } catch (_) {}
    return false;
  }

  Future<void> _checkBoundAccount() async {
    final bindingService = ref.read(deviceAccountBindingServiceProvider);
    final bound = await bindingService.getBoundAccount();
    if (mounted && bound != null) {
      setState(() {
        _boundAccount = bound;
        if (_usernameController.text.trim().isEmpty) {
          _usernameController.text = bound.displayName;
        }
      });
    }

    // Set initial autofocus: focus password if username is already filled, else username
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_boundAccount != null || _usernameController.text.trim().isNotEmpty) {
        _passwordFocusNode.requestFocus();
      } else {
        _usernameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final identifier = _usernameController.text.trim();
    final password = _passwordController.text;

    // Check device binding
    final bindingService = ref.read(deviceAccountBindingServiceProvider);
    final isAllowed = await bindingService.isIdentifierAllowed(identifier);
    if (!isAllowed) {
      final bound = await bindingService.getBoundAccount();
      final name = bound?.displayName ?? 'another account';
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'This device is registered to "$name". To switch accounts, please release the device lock in the Admin Portal.';
      });
      return;
    }

    final portalResult = await ref
        .read(portalSessionControllerProvider.notifier)
        .login(identifier: identifier, password: password);

    if (portalResult.isSuccess) {
      return; // portal login succeeded — MisApp reacts to portalSessionControllerProvider
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _errorMessage = portalResult.errorOrNull?.message ?? 'Invalid username/email or password.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg = AppColors.canvasOf(context);

    return Scaffold(
      backgroundColor: surfaceBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 800;

          if (isCompact) {
            return Stack(
              children: [
                _buildCompactLayout(context, isDark),
                _buildTopThemeToggle(context, isDark),
              ],
            );
          }

          return Stack(
            children: [
              Row(
                children: [
                  // Left panel (~45% width): dark navy brand showcase
                  Expanded(
                    flex: 45,
                    child: _buildLeftBrandPanel(context),
                  ),

                  // Right panel (~55% width): form container
                  Expanded(
                    flex: 55,
                    child: _buildRightFormPanel(context, isDark, showLogoOnTop: false),
                  ),
                ],
              ),
              _buildTopThemeToggle(context, isDark),
            ],
          );
        },
      ),
    );
  }

  /// Theme toggle positioned at top-right
  Widget _buildTopThemeToggle(BuildContext context, bool isDark) {
    return Positioned(
      top: 16,
      right: 20,
      child: Tooltip(
        message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 18,
                color: AppColors.inkPrimaryOf(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Compact single-column layout for window width < 800px
  Widget _buildCompactLayout(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? AppColors.darkSurfacePanel : Colors.white;
    final borderColor = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.35)
                                      : const Color(0xFF0F172A).withValues(alpha: 0.07),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                            child: _buildLoginForm(context, isDark, showLogoOnTop: true),
                          ),
                          const SizedBox(height: 24),
                          _buildTrustRow(context, isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildFooter(context, isDark, showVersion: true),
      ],
    );
  }

  /// Left panel (~45%): Dark navy gradient with enlarged logo, tagline, and feature bullets
  Widget _buildLeftBrandPanel(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E1B4B), // Nav rail deep indigo/navy
            Color(0xFF0B1120), // Midnight black-blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle soft radial gradient background shape (top-left)
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentIndigo.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Subtle soft radial gradient background shape (bottom-right)
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Decorative faint grid lines
          Positioned.fill(
            child: CustomPaint(
              painter: _FaintGridPainter(
                color: Colors.white.withValues(alpha: 0.03),
                step: 40,
              ),
            ),
          ),

          // Foreground Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo enlarged by ~20% in crisp white rounded tile
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/login_logo.png',
                      height: 86,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // App Title
                  const Text(
                    'ARMSS Gateway',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    'Think Different Think Money',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navRailDarkText.withValues(alpha: 0.9),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Three feature bullets
                  _buildBrandFeatureRow(
                    Icons.check_circle_outline_rounded,
                    'One sign-in for all ARMSS portals',
                  ),
                  const SizedBox(height: 12),
                  _buildBrandFeatureRow(
                    Icons.shield_outlined,
                    'Role-based portal access',
                  ),
                  const SizedBox(height: 12),
                  _buildBrandFeatureRow(
                    Icons.devices_rounded,
                    'Device-protected accounts',
                  ),
                ],
              ),
            ),
          ),

          // Version number in left side bottom
          Positioned(
            bottom: 20,
            left: 28,
            child: FutureBuilder<String>(
              future: getCurrentAppVersion(),
              initialData: currentAppVersion,
              builder: (context, snapshot) {
                final version = snapshot.data ?? currentAppVersion;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'v$version',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.55),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Single feature bullet in left brand panel
  Widget _buildBrandFeatureRow(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFFA5B4FC),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.88),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  /// Right panel (~55%): Centered card with subtle indigo background blobs & dot grid
  Widget _buildRightFormPanel(BuildContext context, bool isDark, {required bool showLogoOnTop}) {
    final surfaceColor = isDark ? AppColors.darkSurfacePanel : Colors.white;
    final borderColor = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Subtle background decoration 1: Top-Right soft indigo blob
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        isDark
                            ? const Color(0xFF4F46E5).withValues(alpha: 0.09)
                            : const Color(0xFF6366F1).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Subtle background decoration 2: Bottom-Left soft indigo blob
              Positioned(
                bottom: -80,
                left: -60,
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        isDark
                            ? const Color(0xFF6366F1).withValues(alpha: 0.07)
                            : const Color(0xFF818CF8).withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Faint dot grid decoration
              Positioned.fill(
                child: CustomPaint(
                  painter: _FaintDotGridPainter(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.025)
                        : Colors.black.withValues(alpha: 0.02),
                    step: 32,
                  ),
                ),
              ),

              // Vertically & Horizontally centered Form Card & Trust Row
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 56,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. Form Card
                              Container(
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderColor, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withValues(alpha: 0.35)
                                          : const Color(0xFF0F172A).withValues(alpha: 0.07),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withValues(alpha: 0.15)
                                          : const Color(0xFF0F172A).withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(38),
                                child: _buildLoginForm(context, isDark, showLogoOnTop: showLogoOnTop),
                              ),

                              const SizedBox(height: 24),

                              // 2. Trust Row & Help Text
                              _buildTrustRow(context, isDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        _buildFooter(context, isDark, showVersion: false),
      ],
    );
  }

  /// Trust items and help line below the card
  Widget _buildTrustRow(BuildContext context, bool isDark) {
    final textColor = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
    final iconColor = isDark ? const Color(0xFFA5B4FC) : AppColors.accentIndigo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            _buildTrustBadge(Icons.verified_user_outlined, 'Secure sign-in', iconColor, textColor),
            _buildTrustBadge(Icons.devices_rounded, 'Device-protected', iconColor, textColor),
            _buildTrustBadge(Icons.history_rounded, 'Activity logged', iconColor, textColor),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Having trouble signing in? Contact your administrator.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadge(IconData icon, String label, Color iconColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  /// The core login form
  Widget _buildLoginForm(BuildContext context, bool isDark, {required bool showLogoOnTop}) {
    final isLocked = _boundAccount != null;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo when compact / stacked
          if (showLogoOnTop) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  'assets/images/login_logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Form Header (enlarged to 30px)
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.inkPrimaryOf(context),
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to your ARMSS Gateway account',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.inkSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 26),

          // Device-lock notice banner (when bound account exists)
          if (isLocked) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2640)
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accentIndigo.withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.lock_person_rounded,
                      size: 20,
                      color: AppColors.accentIndigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This device is registered to ${_boundAccount!.displayName}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFA5B4FC)
                                : const Color(0xFF3730A3),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Only this account can sign in here. Contact your administrator to change it.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkInkSecondary
                                : AppColors.inkSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Username Field
          TextFormField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            decoration: InputDecoration(
              labelText: 'Username or Email',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkInkSecondary : const Color(0xFF374151),
              ),
              floatingLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accentIndigo,
              ),
              hintText: 'Enter your username or email',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
              ),
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                size: 19,
                color: isLocked
                    ? AppColors.accentIndigo
                    : (isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary),
              ),
              filled: true,
              fillColor: isLocked
                  ? (isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F3F9))
                  : (isDark ? AppColors.darkSurfacePanel : Colors.white),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkLineHairline : AppColors.lineHairline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.accentIndigo,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.signalError,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.signalError,
                  width: 1.8,
                ),
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Username or email is required' : null,
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 18),

          // Password Field
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkInkSecondary : const Color(0xFF374151),
              ),
              floatingLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accentIndigo,
              ),
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 19,
                color: isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary,
              ),
              suffixIcon: Semantics(
                label: _obscurePassword ? 'Show password' : 'Hide password',
                button: true,
                child: Tooltip(
                  message: _obscurePassword ? 'Show password' : 'Hide password',
                  child: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 19,
                      color: isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfacePanel : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkLineHairline : AppColors.lineHairline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.accentIndigo,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.signalError,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.signalError,
                  width: 1.8,
                ),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
            onFieldSubmitted: (_) => _submit(),
          ),

          // Under Password row: Caps lock hint (left) & Forgot Password link (right)
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_isCapsLockOn)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 13,
                      color: AppColors.signalAmber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Caps Lock is on',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.signalAmber,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              Semantics(
                button: true,
                label: 'Forgot password',
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PortalForgotPasswordScreen()),
                  ),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentIndigo,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Inline Error Message Banner
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF381515)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.signalError.withValues(alpha: isDark ? 0.45 : 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.signalError,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFB91C1C),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),

          // Full-width Log In Button
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentIndigo,
              disabledBackgroundColor: AppColors.accentIndigo.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),

          // Register Action (shown only if no bound account locks this device)
          if (!isLocked) ...[
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.inkSecondaryOf(context),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PortalRegisterScreen()),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.accentIndigo,
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Bottom footer: version on left (if enabled), company credits on right
  Widget _buildFooter(BuildContext context, bool isDark, {bool showVersion = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkLineHairline : AppColors.lineHairline,
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: showVersion ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
        children: [
          if (showVersion) ...[
            FutureBuilder<String>(
              future: getCurrentAppVersion(),
              initialData: currentAppVersion,
              builder: (context, snapshot) {
                final version = snapshot.data ?? currentAppVersion;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: isDark
                          ? AppColors.darkInkSecondary
                          : const Color(0xFF4B5563),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'v$version',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkInkSecondary
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],

          // Company credit
          Flexible(
            child: Text(
              'Software designed and developed by ARMSS INFO TECH',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkInkSecondary
                    : const Color(0xFF374151), // Darkened gray-700 for sharp, high-contrast readability
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle faint grid painter for the dark brand panel background
class _FaintGridPainter extends CustomPainter {
  final Color color;
  final double step;

  _FaintGridPainter({required this.color, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FaintGridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.step != step;
  }
}

/// Subtle faint dot grid painter for the right panel background
class _FaintDotGridPainter extends CustomPainter {
  final Color color;
  final double step;

  _FaintDotGridPainter({
    required this.color,
    this.step = 32,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 1.2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FaintDotGridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.step != step;
  }
}
