import 'package:flutter/material.dart';

import 'package:campusfix/core/constants/app_constants.dart';
import 'package:campusfix/core/theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.matcha,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Icon(
            Icons.home_repair_service_outlined,
            color: AppColors.white,
            size: size * 0.55,
          ),
        ),
        if (showName) ...[
          const SizedBox(width: 12),
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.w800,
              color: AppColors.matchaDeep,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
