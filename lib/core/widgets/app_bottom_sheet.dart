import 'package:flutter/material.dart';

/// Bottom sheet helper with standard design
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetContent(
        title: title,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  /// Quick confirm dialog
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Konfirmasi',
    String cancelText = 'Batal',
    Color? confirmColor,
    bool isDangerous = false,
  }) {
    return show<bool>(
      context: context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(cancelText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: isDangerous
                      ? FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        )
                      : null,
                  child: Text(confirmText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Options list bottom sheet
  static Future<T?> showOptions<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetOption<T>> options,
  }) {
    return show<T>(
      context: context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            leading: option.icon != null ? Icon(option.icon) : null,
            title: Text(option.title),
            subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
            onTap: () => Navigator.pop(context, option.value),
          );
        }).toList(),
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? maxHeight;

  const _BottomSheetContent({
    this.title,
    required this.child,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? mediaQuery.size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.colorScheme.outlineVariant),
          ],
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                title == null ? 20 : 16,
                20,
                mediaQuery.padding.bottom + 20,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSheetOption<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;

  const BottomSheetOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}
