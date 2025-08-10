import 'package:http/http.dart' as http;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/drive/v3.dart' as drive;

import '../../../features/authentication/domain/repositories/google_auth_repository.dart'; // if you also manage files/folders


class _AuthClient extends http.BaseClient {
  final http.Client _inner;
  final String _token;
  _AuthClient(this._inner, this._token);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }
}

class SheetsApiClient {
  final GoogleAuthRepository _authRepo;
  final http.Client _http;
  SheetsApiClient(this._authRepo, {http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const _scopes = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive.file', // create/manage spreadsheet files user owns
  ];

  Future<sheets.SheetsApi> _sheets() async {
    final token = await _authRepo.getAccessToken(scopes: _scopes);
    return sheets.SheetsApi(_AuthClient(_http, token));
  }

  Future<drive.DriveApi> _drive() async {
    final token = await _authRepo.getAccessToken(scopes: _scopes);
    return drive.DriveApi(_AuthClient(_http, token));
  }

  // ==== Quickstart helpers ====

  /// Create a spreadsheet and return its ID
  Future<String> createSpreadsheet(String title, {String? folderId}) async {
    final api = await _sheets();
    final created = await api.spreadsheets.create(
      sheets.Spreadsheet(properties: sheets.SpreadsheetProperties(title: title)),
    );
    final id = created.spreadsheetId!;

    if (folderId != null) {
      // Move file into a folder using Drive API
      final drv = await _drive();

      // Some environments infer Object for get(); handle both model and Map
      final meta = await drv.files.get(id, $fields: 'parents');
      List<String> parents;
      if (meta is drive.File) {
        parents = meta.parents ?? const <String>[];
      } else if (meta is Map) {
        parents = ((meta['parents'] as List?)?.cast<String>()) ?? const <String>[];
      } else {
        parents = const <String>[];
      }
      final previousParents = parents.join(',');

      await drv.files.update(
        drive.File(),
        id,
        addParents: folderId,
        removeParents: previousParents.isEmpty ? null : previousParents,
        supportsAllDrives: true,
      );
    }
    return id;
  }

  /// Ensure a worksheet (tab) exists; if not, add it.
  Future<void> ensureSheet(String spreadsheetId, String sheetTitle) async {
    final api = await _sheets();
    final meta = await api.spreadsheets.get(spreadsheetId);
    final exists = (meta.sheets ?? []).any((s) => s.properties?.title == sheetTitle);
    if (exists) return;
    await api.spreadsheets.batchUpdate(
      sheets.BatchUpdateSpreadsheetRequest(requests: [
        sheets.Request(addSheet: sheets.AddSheetRequest(
          properties: sheets.SheetProperties(title: sheetTitle),
        )),
      ]),
      spreadsheetId,
    );
  }

  /// Read values in A1 notation
  Future<List<List<Object?>>> readRange(String spreadsheetId, String a1Range) async {
    final api = await _sheets();
    final resp = await api.spreadsheets.values.get(spreadsheetId, a1Range);
    return resp.values?.map((row) => row.cast<Object?>()).toList() ?? const [];
  }

  /// Append a row at the end of the range
  Future<void> appendRow(String spreadsheetId, String a1Range, List<Object?> row) async {
    final api = await _sheets();
    await api.spreadsheets.values.append(
      sheets.ValueRange(values: [row]),
      spreadsheetId,
      a1Range,
      valueInputOption: 'USER_ENTERED',
    );
  }

  /// Update an exact A1 range with values (2D array)
  Future<void> updateRange(String spreadsheetId, String a1Range, List<List<Object?>> values) async {
    final api = await _sheets();
    await api.spreadsheets.values.update(
      sheets.ValueRange(values: values),
      spreadsheetId,
      a1Range,
      valueInputOption: 'USER_ENTERED',
    );
  }

  /// Batch write multiple ranges efficiently
  Future<void> batchWrite(String spreadsheetId, Map<String, List<List<Object?>>> writes) async {
    final api = await _sheets();
    final data = writes.entries
        .map((e) => sheets.ValueRange(range: e.key, values: e.value))
        .toList();
    await api.spreadsheets.values.batchUpdate(
      sheets.BatchUpdateValuesRequest(
        valueInputOption: 'USER_ENTERED',
        data: data,
      ),
      spreadsheetId,
    );
  }

  /// Optional: protect a range (e.g., header row)
  Future<void> protectHeader(String spreadsheetId, String sheetTitle) async {
    final api = await _sheets();
    final meta = await api.spreadsheets.get(spreadsheetId, includeGridData: false);
    final sheet = meta.sheets?.firstWhere((s) => s.properties?.title == sheetTitle);
    final sheetId = sheet?.properties?.sheetId;
    if (sheetId == null) return;
    await api.spreadsheets.batchUpdate(
      sheets.BatchUpdateSpreadsheetRequest(requests: [
        sheets.Request(addProtectedRange: sheets.AddProtectedRangeRequest(
          protectedRange: sheets.ProtectedRange(
            range: sheets.GridRange(sheetId: sheetId, startRowIndex: 0, endRowIndex: 1),
            description: 'Protect header',
            editors: sheets.Editors(users: []), // only owner by default
          ),
        )),
      ]),
      spreadsheetId,
    );
  }
}