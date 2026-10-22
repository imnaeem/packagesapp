import 'package:dio/dio.dart';
import '../../models/favourite_model.dart';
import 'dio_client.dart';

class FavouriteRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<FavouriteModel>> fetchFavourites() async {
    final response = await _dio.get('/favourites');
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list.map((e) => FavouriteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addFavourite(String packageId) async {
    await _dio.post('/favourites/$packageId');
  }

  Future<void> removeFavourite(String packageId) async {
    await _dio.delete('/favourites/$packageId');
  }

  Future<void> syncFavourites(List<FavouriteModel> favourites) async {
    await _dio.post('/favourites/sync', data: {
      'favourites': favourites.map((f) => f.toJson()).toList(),
    });
  }
}
