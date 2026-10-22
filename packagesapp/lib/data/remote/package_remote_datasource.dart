import 'package:dio/dio.dart';
import '../../models/package_model.dart';
import '../../models/network_model.dart';
import 'dio_client.dart';

class PackageRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<NetworkModel>> fetchNetworks() async {
    final response = await _dio.get('/networks');
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list.map((e) => NetworkModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PackageModel>> fetchPackages({
    String? networkId,
    String? category,
    String? subCategory,
    String? sort,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{};
    if (networkId != null) queryParams['networkId'] = networkId;
    if (category != null && category != 'all') queryParams['category'] = category;
    if (subCategory != null) queryParams['subCategory'] = subCategory;
    if (sort != null) queryParams['sort'] = sort;
    if (order != null) queryParams['order'] = order;

    final response = await _dio.get('/packages', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list.map((e) => PackageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PackageModel> fetchPackageById(String id) async {
    final response = await _dio.get('/packages/$id');
    final data = response.data as Map<String, dynamic>;
    return PackageModel.fromJson(data['data'] as Map<String, dynamic>);
  }
}
