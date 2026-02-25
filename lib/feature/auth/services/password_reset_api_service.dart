import 'package:cloud_functions/cloud_functions.dart';

class PasswordResetApiService {
  PasswordResetApiService({FirebaseFunctions? functions, String? region})
    : _functions = functions,
      _region = region;

  final FirebaseFunctions? _functions;
  final String? _region;

  static const List<String> _fallbackRegions = <String>[
    'us-central1',
    'asia-south1',
    'asia-east1',
    'europe-west1',
  ];

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

  Future<Map<String, dynamic>> resetPasswordWithPhoneOtp({
    required String phone,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final Map<String, dynamic> payload = {
      'phone': phone,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };

    return _call('resetPasswordWithPhoneOtp', payload);
  }

  Future<Map<String, dynamic>> _call(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    FirebaseFunctionsException? notFoundError;

    if (_functions != null) {
      try {
        final HttpsCallable callable = _functions.httpsCallable(functionName);
        final HttpsCallableResult<dynamic> result = await callable.call(
          payload,
        );
        return _asMap(result.data);
      } on FirebaseFunctionsException catch (e) {
        if (e.code == 'not-found') {
          notFoundError = e;
        } else {
          final String message = e.message?.trim().isNotEmpty == true
              ? e.message!.trim()
              : 'Request failed.';
          throw Exception(message);
        }
      }
    }

    final Set<String> attemptedRegions = <String>{};
    final List<String> regionsToTry = <String>[
      if (_region?.trim().isNotEmpty == true) _region!.trim(),
      ..._fallbackRegions,
    ];

    for (final String region in regionsToTry) {
      if (!attemptedRegions.add(region)) {
        continue;
      }
      final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
        region: region,
      );
      try {
        final HttpsCallable callable = functions.httpsCallable(functionName);
        final HttpsCallableResult<dynamic> result = await callable.call(
          payload,
        );
        return _asMap(result.data);
      } on FirebaseFunctionsException catch (e) {
        if (e.code == 'not-found') {
          notFoundError = e;
          continue;
        }
        final String message = e.message?.trim().isNotEmpty == true
            ? e.message!.trim()
            : 'Request failed.';
        throw Exception(message);
      }
    }

    if (notFoundError != null) {
      throw Exception(
        'Password reset service is not deployed. Deploy Cloud Functions first.',
      );
    }

    throw Exception('Request failed.');
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
