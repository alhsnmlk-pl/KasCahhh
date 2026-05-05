import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_data.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _androidChannel = AndroidNotificationChannel(
    'kascahh_tagihan',
    'Tagihan Kas',
    description: 'Pengingat tagihan iuran anggota',
    importance: Importance.high,
  );

  // ── Init ────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (kIsWeb) return; // Web tidak support local notifications
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Buat channel Android
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }

  // ── Request permission ──────────────────────────────────────────────────
  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  // ── Show immediate notification ─────────────────────────────────────────
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Schedule daily reminder ─────────────────────────────────────────────
  static Future<void> scheduleHarianReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb || !_initialized) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Jika waktu sudah lewat hari ini, jadwalkan besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Notify all members who haven't paid ─────────────────────────────────
  static Future<void> kirimReminderBelumBayar(AppData data) async {
    if (kIsWeb || !_initialized) return;

    final belumBayar = data.anggotaBelumBayarList;
    if (belumBayar.isEmpty) {
      await showNotification(
        id: 999,
        title: '✅ ${data.namaAplikasi}',
        body: 'Semua anggota sudah bayar iuran periode ini!',
      );
      return;
    }

    // Notifikasi ringkasan
    final total = belumBayar.fold<int>(
      0,
      (sum, a) => sum + data.hitungKekurangan(a),
    );
    await showNotification(
      id: 1000,
      title: '🔔 Tagihan Kas – ${data.namaAplikasi}',
      body:
          '${belumBayar.length} anggota belum bayar. Total kekurangan: ${AppData.formatRupiah(total)}.',
    );

    // Notifikasi per anggota (maks 5)
    for (int i = 0; i < belumBayar.length && i < 5; i++) {
      final a = belumBayar[i];
      final kekurangan = data.hitungKekurangan(a);
      final selisih = data.hitungSelisihPeriode(a);
      final label = data.labelPeriode(a);
      await showNotification(
        id: i + 1,
        title: '⚠️ ${a.nama} belum bayar',
        body: 'Kurang ${AppData.formatRupiah(kekurangan)} (${-selisih} $label)',
      );
      // Delay kecil agar tidak overlap
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  // ── Jadwalkan reminder harian otomatis ──────────────────────────────────
  static Future<void> aturReminderOtomatis(AppData data) async {
    if (kIsWeb || !_initialized) return;
    if (!data.pengingatTagihan) {
      await cancelAll();
      return;
    }

    // Reminder pukul 08:00 setiap hari
    await scheduleHarianReminder(
      id: 9001,
      title: '🔔 ${data.namaAplikasi} – Cek Tagihan',
      body: '${data.anggotaBelumBayar} anggota belum melunasi iuran.',
      hour: 8,
      minute: 0,
    );
  }

  static Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }

  static Future<void> cancel(int id) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(id: id);
  }
}
