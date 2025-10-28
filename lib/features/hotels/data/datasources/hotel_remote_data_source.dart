import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/api_config.dart';
import '../models/hotel_model.dart';

abstract class HotelRemoteDataSource {
  Future<List<HotelModel>> searchHotels(String query, int page);
  Future<List<HotelModel>> getPopularHotels({
    required String city,
    required String state,
    required String country,
  });
}

class HotelRemoteDataSourceImpl implements HotelRemoteDataSource {
  final http.Client client;
  String? _visitorToken;

  HotelRemoteDataSourceImpl({required this.client});

  @override
  Future<List<HotelModel>> searchHotels(String query, int page) async {
    await _ensureVisitorToken();

    try {
      developer.log('Searching: "$query" (page: $page)', name: 'HotelAPI');

      final requestBody = {
        'action': ApiConfig.actionSearchAutoComplete,
        'searchAutoComplete': {
          'inputText': query,
          'searchType': ApiConfig.searchTypes,
          'limit': ApiConfig.defaultSearchLimit,
        }
      };

      final response = await _makeRequest(requestBody);
      return _parseSearchResponse(response);
    } catch (e) {
      developer.log('Search error: $e', name: 'HotelAPI');
      if (e is ServerException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<List<HotelModel>> getPopularHotels({
    required String city,
    required String state,
    required String country,
  }) async {
    await _ensureVisitorToken();

    try {
      developer.log('Getting popular: $city, $state', name: 'HotelAPI');

      final requestBody = {
        'action': ApiConfig.actionPopularStay,
        'popularStay': {
          'limit': ApiConfig.defaultPopularLimit,
          'entityType': 'Any',
          'filter': {
            'searchType': 'byCity',
            'searchTypeInfo': {
              'country': country,
              'state': state,
              'city': city,
            }
          },
          'currency': ApiConfig.defaultCurrency,
        }
      };

      final response = await _makeRequest(requestBody);
      return _parsePopularResponse(response);
    } catch (e) {
      developer.log('Popular hotels error: $e', name: 'HotelAPI');
      if (e is ServerException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  Future<void> _ensureVisitorToken() async {
    if (_visitorToken != null) return;

    try {
      developer.log('Registering device...', name: 'HotelAPI');

      final deviceData = await _getDeviceInfo();
      final response = await client.post(
        Uri.parse(ApiConfig.baseUrl),
        headers: _buildHeaders(includeVisitorToken: false),
        body: json.encode({
          'action': ApiConfig.actionDeviceRegister,
          'deviceRegister': deviceData,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _visitorToken = data['data']?['visitorToken'];
        developer.log('Visitor token obtained', name: 'HotelAPI');
      }
    } catch (e) {
      developer.log('Device register error: $e', name: 'HotelAPI');
      // Continue without visitor token
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'deviceModel': androidInfo.model,
        'deviceFingerprint': androidInfo.fingerprint,
        'deviceBrand': androidInfo.brand,
        'deviceId': androidInfo.id,
        'deviceName':
            '${androidInfo.model}_${androidInfo.version.release}_${androidInfo.display}',
        'deviceManufacturer': androidInfo.manufacturer,
        'deviceProduct': androidInfo.product,
        'deviceSerialNumber': androidInfo.serialNumber.isNotEmpty
            ? androidInfo.serialNumber
            : 'unknown',
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'deviceModel': iosInfo.model,
        'deviceBrand': 'Apple',
        'deviceId': iosInfo.identifierForVendor ?? 'unknown',
        'deviceName': iosInfo.name,
        'deviceManufacturer': 'Apple',
        'deviceProduct': iosInfo.utsname.machine,
        'deviceSerialNumber': 'unknown',
      };
    }

    // Fallback for other platforms
    return {
      'deviceModel': 'Flutter App',
      'deviceBrand': 'MyTravaly',
      'deviceId': 'flutter_${DateTime.now().millisecondsSinceEpoch}',
      'deviceName': 'Flutter Device',
      'deviceManufacturer': 'Flutter',
      'deviceProduct': 'FlutterApp',
      'deviceSerialNumber': 'unknown',
    };
  }

  Map<String, String> _buildHeaders({bool includeVisitorToken = true}) {
    return {
      ApiConfig.headerAuthToken: ApiConfig.authToken,
      if (includeVisitorToken && _visitorToken != null)
        ApiConfig.headerVisitorToken: _visitorToken!,
      ApiConfig.headerContentType: ApiConfig.contentTypeJson,
    };
  }

  Future<http.Response> _makeRequest(Map<String, dynamic> requestBody) async {
    final response = await client.post(
      Uri.parse(ApiConfig.baseUrl),
      headers: _buildHeaders(),
      body: json.encode(requestBody),
    );

    developer.log('Response: ${response.statusCode}', name: 'HotelAPI');

    if (response.statusCode != 200) {
      throw ServerException('Request failed: ${response.statusCode}');
    }

    return response;
  }

  List<HotelModel> _parseSearchResponse(http.Response response) {
    final data = json.decode(response.body);
    final hotels = <HotelModel>[];

    final autoCompleteList = data['data']?['autoCompleteList'];
    if (autoCompleteList == null) return hotels;

    if (autoCompleteList['byPropertyName']?['present'] == true) {
      final properties =
          autoCompleteList['byPropertyName']['listOfResult'] as List? ?? [];

      hotels.addAll(
        properties.map((prop) => HotelModel.fromJson({
              'propertyCode': prop['searchArray']?['query']?[0],
              'propertyName': prop['propertyName'],
              'propertyAddress': {
                'city': prop['address']?['city'],
                'state': prop['address']?['state'],
                'country': 'India',
              },
              'description': prop['valueToDisplay'],
            })),
      );

      developer.log('Found ${hotels.length} hotels', name: 'HotelAPI');
    }

    return hotels;
  }

  List<HotelModel> _parsePopularResponse(http.Response response) {
    final data = json.decode(response.body);

    if (data['status'] == true && data['data'] != null) {
      final hotelsData = data['data'] as List;
      developer.log('Found ${hotelsData.length} popular hotels',
          name: 'HotelAPI');
      return hotelsData.map((hotel) => HotelModel.fromJson(hotel)).toList();
    }

    return [];
  }
}
