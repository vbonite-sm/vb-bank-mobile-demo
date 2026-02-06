import 'package:flutter/material.dart';
import '../theme/colors.dart';

class LoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const LoadingSpinner({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Full-screen loading overlay
  static Widget overlay({String? message}) {
    return Container(
      color: AppColors.background.withOpacity(0.8),
      child: LoadingSpinner(message: message),
    );
  }
}
