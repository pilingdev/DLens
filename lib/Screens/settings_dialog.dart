import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/locale_provider.dart';
import '../services/tutorial_service.dart';

class SettingsDialog extends ConsumerWidget {
  /// Called when the user taps "Show Tutorial" so the home screen can
  /// replay the overlay without a full rebuild.
  final VoidCallback? onReplayTutorial;

  const SettingsDialog({super.key, this.onReplayTutorial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isFilipino = locale.languageCode == 'tl';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.settings, color: Color(0xFF2ECC71), size: 26),
          const SizedBox(width: 10),
          Text(
            loc.settings,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Language Switch ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.language,
                    color: Color(0xFF2ECC71),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.languageSwitch,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'EN',
                    style: TextStyle(
                      fontWeight: isFilipino
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: isFilipino ? Colors.grey : const Color(0xFF2ECC71),
                    ),
                  ),
                  Switch(
                    value: isFilipino,
                    activeThumbColor: const Color(0xFF2ECC71),
                    onChanged: (value) {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(
                            value ? const Locale('tl') : const Locale('en'),
                          );
                    },
                  ),
                  Text(
                    'TL',
                    style: TextStyle(
                      fontWeight: isFilipino
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isFilipino ? const Color(0xFF2ECC71) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 8),

          // ── Tutorial Toggle ──────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.school_outlined,
              color: Colors.blueAccent,
              size: 22,
            ),
            title: Text(
              loc.tutorialToggle,
              style: const TextStyle(fontSize: 15),
            ),
            onTap: () {
              TutorialService().resetTutorial();
              Navigator.pop(context);
              onReplayTutorial?.call();
            },
          ),
          const Divider(height: 8),

          // ── Exit App ────────────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.redAccent,
              size: 22,
            ),
            title: Text(loc.exitApp, style: const TextStyle(fontSize: 15)),
            onTap: () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            loc.cancel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }
}
