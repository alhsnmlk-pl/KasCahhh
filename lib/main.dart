import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_data.dart';
import 'screens/beranda_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const KasCahhApp());
}

// ─── InheritedWidget untuk state global ──────────────────────────────────────

class AppDataProvider extends InheritedNotifier<AppData> {
  const AppDataProvider({
    super.key,
    required AppData data,
    required super.child,
  }) : super(notifier: data);

  static AppData of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AppDataProvider>();
    assert(provider != null, 'AppDataProvider not found in widget tree');
    return provider!.notifier!;
  }
}

// ─── Root App ─────────────────────────────────────────────────────────────────

class KasCahhApp extends StatelessWidget {
  const KasCahhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDataProvider(
      data: AppData(),
      child: Builder(builder: (context) {
        return MaterialApp(
          title: AppDataProvider.of(context).namaAplikasi,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF005440),
            primary: const Color(0xFF005440),
            primaryContainer: const Color(0xFF0F6E56),
            secondaryContainer: const Color(0xFFD3E7E0),
            onSecondaryContainer: const Color(0xFF566863),
            tertiaryContainer: const Color(0xFF3B6D11),
            surface: const Color(0xFFFBF9F8),
            onSurface: const Color(0xFF1B1C1C),
            onSurfaceVariant: const Color(0xFF3F4944),
            onPrimary: Colors.white,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData.light().textTheme,
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        );
      }),
    );
  }
}

// ─── Splash Screen ────────────────────────────────────────────────────────────

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.66,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container
                        Container(
                          width: 224,
                          height: 224,
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primaryContainer
                                      .withValues(alpha: 0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primaryContainer
                                          .withValues(alpha: 0.3),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 144,
                                height: 144,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.monetization_on,
                                    size: 72,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 32,
                                right: 32,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.eco,
                                    size: 24,
                                    color: colorScheme.tertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppDataProvider.of(context).namaAplikasi,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSecondaryContainer,
                              letterSpacing: 0.12,
                            ),
                          ),
                        ),

                        // Title
                        Text(
                          'Kelola Kas\ndengan Mudah',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: -0.64,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          'Catat pemasukan, pengeluaran, dan iuran anggota dalam satu tempat',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Button Mulai
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BerandaScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 8,
                        shadowColor: Colors.black.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mulai Sekarang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
