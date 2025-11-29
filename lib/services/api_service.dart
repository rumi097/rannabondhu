import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Models
import 'package:rannabondhu/models/recipe.dart';
import 'package:rannabondhu/utils/strings_bn.dart';

class ApiService {
  
  // --- THIS IS THE CHANGE ---
  // Replace this with your new, permanent InfinityFree URL
  static const String _baseUrl = "http://rannabondhu.infinityfreeapp.com/rannabondhu";
  // --- END OF CHANGE ---
  
  // These are the bdapps server URLs from the PDF
  static const String _bdappsOtpRequestUrl = "https://developer.bdapps.com/subscription/otp/request";
  static const String _bdappsOtpVerifyUrl = "https://developer.bdapps.com/subscription/otp/verify";
  

  // --- Auth Method 1: Request OTP (WITH Password) ---
  Future<String?> requestOtp(String mobileNumber) async {
    // bdapps requires the number in "tel:8801..." format
    final formattedNumber = "tel:88$mobileNumber";
    
    final body = jsonEncode({
      "applicationId": AppStrings.bdappsAppId,
      "password": AppStrings.bdappsAppPassword,
      "subscriberId": formattedNumber,
      "applicationMetaData": {
      "client": "MOBILEAPP" // This tells bdapps it's a mobile app
      }
    });

    try {
      final response = await http.post(
        Uri.parse(_bdappsOtpRequestUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['statusCode'] == 'S1000' && data['referenceNo'] != null) {
          return data['referenceNo'];
        }
      }
      print("bdapps OTP Request Failed: ${response.body}");
      return null;
    } catch (e) {
      print("requestOtp Error: $e");
      return null;
    }
  }
  
  // --- Auth Method 2: Verify OTP (WITH Password) ---
  Future<bool> verifyOtp(String referenceNo, String otp) async {
    
    final body = jsonEncode({
      "applicationId": AppStrings.bdappsAppId,
      "password": AppStrings.bdappsAppPassword,
      "referenceNo": referenceNo,
      "otp": otp
    });

    try {
      final response = await http.post(
        Uri.parse(_bdappsOtpVerifyUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['statusCode'] == 'S1000' && data['subscriptionStatus'] == 'REGISTERED') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);
          return true;
        }
      }
      print("bdapps OTP Verify Failed: ${response.body}");
      return false;
    } catch (e) {
      print("verifyOtp Error: $e");
      return false;
    }
  }
  
  // --- AI Recipe Method ---
  Future<Recipe> generateRecipe(String prompt) async {
    final encodedPrompt = Uri.encodeComponent(prompt);
    
    final response = await http.get(
      Uri.parse("$_baseUrl/get_recipes.php?prompt=$encodedPrompt")
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['error'] != null) {
        throw Exception('AI Error: ${data['error']}');
      }
      return Recipe.fromAiJson(data);
    } else {
      throw Exception('Failed to load AI recipe. Server status: ${response.statusCode}');
    }
  }
}