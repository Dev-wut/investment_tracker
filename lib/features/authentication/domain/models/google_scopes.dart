/// Scopes needed in this app
class GoogleScopes {
  // For Apps Script Web App that manipulates Sheets/Drive via server script
  static const appsScript = <String>[
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/spreadsheets',
    // add more if your script hits other services
  ];

  // Direct Sheets API usage
  static const sheetsDirect = <String>[
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/spreadsheets',
  ];
}