class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://api.mytravaly.com/public/v1/';

  // Authentication Token
  static const String authToken = '71523fdd8d26f585315b4233e39d9263';

  // API Actions
  static const String actionDeviceRegister = 'deviceRegister';
  static const String actionSearchAutoComplete = 'searchAutoComplete';
  static const String actionPopularStay = 'popularStay';

  // Search Types
  static const List<String> searchTypes = [
    'byCity',
    'byState',
    'byCountry',
    'byPropertyName',
  ];

  // Default Limits
  static const int defaultSearchLimit = 10;
  static const int defaultPopularLimit = 10;

  // Currency
  static const String defaultCurrency = 'INR';

  // Headers
  static const String headerAuthToken = 'authtoken';
  static const String headerVisitorToken = 'visitortoken';
  static const String headerContentType = 'Content-Type';
  static const String contentTypeJson = 'application/json';
}
