import 'package:googleapis/sheets/v4.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';

import '../models/investment.dart';
import '../utils/constants.dart';

class GoogleSheetsService {
  static const List<String> _scopes = <String>[
    SheetsApi.spreadsheetsScope,
  ];

  SheetsApi? _sheetsApi;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _errorMessage = '';

  final StreamController<String> _statusController = StreamController<String>.broadcast();

  // Streams
  Stream<String> get statusStream => _statusController.stream;

  // ตรวจสอบสถานะ login
  bool get isSignedIn => _currentUser != null;
  bool get isAuthorized => _isAuthorized;
  String get errorMessage => _errorMessage;
  GoogleSignInAccount? get currentUser => _currentUser;

  /// *** ต้องเรียก initialize() ก่อนใช้งานทุกกรณี ***
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
  }) async {
    try {
      _statusController.add('Initializing Google Sign In...');

      final GoogleSignIn signIn = GoogleSignIn.instance;

      await signIn.initialize(
          clientId: clientId,
          serverClientId: serverClientId
      );

      // Listen to authentication events
      signIn.authenticationEvents
          .listen(_handleAuthenticationEvent)
          .onError(_handleAuthenticationError);

      // Attempt lightweight authentication
      await signIn.attemptLightweightAuthentication();

      _statusController.add('Google Sign In initialized successfully');
    } catch (e) {
      _errorMessage = 'Initialization error: $e';
      _statusController.add(_errorMessage);
      print('GoogleSheetsService initialization error: $e');
    }
  }

  /// Handle authentication events
  Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    try {
      final GoogleSignInAccount? user = switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };

      // Check for existing authorization
      final GoogleSignInClientAuthorization? authorization =
      await user?.authorizationClient.authorizationForScopes(_scopes);

      _currentUser = user;
      _isAuthorized = authorization != null;
      _errorMessage = '';

      if (user != null && authorization != null) {
        await _initSheetsApi(user);
        _statusController.add('Signed in and authorized successfully');
      } else if (user != null) {
        _statusController.add('Signed in but not authorized for Sheets API');
      } else {
        _statusController.add('Signed out');
      }
    } catch (e) {
      _errorMessage = 'Authentication event error: $e';
      _statusController.add(_errorMessage);
      print('Authentication event error: $e');
    }
  }

  /// Handle authentication errors
  Future<void> _handleAuthenticationError(Object e) async {
    _currentUser = null;
    _isAuthorized = false;
    _errorMessage = e is GoogleSignInException
        ? _errorMessageFromSignInException(e)
        : 'Unknown error: $e';

    _statusController.add(_errorMessage);
  }

  /// ลงชื่อเข้าใช้ Google
  Future<bool> signIn() async {
    try {
      _statusController.add('Attempting to sign in...');

      if (GoogleSignIn.instance.supportsAuthenticate()) {
        await GoogleSignIn.instance.authenticate();
        return _currentUser != null;
      } else {
        _statusController.add('This platform does not support authenticate method');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Sign in error: $e';
      _statusController.add(_errorMessage);
      print('GoogleSheetsService signIn error: $e');
      return false;
    }
  }

  /// ขอสิทธิ์ในการเข้าถึง Google Sheets
  Future<bool> requestAuthorization() async {
    if (_currentUser == null) {
      _errorMessage = 'User not signed in';
      _statusController.add(_errorMessage);
      return false;
    }

    try {
      _statusController.add('Requesting authorization...');

      final GoogleSignInClientAuthorization authorization =
      await _currentUser!.authorizationClient.authorizeScopes(_scopes);

      _isAuthorized = true;
      _errorMessage = '';

      await _initSheetsApi(_currentUser!);
      _statusController.add('Authorization granted successfully');
      return true;
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
      _statusController.add(_errorMessage);
      return false;
    } catch (e) {
      _errorMessage = 'Authorization error: $e';
      _statusController.add(_errorMessage);
      print('Authorization error: $e');
      return false;
    }
  }

  /// ออกจากระบบ
  Future<void> signOut() async {
    try {
      _statusController.add('Signing out...');
      await GoogleSignIn.instance.disconnect();

      _currentUser = null;
      _isAuthorized = false;
      _sheetsApi = null;
      _errorMessage = '';

      _statusController.add('Signed out successfully');
    } catch (e) {
      _errorMessage = 'Sign out error: $e';
      _statusController.add(_errorMessage);
      print('Sign out error: $e');
    }
  }

  // =============================
  //   Google Sheets API methods
  // =============================

  Future<void> _initSheetsApi(GoogleSignInAccount user) async {
    try {
      final Map<String, String>? headers =
      await user.authorizationClient.authorizationHeaders(_scopes);

      if (headers == null) {
        throw Exception('Failed to get authorization headers');
      }

      final client = _GoogleSignInAuthClient(headers);
      _sheetsApi = SheetsApi(client);

      _statusController.add('Sheets API initialized successfully');
    } catch (e) {
      _errorMessage = 'Failed to initialize Sheets API: $e';
      _statusController.add(_errorMessage);
      print('Error initializing Sheets API: $e');
      rethrow;
    }
  }

  /// สร้างสเปรดชีต
  Future<String?> createSpreadsheet(String title) async {
    if (_sheetsApi == null) {
      _errorMessage = 'Sheets API not initialized. Please sign in and authorize first.';
      _statusController.add(_errorMessage);
      return null;
    }

    try {
      _statusController.add('Creating spreadsheet...');

      final spreadsheet = Spreadsheet(
        properties: SpreadsheetProperties(title: title),
        sheets: [
          Sheet(
              properties: SheetProperties(
                title: 'Investments',
                gridProperties: GridProperties(
                    rowCount: 1000,
                    columnCount: 15
                ),
              )
          ),
        ],
      );

      final response = await _sheetsApi!.spreadsheets.create(spreadsheet);
      final spreadsheetId = response.spreadsheetId;

      if (spreadsheetId != null) {
        await _addHeaders(spreadsheetId);
        _statusController.add('Spreadsheet created successfully');
        return spreadsheetId;
      }

      _errorMessage = 'Failed to create spreadsheet - no ID returned';
      _statusController.add(_errorMessage);
      return null;
    } catch (e) {
      _errorMessage = 'Create spreadsheet error: $e';
      _statusController.add(_errorMessage);
      print('Create spreadsheet error: $e');
      return null;
    }
  }

  Future<void> _addHeaders(String spreadsheetId) async {
    try {
      final headers = [
        'ID', 'Symbol', 'Name', 'Type', 'Quantity', 'Buy Price', 'Current Price',
        'Purchase Date', 'Initial Value', 'Current Value', 'Profit/Loss', 'Profit/Loss %',
        'Notes', 'Last Updated'
      ];

      final valueRange = ValueRange(values: [headers]);
      await _sheetsApi!.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        'Investments!A1:N1',
        valueInputOption: 'RAW',
      );

      // Format headers (optional)
      await _formatHeaders(spreadsheetId);
    } catch (e) {
      print('Add headers error: $e');
    }
  }

  Future<void> _formatHeaders(String spreadsheetId) async {
    try {
      final request = Request(
        updateCells: UpdateCellsRequest(
          range: GridRange(
            sheetId: 0,
            startRowIndex: 0,
            endRowIndex: 1,
            startColumnIndex: 0,
            endColumnIndex: 14,
          ),
          rows: [
            RowData(
              values: List.generate(14, (index) => CellData(
                userEnteredFormat: CellFormat(
                  backgroundColor: Color(
                    red: 0.9,
                    green: 0.9,
                    blue: 0.9,
                  ),
                  textFormat: TextFormat(
                    bold: true,
                  ),
                ),
              )),
            ),
          ],
          fields: 'userEnteredFormat.backgroundColor,userEnteredFormat.textFormat.bold',
        ),
      );

      final batchUpdateRequest = BatchUpdateSpreadsheetRequest(requests: [request]);
      await _sheetsApi!.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);
    } catch (e) {
      print('Format headers error: $e');
    }
  }

  Future<bool> saveInvestment(String spreadsheetId, Investment investment) async {
    if (_sheetsApi == null) {
      _errorMessage = 'Sheets API not initialized';
      _statusController.add(_errorMessage);
      return false;
    }

    try {
      final row = [
        investment.id,
        investment.symbol,
        investment.name,
        investment.type.toString().split('.').last,
        investment.quantity.toString(),
        investment.buyPrice.toString(),
        investment.currentPrice.toString(),
        investment.purchaseDate.toIso8601String(),
        investment.initialValue.toString(),
        investment.currentValue.toString(),
        investment.profitLoss.toString(),
        investment.profitLossPercentage.toString(),
        investment.notes ?? '',
        DateTime.now().toIso8601String(),
      ];

      final valueRange = ValueRange(values: [row]);

      await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        'Investments!A:N',
        valueInputOption: 'RAW',
      );

      _statusController.add('Investment saved successfully');
      return true;
    } catch (e) {
      _errorMessage = 'Save investment error: $e';
      _statusController.add(_errorMessage);
      print('Save investment error: $e');
      return false;
    }
  }

  Future<List<Investment>> getInvestments(String spreadsheetId) async {
    if (_sheetsApi == null) {
      _errorMessage = 'Sheets API not initialized';
      _statusController.add(_errorMessage);
      return [];
    }

    try {
      final response = await _sheetsApi!.spreadsheets.values.get(
        spreadsheetId,
        'Investments!A2:N',
      );

      final values = response.values ?? [];
      final investments = values.map((row) {
        return Investment.fromMap({
          'id': row.isNotEmpty ? row[0] : '',
          'symbol': row.length > 1 ? row[1] : '',
          'name': row.length > 2 ? row[2] : '',
          'type': row.length > 3 ? row[3] : 'stock',
          'quantity': row.length > 4 ? row[4] : '0',
          'buy_price': row.length > 5 ? row[5] : '0',
          'current_price': row.length > 6 ? row[6] : '0',
          'purchase_date': row.length > 7 ? row[7] : DateTime.now().toIso8601String(),
          'notes': row.length > 12 ? row[12] : '',
        });
      }).toList();

      _statusController.add('Investments loaded successfully');
      return investments;
    } catch (e) {
      _errorMessage = 'Get investments error: $e';
      _statusController.add(_errorMessage);
      print('Get investments error: $e');
      return [];
    }
  }

  // อัพเดทราคาปัจจุบัน
  Future<bool> updateCurrentPrices(String spreadsheetId, List<Investment> investments) async {
    if (_sheetsApi == null) {
      _errorMessage = 'Sheets API not initialized';
      _statusController.add(_errorMessage);
      return false;
    }

    try {
      final requests = <Request>[];

      for (int i = 0; i < investments.length; i++) {
        final investment = investments[i];
        final rowIndex = i + 1; // เริ่มจากแถวที่ 2 (index 1)

        requests.add(
          Request(
            updateCells: UpdateCellsRequest(
              range: GridRange(
                sheetId: 0,
                startRowIndex: rowIndex,
                endRowIndex: rowIndex + 1,
                startColumnIndex: 6, // Current Price column
                endColumnIndex: 12, // ถึง Profit/Loss % column
              ),
              rows: [
                RowData(
                  values: [
                    CellData(userEnteredValue: ExtendedValue(numberValue: investment.currentPrice.toDouble())),
                    CellData(userEnteredValue: ExtendedValue(stringValue: investment.purchaseDate.toIso8601String())),
                    CellData(userEnteredValue: ExtendedValue(numberValue: investment.initialValue.toDouble())),
                    CellData(userEnteredValue: ExtendedValue(numberValue: investment.currentValue.toDouble())),
                    CellData(userEnteredValue: ExtendedValue(numberValue: investment.profitLoss.toDouble())),
                    CellData(userEnteredValue: ExtendedValue(numberValue: investment.profitLossPercentage.toDouble())),
                  ],
                ),
              ],
              fields: 'userEnteredValue',
            ),
          ),
        );
      }

      if (requests.isNotEmpty) {
        final batchUpdateRequest = BatchUpdateSpreadsheetRequest(requests: requests);
        await _sheetsApi!.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);
      }

      _statusController.add('Prices updated successfully');
      return true;
    } catch (e) {
      _errorMessage = 'Update current prices error: $e';
      _statusController.add(_errorMessage);
      print('Update current prices error: $e');
      return false;
    }
  }

  // ลบการลงทุน
  Future<bool> deleteInvestment(String spreadsheetId, String investmentId) async {
    if (_sheetsApi == null) {
      _errorMessage = 'Sheets API not initialized';
      _statusController.add(_errorMessage);
      return false;
    }

    try {
      // หาแถวที่ต้องลบ
      final response = await _sheetsApi!.spreadsheets.values.get(
        spreadsheetId,
        'Investments!A:A',
      );

      final values = response.values ?? [];
      int? rowToDelete;

      for (int i = 0; i < values.length; i++) {
        if (values[i].isNotEmpty && values[i][0] == investmentId) {
          rowToDelete = i;
          break;
        }
      }

      if (rowToDelete != null) {
        final request = Request(
          deleteDimension: DeleteDimensionRequest(
            range: DimensionRange(
              sheetId: 0,
              dimension: 'ROWS',
              startIndex: rowToDelete,
              endIndex: rowToDelete + 1,
            ),
          ),
        );

        final batchUpdateRequest = BatchUpdateSpreadsheetRequest(requests: [request]);
        await _sheetsApi!.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);

        _statusController.add('Investment deleted successfully');
        return true;
      }

      _errorMessage = 'Investment not found';
      _statusController.add(_errorMessage);
      return false;
    } catch (e) {
      _errorMessage = 'Delete investment error: $e';
      _statusController.add(_errorMessage);
      print('Delete investment error: $e');
      return false;
    }
  }

  // Utility methods
  String _errorMessageFromSignInException(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }

  void dispose() {
    _statusController.close();
  }
}

/// Dart http Client ที่ inject header สำหรับ Google Auth
class _GoogleSignInAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _GoogleSignInAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}