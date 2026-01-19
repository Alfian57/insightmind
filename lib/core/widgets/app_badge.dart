import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Status badge/chip component
class AppBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final bool small;

  const AppBadge({
    super.key,
    required this.text,
    this.type = BadgeType.info,
    this.small = false,
  });

  const AppBadge.success({
    super.key,
    required this.text,
    this.small = false,
  }) : type = BadgeType.success;

  const AppBadge.warning({
    super.key,
    required this.text,
    this.small = false,
  }) : type = BadgeType.warning;

  const AppBadge.error({
    super.key,
    required this.text,
    this.small = false,
  }) : type = BadgeType.error;

  @override
  Widget build(BuildContext context) {
    final colors = _getBadgeColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(small ? 6 : 8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.foreground,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _BadgeColors _getBadgeColors() {
    switch (type) {
      case BadgeType.success:
        return _BadgeColors(
          background: AppColors.success.withOpacity(0.15),
          foreground: AppColors.successDark,
        );
      case BadgeType.warning:
        return _BadgeColors(
          background: AppColors.warning.withOpacity(0.15),
          foreground: AppColors.warningDark,
        );
      case BadgeType.error:
        return _BadgeColors(
          background: AppColors.error.withOpacity(0.15),
          foreground: AppColors.errorDark,
        );
      case BadgeType.info:
        return _BadgeColors(
          background: AppColors.info.withOpacity(0.15),
          foreground: AppColors.infoDark,
        );
      case BadgeType.neutral:
        return _BadgeColors(
          background: AppColors.textTertiaryLight.withOpacity(0.2),
          foreground: AppColors.textSecondaryLight,
        );
    }
  }
}

enum BadgeType { success, warning, error, info, neutral }

class _BadgeColors {
  final Color background;
  final Color foreground;

  const _BadgeColors({required this.background, required this.foreground});
}

/// Risk level badge with specific styling
class AppRiskBadge extends StatelessWidget {
  final String riskLevel;
  final bool showIcon;
  final bool large;

  const AppRiskBadge({
    super.key,
    required this.riskLevel,
    this.showIcon = true,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getRiskConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              color: config.color,
              size: large ? 20 : 16,
            ),
            SizedBox(width: large ? 8 : 6),
          ],
          Text(
            riskLevel,
            style: TextStyle(
              color: config.color,
              fontSize: large ? 16 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _RiskConfig _getRiskConfig() {
    switch (riskLevel.toLowerCase()) {
      case 'rendah':
      case 'low':
        return _RiskConfig(
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case 'sedang':
      case 'medium':
        return _RiskConfig(
          color: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case 'tinggi':
      case 'high':
        return _RiskConfig(
          color: AppColors.error,
          icon: Icons.error_outline,
        );
      default:
        return _RiskConfig(
          color: AppColors.info,
          icon: Icons.info_outline,
        );
    }
  }
}

class _RiskConfig {
  final Color color;
  final IconData icon;

  const _RiskConfig({required this.color, required this.icon});
}
