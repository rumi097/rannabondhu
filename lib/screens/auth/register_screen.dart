import 'package:flutter/material.dart';
import 'package:rannabondhu/screens/auth/verify_otp_screen.dart';
import 'package:rannabondhu/services/api_service.dart';
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final mobile = _mobileController.text;
      
      final String? referenceNo = await _apiService.requestOtp(mobile);
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (referenceNo != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.otpSent),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(referenceNo: referenceNo),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP পাঠাতে সমস্যা হয়েছে।"),
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
        title: const Text(AppStrings.registerTitle),
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
                AppStrings.registerTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.registerSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 11, // The user just types 01...
                decoration: const InputDecoration(
                  labelText: AppStrings.mobileNumber,
                  hintText: AppStrings.mobileNumberHint,
                  prefixIcon: Icon(Icons.phone_android_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length != 11 || !value.startsWith('01')) {
                    return AppStrings.invalidMobile;
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(AppStrings.sendOtp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}