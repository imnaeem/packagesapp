import 'package:dio/dio.dart';
import '../../models/user_profile_model.dart';
import 'dio_client.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<UserProfileModel> syncProfile(UserProfileModel profile) async {
    final response = await _dio.post('/auth/profile', data: profile.toJson());
    final data = response.data as Map<String, dynamic>;
    return UserProfileModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> submitFeedback({
    required String message,
    required String email,
    String? name,
  }) async {
    await _dio.post('/feedback', data: {
      'message': message,
      'email': email,
      if (name != null) 'name': name,
    });
  }
}
