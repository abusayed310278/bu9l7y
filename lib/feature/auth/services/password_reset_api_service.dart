import 'package:cloud_functions/cloud_functions.dart';

class PasswordResetApiService {
  PasswordResetApiService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    return _call('sendPasswordResetOtp', {'email': email});
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return _call('verifyPasswordResetOtp', {'email': email, 'otp': otp});
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
    String? verificationToken,
  }) async {
    final Map<String, dynamic> payload = {
      'email': email,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      if (verificationToken != null && verificationToken.trim().isNotEmpty)
        'token': verificationToken,
    };

    return _call('resetPasswordWithOtp', payload);
  }

  Future<Map<String, dynamic>> _call(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(functionName);
      final HttpsCallableResult<dynamic> result = await callable.call(payload);
      return _asMap(result.data);
    } on FirebaseFunctionsException catch (e) {
      final String message = e.message?.trim().isNotEmpty == true
          ? e.message!.trim()
          : 'Request failed.';
      throw Exception(message);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
