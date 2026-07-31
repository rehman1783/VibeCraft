import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vibe_button.dart';
import '../../../../core/widgets/vibe_text_field.dart';

class PhoneAuthBottomSheet extends StatefulWidget {
  final Function(String phoneNumber) onSendCode;
  final Function(String smsCode) onVerifyCode;
  final bool isCodeSent;

  const PhoneAuthBottomSheet({
    super.key,
    required this.onSendCode,
    required this.onVerifyCode,
    required this.isCodeSent,
  });

  @override
  State<PhoneAuthBottomSheet> createState() => _PhoneAuthBottomSheetState();
}

class _PhoneAuthBottomSheetState extends State<PhoneAuthBottomSheet> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isCodeSent ? 'Enter OTP Code' : 'Phone Authentication',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (!widget.isCodeSent) ...[
            VibeTextField(
              controller: _phoneController,
              hintText: '+923001234567',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            VibeButton(
              label: 'Send Verification Code',
              onPressed: () => widget.onSendCode(_phoneController.text.trim()),
            ),
          ] else ...[
            VibeTextField(
              controller: _otpController,
              hintText: '6-digit SMS Code',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            VibeButton(
              label: 'Verify & Login',
              onPressed: () => widget.onVerifyCode(_otpController.text.trim()),
            ),
          ],
        ],
      ),
    );
  }
}