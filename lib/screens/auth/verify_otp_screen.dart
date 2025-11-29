import 'package:flutter/material.dart';
import 'package:rannabondhu/screens/home_screen.dart';
import 'package:rannabondhu/services/api_service.dart';
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/utils/app_theme.dart';

class VerifyOtpScreen extends StatefulWidget {
  // It now takes a referenceNo, not a mobile number
  final String referenceNo;
  const VerifyOtpScreen({super.key, required this.referenceNo});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final otp = _otpController.text;
      
      // --- UPDATED LOGIC ---
      // Send the referenceNo and the new OTP
      final bool success = (await _apiService.verifyOtp(widget.referenceNo, otp)) == true;
      // --- END OF UPDATE ---
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          // We don't need to call NotificationService,
          // as we are not using Firebase for notifications.
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.verificationSuccess),
              backgroundColor: Colors.green,
            ),
          );
          
          // Go to Home and remove all previous screens (register, verify)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.verificationFailed),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.otpTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                AppStrings.otpTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.otpSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16),
                decoration: const InputDecoration(
                  labelText: AppStrings.otpCode,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return AppStrings.invalidOtp;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(AppStrings.verifyOtp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}