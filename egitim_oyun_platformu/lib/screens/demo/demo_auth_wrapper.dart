import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DemoAuthWrapper extends StatefulWidget {
  const DemoAuthWrapper({super.key});

  @override
  State<DemoAuthWrapper> createState() => _DemoAuthWrapperState();
}

class _DemoAuthWrapperState extends State<DemoAuthWrapper> {
  bool _isLoggedIn = false;

  void _login() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.games_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),

                  // Title
                  Text(
                    'Eğitim Oyun\nPlatformu',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),

                  Text(
                    'AI ile kendi oyununu oluştur!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),

                  // Demo Info
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.secondaryColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: AppTheme.secondaryColor,
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Text(
                              'DEMO MODU',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Text(
                          'Bu demo, Firebase olmadan UI özelliklerini gösterir. Oyun oluşturma, feed, profil gibi tüm ekranları test edebilirsiniz.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),

                  // Demo Login Button
                  ElevatedButton.icon(
                    onPressed: _login,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Demo ile Başla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),

                  // Note
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingMedium,
                      vertical: AppTheme.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      '⚠️ Production için Firebase entegrasyonu ve Gemini API keyi gerekir.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DemoHomeScreen(onLogout: _logout);
  }
}

class DemoHomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const DemoHomeScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Demo - Gerçek UI render edilecek'),
      ),
    );
  }
}
