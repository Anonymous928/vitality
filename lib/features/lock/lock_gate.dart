import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../data/providers.dart';

/// Native window flags (FLAG_SECURE) via a tiny channel in MainActivity.
class WindowPrivacy {
  static const _channel = MethodChannel('afterglow/window');
  static Future<void> setSecure(bool secure) =>
      _channel.invokeMethod('setSecure', secure);

  /// Android 12+ wallpaper accent for the optional dynamic-colour theme.
  static Future<Color?> accentColor() async {
    final argb = await _channel.invokeMethod<int>('accentColor');
    return argb == null ? null : Color(argb);
  }
}

final lockedProvider = NotifierProvider<LockController, bool>(LockController.new);

class LockController extends Notifier<bool> {
  @override
  bool build() => ref.read(initialSettingsProvider).appLock;

  void lock() {
    if (ref.read(settingsProvider).appLock) state = true;
  }

  Future<void> unlock() async {
    final ok = await authenticate('Unlock your journal');
    if (ok) state = false;
  }

  /// Device PIN, pattern or biometric via Android BiometricPrompt.
  static Future<bool> authenticate(String reason) async {
    try {
      return await LocalAuthentication().authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

/// Sits above the router. Shows a plain placeholder (never app content)
/// while locked, and re-locks whenever the app leaves the foreground.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  bool _prompting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WindowPrivacy.setSecure(ref.read(settingsProvider).secureScreen);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The biometric dialog itself pauses the activity, so ignore lifecycle
    // events while it's showing.
    if (_prompting) return;
    if (state == AppLifecycleState.hidden) {
      ref.read(lockedProvider.notifier).lock();
    } else if (state == AppLifecycleState.resumed) {
      _maybePrompt();
    }
  }

  Future<void> _maybePrompt() async {
    if (!ref.read(lockedProvider) || _prompting) return;
    _prompting = true;
    await ref.read(lockedProvider.notifier).unlock();
    _prompting = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider.select((s) => s.secureScreen),
        (_, secure) => WindowPrivacy.setSecure(secure));

    final locked = ref.watch(lockedProvider);
    return Stack(
      children: [
        // Keep the app mounted (state, scroll position) but invisible.
        Offstage(offstage: locked, child: widget.child),
        if (locked) _LockedScreen(onUnlock: _maybePrompt),
      ],
    );
  }
}

class _LockedScreen extends StatelessWidget {
  const _LockedScreen({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Locked', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onUnlock,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
