import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const HoursApp());
}

// نموذج المنشور الحقيقي
class PostModel {
  final String authorEmail;
  final String authorName;
  final String content;
  final String category;
  final String timeAgo;
  int likes;
  bool isLiked;

  PostModel({
    required this.authorEmail,
    required this.authorName,
    required this.content,
    required this.category,
    required this.timeAgo,
    this.likes = 0,
    this.isLiked = false,
  });
}

// قائمة عامة فارغة وخالية من أي منشورات وهمية مسبقة لضمان الواقعية المطلقة
final List<PostModel> globalPosts = [];

class HoursApp extends StatefulWidget {
  const HoursApp({Key? key}) : super(key: key);

  @override
  State<HoursApp> createState() => _HoursAppState();
}

class _HoursAppState extends State<HoursApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hours',
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFFCE1126),
        scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: LoginScreen(onThemeChanged: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

// ================= شاشة تسجيل الدخول الواقعية =================
class LoginScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkMode;
  const LoginScreen({Key? key, required this.onThemeChanged, required this.isDarkMode}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _currentLanguage = 'AR';

  Future<void> _handleLogin() async {
    String input = _emailOrPhoneController.text.trim();
    String password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      _showMessage(_currentLanguage == 'AR' ? 'الرجاء إدخال البريد/الهاتف وكلمة المرور' : 'Please enter email/phone and password', Colors.red[800]!);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? storedPassword = prefs.getString(input);
    String? storedName = prefs.getString('${input}_name');

    if (storedPassword != null) {
      if (storedPassword == password) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(
              currentUserEmail: input,
              currentUserName: storedName ?? 'مستخدم Hours',
              onThemeChanged: widget.onThemeChanged,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        );
      } else {
        _showMessage(_currentLanguage == 'AR' ? 'كلمة المرور غير صحيحة' : 'Incorrect password', Colors.red[800]!);
      }
    } else {
      _showRegisterPrompt();
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showRegisterPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_currentLanguage == 'AR' ? 'حساب غير موجود' : 'Account Not Found'),
        content: Text(_currentLanguage == 'AR' ? 'هذا البريد غير مسجل. هل تريد إنشاء حساب؟' : 'Not registered. Create account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_currentLanguage == 'AR' ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCE1126), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(isEnglish: _currentLanguage == 'EN')));
            },
            child: Text(_currentLanguage == 'AR' ? 'إنشاء حساب' : 'Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _currentLanguage == 'EN';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C), Color(0xFF8B0000), Color(0xFFD4AF37)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                border: const Border(top: BorderSide(color: Color(0xFFCE1126), width: 4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 36),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Container(height: 3, color: const Color(0xFFCE1126))),
                            Expanded(child: Container(height: 3, color: Colors.white)),
                            Expanded(child: Container(height: 3, color: Colors.black)),
                            Expanded(child: Container(height: 3, color: const Color(0xFFD4AF37))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => setState(() => _currentLanguage = _currentLanguage == 'AR' ? 'EN' : 'AR'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.language, size: 16, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 4),
                              Text(_currentLanguage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Hours', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), letterSpacing: 2)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailOrPhoneController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: isEn ? 'Email or Phone' : 'البريد أو الهاتف',
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFCE1126)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: isEn ? 'Password' : 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFCE1126)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFCE1126),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isEn ? 'Login' : 'تسجيل الدخول', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(isEnglish: isEn))),
                    child: Text(isEn ? "Don't have an account? Register" : 'ليس لديك حساب؟ انشئ حساباً جديداً', style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= شاشة إنشاء حساب مع التحقق من العمر (18 سنة فأكثر) =================
class RegisterScreen extends StatefulWidget {
  final bool isEnglish;
  const RegisterScreen({Key? key, required this.isEnglish}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _selectedBirthDate;

  Future<void> _pickBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _handleRegister() async {
    String name = _nameController.text.trim();
    String input = _emailOrPhoneController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || input.isEmpty || password.isEmpty || _selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEnglish ? 'Fill all fields including birth date' : 'الرجاء تعبئة جميع الحقول وتحديد تاريخ الميلاد'), backgroundColor: Colors.red),
      );
      return;
    }

    // التحقق من شرط العمر 18 سنة فأكثر بدقة
    DateTime today = DateTime.now();
    int age = today.year - _selectedBirthDate!.year;
    if (today.month < _selectedBirthDate!.month || (today.month == _selectedBirthDate!.month && today.day < _selectedBirthDate!.day)) {
      age--;
    }

    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEnglish ? 'You must be at least 18 years old to register.' : 'عذراً، يجب ألا يقل عمرك عن 18 عاماً لتسجيل حساب.'), backgroundColor: Colors.red[800]!),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(input, password);
    await prefs.setString('${input}_name', name);
    await prefs.setString('${input}_birthdate', '${_selectedBirthDate!.toLocal()}'.split(' ')[0]);
    await prefs.setInt('${input}_last_name_change', DateTime.now().millisecondsSinceEpoch);
    // بيانات افتراضية أولية للبروفايل الجديد
    await prefs.setString('${input}_country', 'مصر');
    await prefs.setString('${input}_origin', 'أسوان');
    await prefs.setString('${input}_education', 'تعليم ثانوي/جامعي');
    await prefs.setString('${input}_bio', 'مرحباً، أنا أستخدم تطبيق Hours!');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.isEnglish ? 'Account created successfully!' : 'تم إنشاء الحساب بنجاح! يمكنك تسجيل الدخول الآن'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = widget.isEnglish;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C), Color(0xFF8B0000), Color(0xFFD4AF37)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: const Border(top: BorderSide(color: Color(0xFFCE1126), width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(isEn ? 'Create Account (18+)' : 'إنشاء حساب جديد (يجب أن تكون 18+)', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 24),
                  TextField(controller: _nameController, style: const TextStyle(color: Colors.black), decoration: InputDecoration(labelText: isEn ? 'Full Name' : 'الاسم الكامل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  TextField(controller: _emailOrPhoneController, style: const TextStyle(color: Colors.black), decoration: InputDecoration(labelText: isEn ? 'Email or Phone' : 'البريد أو الهاتف', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordController, obscureText: true, style: const TextStyle(color: Colors.black), decoration: InputDecoration(labelText: isEn ? 'Password' : 'كلمة المرور', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickBirthDate,
                    icon: const Icon(Icons.calendar_today, color: Color(0xFFCE1126)),
                    label: Text(_selectedBirthDate == null ? (isEn ? 'Select Birth Date' : 'اختر تاريخ الميلاد (18+)') : '${_selectedBirthDate!.toLocal()}'.split(' ')[0], style: const TextStyle(color: Colors.black87)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCE1126), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(isEn ? 'Register' : 'تسجيل وحفظ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= التنقل الرئيسي وشريط المهام الفاخر =================
class MainNavigationScreen extends StatefulWidget {
  final String currentUserEmail;
  final String currentUserName;
  final VoidCallback onThemeChanged;
  final bool isDarkMode;

  const MainNavigationScreen({
    Key? key,
    required this.currentUserEmail,
    required this.currentUserName,
    required this.onThemeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = widget.currentUserName;
  }

  void updateNameLocally(String newName) {
    setState(() {
      _displayName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FeedScreen(currentUserEmail: widget.currentUserEmail, currentUserName: _displayName),
      const FriendsScreen(),
      const MessagesScreen(),
      const NotificationsScreen(),
      SettingsMenuScreen(
        currentUserEmail: widget.currentUserEmail,
        currentUserName: _displayName,
        onNameUpdated: updateNameLocally,
        onThemeChanged: widget.onThemeChanged,
        isDarkMode: widget.isDarkMode,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
        elevation: 6,
        title: const Text(
          'Hours',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Container(
            color: const Color(0xFF25252D),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.public, 'العالم'),
                _buildNavItem(1, Icons.people, 'الأصدقاء'),
                _buildNavItem(2, Icons.message, 'الرسائل'),
                _buildNavItem(3, Icons.notifications, 'الإشعارات'),
                _buildNavItem(4, Icons.settings, 'الإعدادات'),
              ],
            ),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(_displayName, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFCE1126)),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen(onThemeChanged: widget.onThemeChanged, isDarkMode: widget.isDarkMode)),
              );
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFCE1126) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// ================= قائمة الإعدادات (توجيه للبروفايل والأمان) =================
class SettingsMenuScreen extends StatelessWidget {
  final String currentUserEmail;
  final String currentUserName;
  final Function(String) onNameUpdated;
  final VoidCallback onThemeChanged;
  final bool isDarkMode;

  const SettingsMenuScreen({
    Key? key,
    required this.currentUserEmail,
    required this.currentUserName,
    required this.onNameUpdated,
    required this.onThemeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('إعدادات الحساب والبروفايل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFCE1126))),
        const SizedBox(height: 15),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFCE1126), child: Icon(Icons.person, color: Colors.white)),
            title: Text(currentUserName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: const Text('عرض وتعديل البروفايل الشخصي والغلاف والمنشورات'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    currentUserEmail: currentUserEmail,
                    currentUserName: currentUserName,
                    onNameUpdated: onNameUpdated,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.security, color: Color(0xFFD4AF37)),
            title: const Text('الأمان والخصوصية', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('تغيير الاسم (كل 60 يوم) ومعلومات الحساب'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacySettingsScreen(
                    currentUserEmail: currentUserEmail,
                    currentUserName: currentUserName,
                    onNameUpdated: onNameUpdated,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SwitchListTile(
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFFCE1126)),
            title: const Text('الوضع المظلم (Dark Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
            value: isDarkMode,
            onChanged: (val) {
              onThemeChanged();
            },
          ),
        ),
      ],
    );
  }
}

// ================= شاشة البروفايل الحقيقية والمتكاملة =================
class ProfileScreen extends StatefulWidget {
  final String currentUserEmail;
  final String currentUserName;
  final Function(String) onNameUpdated;

  const ProfileScreen({Key? key, required this.currentUserEmail, required this.currentUserName, required this.onNameUpdated}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  String? _profileImagePath;
  String? _coverImagePath;
  String _bio = '';
  String _country = '';
  String _origin = '';
  String _education = '';
  String _birthDate = '';

  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;
  final _postController = TextEditingController();
  String _selectedCategory = 'عام';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('${widget.currentUserEmail}_profile');
      _coverImagePath = prefs.getString('${widget.currentUserEmail}_cover');
      _bio = prefs.getString('${widget.currentUserEmail}_bio') ?? 'مرحباً، أنا أستخدم تطبيق Hours!';
      _country = prefs.getString('${widget.currentUserEmail}_country') ?? 'مصر';
      _origin = prefs.getString('${widget.currentUserEmail}_origin') ?? 'أسوان';
      _education = prefs.getString('${widget.currentUserEmail}_education') ?? 'ثانوية عامة';
      _birthDate = prefs.getString('${widget.currentUserEmail}_birthdate') ?? '2008-01-01';
    });
  }

  Future<void> _pickImage(bool isCover) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        String base64Image = Uri.dataFromBytes(bytes, mimeType: 'image/jpeg').toString();

        final prefs = await SharedPreferences.getInstance();
        setState(() {
          if (isCover) {
            _coverImagePath = base64Image;
            prefs.setString('${widget.currentUserEmail}_cover', base64Image);
          } else {
            _profileImagePath = base64Image;
            prefs.setString('${widget.currentUserEmail}_profile', base64Image);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _addNewPostFromProfile() {
    if (_postController.text.trim().isEmpty) return;
    setState(() {
      globalPosts.insert(0, PostModel(
        authorEmail: widget.currentUserEmail,
        authorName: widget.currentUserName,
        content: _postController.text.trim(),
        category: _selectedCategory,
        timeAgo: 'الآن',
      ));
      _postController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر المنشور بنجاح!')));
  }

  void _openEditProfileDialog() {
    final countryCtrl = TextEditingController(text: _country);
    final originCtrl = TextEditingController(text: _origin);
    final educationCtrl = TextEditingController(text: _education);
    final birthCtrl = TextEditingController(text: _birthDate);
    final bioCtrl = TextEditingController(text: _bio);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل الملف الشخصي'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: countryCtrl, decoration: const InputDecoration(labelText: 'البلد')),
              TextField(controller: originCtrl, decoration: const InputDecoration(labelText: 'بلد المنشأ')),
              TextField(controller: educationCtrl, decoration: const InputDecoration(labelText: 'التعليم')),
              TextField(controller: birthCtrl, decoration: const InputDecoration(labelText: 'تاريخ الميلاد (YYYY-MM-DD)')),
              TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'السيرة الذاتية (Bio)'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCE1126), foregroundColor: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('${widget.currentUserEmail}_country', countryCtrl.text);
              await prefs.setString('${widget.currentUserEmail}_origin', originCtrl.text);
              await prefs.setString('${widget.currentUserEmail}_education', educationCtrl.text);
              await prefs.setString('${widget.currentUserEmail}_birthdate', birthCtrl.text);
              await prefs.setString('${widget.currentUserEmail}_bio', bioCtrl.text);

              setState(() {
                _country = countryCtrl.text;
                _origin = originCtrl.text;
                _education = educationCtrl.text;
                _birthDate = birthCtrl.text;
                _bio = bioCtrl.text;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح!')));
            },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تصفية منشورات هذا المستخدم فقط
    List<PostModel> myPosts = globalPosts.where((p) => p.authorEmail == widget.currentUserEmail).toList();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // الغلاف
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[800],
                    child: _coverImagePath != null
                        ? Image.network(_coverImagePath!, fit: BoxFit.cover)
                        : const Center(child: Text('صورة الغلاف', style: TextStyle(color: Colors.white54))),
                  ),
                  Positioned(
                    top: 130,
                    right: 16,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                      onPressed: () => _pickImage(true),
                      icon: const Icon(Icons.camera_alt, size: 14),
                      label: const Text('تغيير الغلاف', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  // معلومات البروفايل تحت الغلاف
                  Positioned(
                    top: 140,
                    left: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: const Color(0xFFCE1126),
                                backgroundImage: _profileImagePath != null
                                    ? NetworkImage(_profileImagePath!) as ImageProvider
                                    : null,
                                child: _profileImagePath == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFFD4AF37),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.camera_alt, size: 12, color: Colors.black),
                                  onPressed: () => _pickImage(false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 245,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.currentUserName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                              onPressed: _openEditProfileDialog,
                              icon: const Icon(Icons.edit, size: 14),
                              label: const Text('تعديل الملف الشخصي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(_bio, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, size: 14, color: Color(0xFFCE1126)), const SizedBox(width: 4), Text('البلد: $_country', style: const TextStyle(color: Colors.white60, fontSize: 12))]),
                            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.home, size: 14, color: Color(0xFFCE1126)), const SizedBox(width: 4), Text('المنشأ: $_origin', style: const TextStyle(color: Colors.white60, fontSize: 12))]),
                            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.school, size: 14, color: Color(0xFFCE1126)), const SizedBox(width: 4), Text('التعليم: $_education', style: const TextStyle(color: Colors.white60, fontSize: 12))]),
                            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cake, size: 14, color: Color(0xFFCE1126)), const SizedBox(width: 4), Text('الميلاد: $_birthDate', style: const TextStyle(color: Colors.white60, fontSize: 12))]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFCE1126),
              labelColor: const Color(0xFFD4AF37),
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'المنشورات والـنشر'),
                Tab(text: 'الصور'),
                Tab(text: 'الأصدقاء'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // تاب المنشورات وخانة النشر
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Column(
                    children: [
                      TextField(
                        controller: _postController,
                        decoration: InputDecoration(
                          hintText: 'ماذا يدور في ذهنك اليوم يا ${widget.currentUserName}؟',
                          border: InputBorder.none,
                        ),
                        maxLines: 2,
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            value: _selectedCategory,
                            items: ['عام', 'برمجة', 'دراسة', 'تكنولوجيا'].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val!),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCE1126), foregroundColor: Colors.white),
                            onPressed: _addNewPostFromProfile,
                            icon: const Icon(Icons.send, size: 14),
                            label: const Text('نشر'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: myPosts.isEmpty
                      ? const Center(child: Text('لا توجد منشورات لك حتى الآن. ابدأ النشر الآن!'))
                      : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: myPosts.length,
                    itemBuilder: (context, index) {
                      final post = myPosts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.content, style: const TextStyle(fontSize: 15)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  Chip(label: Text(post.category, style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: const Color(0xFFD4AF37), padding: EdgeInsets.zero),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // تاب الصور النشطة
            GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                if (_profileImagePath != null)
                  Image.network(_profileImagePath!, fit: BoxFit.cover),
                if (_coverImagePath != null)
                  Image.network(_coverImagePath!, fit: BoxFit.cover),
                if (_profileImagePath == null && _coverImagePath == null)
                  const Center(child: Text('لم تقم برفع صور بعد', style: TextStyle(color: Colors.grey))),
              ],
            ),
            // تاب الأصدقاء
            ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                ListTile(
                  leading: CircleAvatar(backgroundColor: Color(0xFFCE1126), child: Icon(Icons.person, color: Colors.white)),
                  title: Text('أحمد محمد', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('صديق مشترك'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= شاشة الأمان والخصوصية (تغيير الاسم كل 60 يوماً) =================
class PrivacySettingsScreen extends StatefulWidget {
  final String currentUserEmail;
  final String currentUserName;
  final Function(String) onNameUpdated;

  const PrivacySettingsScreen({Key? key, required this.currentUserEmail, required this.currentUserName, required this.onNameUpdated}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  late TextEditingController _nameController;
  bool _canChangeName = true;
  String _nameMessage = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUserName);
    _checkNameChangeEligibility();
  }

  Future<void> _checkNameChangeEligibility() async {
    final prefs = await SharedPreferences.getInstance();
    int? lastChange = prefs.getInt('${widget.currentUserEmail}_last_name_change');
    if (lastChange != null) {
      DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastChange);
      int daysPassed = DateTime.now().difference(lastDate).inDays;
      if (daysPassed < 60) {
        setState(() {
          _canChangeName = false;
          _nameMessage = 'لا يمكنك تغيير الاسم إلا بعد مرور ${60 - daysPassed} يوماً.';
        });
      }
    }
  }

  Future<void> _saveNewName() async {
    if (!_canChangeName) return;
    String newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.currentUserEmail}_name', newName);
    await prefs.setInt('${widget.currentUserEmail}_last_name_change', DateTime.now().millisecondsSinceEpoch);

    widget.onNameUpdated(newName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الاسم بنجاح!'), backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأمان والخصوصية')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('معلومات الحساب الأساسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCE1126))),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: const Text('البريد الإلكتروني أو الهاتف'),
              subtitle: Text(widget.currentUserEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('تغيير الاسم (مرة كل 60 يوماً)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCE1126))),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            enabled: _canChangeName,
            decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder()),
          ),
          if (_nameMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_nameMessage, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCE1126), foregroundColor: Colors.white),
            onPressed: _canChangeName ? _saveNewName : null,
            child: const Text('حفظ الاسم الجديد'),
          ),
        ],
      ),
    );
  }
}

// ================= الشاشة العامة (FeedScreen) =================
class FeedScreen extends StatefulWidget {
  final String currentUserEmail;
  final String currentUserName;
  const FeedScreen({Key? key, required this.currentUserEmail, required this.currentUserName}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _postController = TextEditingController();
  String _selectedCategory = 'عام';
  String _selectedFilter = 'الكل';
  final List<String> categories = ['عام', 'برمجة', 'دراسة', 'تكنولوجيا'];

  void _addNewPost() {
    if (_postController.text.trim().isEmpty) return;
    setState(() {
      globalPosts.insert(0, PostModel(
        authorEmail: widget.currentUserEmail,
        authorName: widget.currentUserName,
        content: _postController.text.trim(),
        category: _selectedCategory,
        timeAgo: 'الآن',
      ));
      _postController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<PostModel> filteredPosts = _selectedFilter == 'الكل'
        ? globalPosts
        : globalPosts.where((p) => p.category == _selectedFilter).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _postController,
                decoration: InputDecoration(
                  hintText: 'ماذا يدور في ذهنك اليوم يا ${widget.currentUserName}؟',
                  border: InputBorder.none,
                ),
                maxLines: 2,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCE1126), foregroundColor: Colors.white),
                    onPressed: _addNewPost,
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('نشر'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: ['الكل', ...categories].map((filter) {
              bool isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: const Color(0xFFCE1126),
                  onSelected: (selected) => setState(() => _selectedFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: filteredPosts.isEmpty
              ? const Center(child: Text('لا توجد منشورات في العالم العام حالياً. كن أول من ينشر!'))
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(backgroundColor: const Color(0xFFCE1126), child: Text(post.authorName[0], style: const TextStyle(color: Colors.white))),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          Chip(
                            label: Text(post.category, style: const TextStyle(fontSize: 11, color: Colors.white)),
                            backgroundColor: const Color(0xFFD4AF37),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(post.content, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 12),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            onPressed: () => setState(() {
                              post.isLiked = !post.isLiked;
                              post.likes += post.isLiked ? 1 : -1;
                            }),
                            icon: Icon(post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, color: post.isLiked ? const Color(0xFFCE1126) : Colors.grey),
                            label: Text('${post.likes} إعجاب'),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                            label: const Text('تعليق'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('قائمة الأصدقاء الحقيقية فارغة حالياً'));
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('لا توجد رسائل نشطة'));
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('لا توجد إشعارات جديدة'));
  }
}