import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage>
    with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  String? errorMessage;
  bool isLoading = false;
  bool _obscurePassword = true;

  // Animations
  late final AnimationController _entranceController;
  late final AnimationController _floatingController;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _formSlide;
  late final Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatingController.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _persistLogin(String uid, String email, String? name) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
    if (name != null && name.isNotEmpty) {
      await prefs.setString('name', name);
    }
    await prefs.setBool('isGuest', false);
  }

  Future<void> _guestLogin() async {
    setState(() => isLoading = true);
    try {
      final prefs = ref.read(sharedPrefsProvider);
      await prefs.remove('uid');
      await prefs.remove('email');
      await prefs.remove('name');
      await prefs.setBool('isGuest', true);
      if (mounted) context.goNamed('home');
    } catch (e) {
      setState(() => errorMessage = "حدث خطأ أثناء الدخول كضيف");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      if (isLogin) {
        final cred = await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .get();
        await _persistLogin(
          cred.user!.uid,
          cred.user!.email ?? '',
          userDoc.data()?['name'],
        );
      } else {
        final cred = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({
          'uid': cred.user!.uid,
          'email': _email.text.trim(),
          'name': _name.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _persistLogin(
          cred.user!.uid,
          _email.text.trim(),
          _name.text.trim(),
        );
      }
      if (mounted) context.goNamed('home');
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // ═══ الخلفية الكحلية العميقة ═══
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.7, 1.0],
                  colors: [
                    AppColors.primaryDeep,
                    AppColors.primaryDeep,
                    AppColors.primary,
                    AppColors.primaryMedium,
                  ],
                ),
              ),
            ),

            // ═══ الزخارف الهندسية المتحركة ═══
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                final floatVal = _floatingController.value;
                return Stack(
                  children: [
                    // دوائر هندسية كبيرة
                    Positioned(
                      top: -40 + (floatVal * 8),
                      right: -50,
                      child: _IslamicGeometryDecor(
                        size: 200,
                        opacity: 0.035,
                        rings: 3,
                      ),
                    ),
                    Positioned(
                      bottom: screenHeight * 0.15 + (floatVal * 6),
                      left: -60,
                      child: _IslamicGeometryDecor(
                        size: 160,
                        opacity: 0.03,
                        rings: 2,
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.35 - (floatVal * 5),
                      right: screenWidth * 0.7,
                      child: _IslamicGeometryDecor(
                        size: 80,
                        opacity: 0.04,
                        rings: 2,
                      ),
                    ),
                    // نجوم صغيرة متناثرة
                    ..._buildStarParticles(screenWidth, screenHeight, floatVal),
                  ],
                );
              },
            ),

            // ═══ القوس الإسلامي الكبير ═══
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.45,
              child: FadeTransition(
                opacity: _logoFade,
                child: CustomPaint(
                  painter: _GrandIslamicArchPainter(),
                ),
              ),
            ),

            // ═══ المحتوى ═══
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.08),

                        // ═══ الشعار والعنوان ═══
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _buildLogoSection(context),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // ═══ النموذج ═══
                        SlideTransition(
                          position: _formSlide,
                          child: FadeTransition(
                            opacity: _formFade,
                            child: _buildFormSection(context),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  قسم الشعار
  // ═══════════════════════════════════════════════
  Widget _buildLogoSection(BuildContext context) {
    return Column(
      children: [
        // الأيقونة في إطار زخرفي
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gold.withValues(alpha:0.15),
                AppColors.gold.withValues(alpha:0.05),
              ],
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha:0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha:0.08),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // الإطار الداخلي
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha:0.15),
                    width: 0.8,
                  ),
                ),
              ),
              const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.gold,
                size: 36,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // العنوان الرئيسي
        Text(
          'استفتاءات الشيخ السند',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                color: AppColors.gold.withValues(alpha:0.15),
                blurRadius: 20,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // الفاصل الزخرفي
        _buildOrnamentalLine(),

        const SizedBox(height: 10),

        Text(
          isLogin ? 'تسجيل الدخول إلى حسابك' : 'إنشاء حساب جديد',
          style: TextStyle(
            color: AppColors.gold.withValues(alpha:0.7),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  قسم النموذج
  // ═══════════════════════════════════════════════
  Widget _buildFormSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.gold.withValues(alpha:0.1),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // حقل الاسم (لإنشاء حساب فقط)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: !isLogin
                  ? Column(
                      children: [
                        _buildField(
                          controller: _name,
                          hint: "الاسم الكامل",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            _buildField(
              controller: _email,
              hint: "البريد الإلكتروني",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "أدخل البريد الإلكتروني" : null,
            ),
            const SizedBox(height: 16),

            _buildField(
              controller: _password,
              hint: "كلمة المرور",
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.gold.withValues(alpha:0.5),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? "أدخل كلمة المرور"
                  : (v.length < 6 ? "كلمة المرور قصيرة جدًا" : null),
            ),

            const SizedBox(height: 28),

            // ═══ زر الدخول الرئيسي ═══
            _buildMainButton(),

            // ═══ رسالة الخطأ ═══
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha:0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: AppColors.error.withValues(alpha:0.8),
                                size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: AppColors.error.withValues(alpha:0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // فاصل زخرفي
            _buildOrnamentalLine(),

            const SizedBox(height: 16),

            // ═══ تبديل بين الدخول والتسجيل ═══
            GestureDetector(
              onTap: () => setState(() {
                isLogin = !isLogin;
                errorMessage = null;
              }),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.6),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: isLogin ? 'ليس لديك حساب؟ ' : 'لديك حساب؟ ',
                    ),
                    TextSpan(
                      text: isLogin ? 'أنشئ واحدًا' : 'تسجيل الدخول',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ═══ الدخول كضيف ═══
            TextButton(
              onPressed: isLoading ? null : _guestLogin,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha:0.08),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white.withValues(alpha:0.4),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "الدخول كضيف",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.4),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ زر الدخول الرئيسي ═══
  Widget _buildMainButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFD4A843),
              Color(0xFFE8C56B),
              Color(0xFFD4A843),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha:0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.primaryDeep,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryDeep,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLogin
                          ? Icons.login_rounded
                          : Icons.person_add_alt_1_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isLogin ? "تسجيل الدخول" : "إنشاء حساب",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ═══ حقل إدخال فاخر ═══
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: AppColors.gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha:0.3),
          fontSize: 14,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha:0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.gold.withValues(alpha:0.7), size: 18),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha:0.05),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha:0.08),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.gold.withValues(alpha:0.5),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.error.withValues(alpha:0.5),
            width: 0.8,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.2,
          ),
        ),
        errorStyle: TextStyle(
          color: AppColors.error.withValues(alpha:0.8),
          fontSize: 12,
        ),
      ),
    );
  }

  // ═══ الخط الزخرفي ═══
  Widget _buildOrnamentalLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.gold.withValues(alpha:0.5),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha:0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha:0.4),
          ),
        ),
        const SizedBox(width: 6),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha:0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 30,
          height: 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha:0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══ نقاط نجومية ═══
  List<Widget> _buildStarParticles(
      double width, double height, double floatVal) {
    final stars = <_StarPos>[
      _StarPos(0.15, 0.12, 2.0),
      _StarPos(0.82, 0.08, 1.5),
      _StarPos(0.65, 0.22, 1.8),
      _StarPos(0.08, 0.35, 1.3),
      _StarPos(0.92, 0.42, 2.2),
      _StarPos(0.35, 0.55, 1.5),
      _StarPos(0.78, 0.65, 1.8),
      _StarPos(0.22, 0.75, 1.4),
      _StarPos(0.55, 0.85, 2.0),
      _StarPos(0.88, 0.78, 1.6),
    ];

    return stars.map((star) {
      final offset = math.sin(floatVal * math.pi * 2 + star.x * 10) * 3;
      return Positioned(
        left: width * star.x + offset,
        top: height * star.y - offset * 0.5,
        child: Container(
          width: star.size,
          height: star.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha:0.15 + floatVal * 0.1),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha:0.1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _StarPos {
  final double x, y, size;
  const _StarPos(this.x, this.y, this.size);
}

// ═══════════════════════════════════════════════
//  زخرفة هندسية إسلامية
// ═══════════════════════════════════════════════
class _IslamicGeometryDecor extends StatelessWidget {
  final double size;
  final double opacity;
  final int rings;

  const _IslamicGeometryDecor({
    required this.size,
    required this.opacity,
    this.rings = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IslamicGeometryPainter(
          opacity: opacity,
          rings: rings,
        ),
      ),
    );
  }
}

class _IslamicGeometryPainter extends CustomPainter {
  final double opacity;
  final int rings;

  _IslamicGeometryPainter({required this.opacity, required this.rings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha:opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // الدوائر المتداخلة
    for (int i = 0; i < rings; i++) {
      final r = maxRadius * (1 - i * 0.25);
      canvas.drawCircle(center, r, paint);
    }

    // الخطوط الشعاعية (نمط النجمة)
    final linePaint = Paint()
      ..color = AppColors.gold.withValues(alpha:opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final end = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, end, linePaint);
    }

    // المثمن الداخلي
    final octagonPaint = Paint()
      ..color = AppColors.gold.withValues(alpha:opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final innerR = maxRadius * 0.5;
    final octPath = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i - math.pi / 8;
      final x = center.dx + innerR * math.cos(angle);
      final y = center.dy + innerR * math.sin(angle);
      if (i == 0) {
        octPath.moveTo(x, y);
      } else {
        octPath.lineTo(x, y);
      }
    }
    octPath.close();
    canvas.drawPath(octPath, octagonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════
//  القوس الإسلامي الكبير
// ═══════════════════════════════════════════════
class _GrandIslamicArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // القوس الخارجي
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gold.withValues(alpha:0.0),
          AppColors.gold.withValues(alpha:0.12),
          AppColors.gold.withValues(alpha:0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final outerPath = Path();
    outerPath.moveTo(0, h);
    outerPath.quadraticBezierTo(w * 0.05, h * 0.15, w * 0.5, h * 0.02);
    outerPath.quadraticBezierTo(w * 0.95, h * 0.15, w, h);
    canvas.drawPath(outerPath, outerPaint);

    // القوس الداخلي
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gold.withValues(alpha:0.0),
          AppColors.gold.withValues(alpha:0.08),
          AppColors.gold.withValues(alpha:0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final innerPath = Path();
    innerPath.moveTo(w * 0.08, h);
    innerPath.quadraticBezierTo(w * 0.12, h * 0.25, w * 0.5, h * 0.1);
    innerPath.quadraticBezierTo(w * 0.88, h * 0.25, w * 0.92, h);
    canvas.drawPath(innerPath, innerPaint);

    // نقطة الذروة (قمة القوس)
    final dotPaint = Paint()
      ..color = AppColors.gold.withValues(alpha:0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.06), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
