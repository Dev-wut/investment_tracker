# แนวทางใช้งาน Dio 5.9.0 + Interceptors + ErrorHandler + ApiResult (Flutter/Dart)

> เอกสารฉบับนี้สรุปสิ่งที่เราคุยและปรับทั้งหมด เพื่อใช้ **Dio 5.9.0** อย่างเป็นระบบในแอปของคุณ  
> โฟกัส: โครงสร้างคลีน, แยก concerns, log ปลอดภัย, error ที่สม่ำเสมอ, และผลลัพธ์ที่ type-safe ผ่าน `ApiResult<T>`

---

## ภาพรวมสถาปัตยกรรม

- **DioClient** — ห่อหุ้ม `Dio` แบบ singleton + ตั้งค่า `BaseOptions` และลง `Interceptors`
- **LoggingInterceptor** — log แบบปลอดภัย (redact header ลับ), มี `requestId` และวัดเวลา (latency)
- **ErrorInterceptor** — จัดรูป error ให้สม่ำเสมอ, เก็บ `raw` payload, เลือก `next` หรือ `resolve`
- **ErrorHandler** — map จาก `DioException` -> `ErrorDetails (DataSource, message, code)` พร้อมดึงข้อความฝั่งเซิร์ฟเวอร์หากมี
- **ApiResult<T>** — โครงสร้างผลลัพธ์กลาง (success/failure) + helper สำหรับแปลงจาก `Response`/`DioException`
- **Unit** — ตัวแทน “สำเร็จแต่ไม่มีบอดี้” (เช่น 204/DELETE)

ภาพรวมการไหลงานเมื่อเรียก API:

```
DioClient -> Interceptors (Logging -> Error) -> Response/DioException
     \-> ApiResult.fromDioResponse / ApiResult.fromDioException
```

---

## ติดตั้งและเวอร์ชันที่เกี่ยวข้อง

```yaml
dependencies:
  dio: ^5.9.0
```

> เอกสารนี้ตั้งต้นกับ `dio: ^5.9.0`

---

## การตั้งค่า DioClient (ที่ควรมี)

จุดสำคัญ:
- กำหนด timeouts ทั้ง **connect / send / receive** (ชนิด `Duration`)
- ใช้ `Headers.acceptHeader` (และ `Headers.jsonContentType` เมื่อจำเป็น)
- พิจารณา `validateStatus` / `receiveDataWhenStatusError` ให้ตรงกับสไตล์การจัดการ error
- ลง `LoggingInterceptor` และ `ErrorInterceptor`

```dart
class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 15000),
        sendTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 15000),
        headers: <String, String>{
          Headers.acceptHeader: 'application/json',
        },
        // ดีฟอลต์: 2xx = success; ปรับตามรูปแบบที่คุณต้องการ
        validateStatus: (status) => status != null && status >= 200 && status < 300,
        receiveDataWhenStatusError: false,
      ),
    );

    _dio.interceptors.addAll([
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;
  Dio get dio => _dio;
}
```

> ถ้าต้องการเปลี่ยนให้ 4xx/5xx **ไม่** โยน error อัตโนมัติ ให้ตั้ง `validateStatus: (_) => true` แล้วให้ `ErrorInterceptor`/ชั้นบนจัดการเอง

---

## LoggingInterceptor (ส่วนสำคัญ)

หลักการ:
- **Redact** header ลับ (`Authorization`, `Cookie`, `X-API-KEY`)
- เพิ่ม `requestId` และเวลาที่เริ่ม (`extra['logId']`, `extra['ts']`) เพื่อคำนวณ latency
- Pretty-print เฉพาะกรณีที่เป็น JSON/Map/List และตัดความยาวบอดี้ใหญ่ๆ

> โค้ดเต็มไม่จำเป็น แต่ส่วนสำคัญ/หัวใจควรเป็นแบบนี้:

```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    options.extra['logId'] = id;
    options.extra['ts'] = DateTime.now().millisecondsSinceEpoch;

    // redact headers + log method/uri/body แบบย่อ
    // ...

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final id = response.requestOptions.extra['logId'] ?? '-';
    final ts = response.requestOptions.extra['ts'] as int?;
    final ms = ts != null ? (DateTime.now().millisecondsSinceEpoch - ts) : null;

    // log status + latency + body แบบย่อ
    // ...

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final id = err.requestOptions.extra['logId'] ?? '-';
    final ts = err.requestOptions.extra['ts'] as int?;
    final ms = ts != null ? (DateTime.now().millisecondsSinceEpoch - ts) : null;

    // log type/status/message + latency + error body แบบย่อ
    // ...

    handler.next(err);
  }
}
```

---

## ErrorHandler (แนวทาง mapping)

แนวทางที่แนะนำ:
- แยก `DioExceptionType` (timeout/cancel/connectionError/badResponse/unknown)
- เคส `badResponse`: ดึงข้อความจากเซิร์ฟเวอร์ถ้ามี (`message`, `error`, `detail`, `errors[0].message]` ฯลฯ)
- map สถานะยอดนิยม (400/401/403/404/422/429/5xx) -> `DataSource` ของคุณ
- ส่ง `ErrorDetails(source, message, code)`

> โค้ดเต็มคุณมีแล้ว — เพิ่มเพียงตัวช่วย `_extractServerMessage` และรองรับสถานะเพิ่ม จะยืดหยุ่นขึ้น

---

## ErrorInterceptor (จัดรูป error + คง payload เดิม)

หัวใจ:
- **ไม่** ใช้ `response.copyWith` (บางสภาพแวดล้อมไม่มี) -> ประกอบ `Response` ใหม่เอง
- ใส่ `raw` payload ดั้งเดิมลงใน `data` ที่จัดรูป เพื่อดีบัก
- เลือกได้ว่าจะ `handler.next(DioException(... response: shaped))` (คงเป็น error) หรือ `handler.resolve(shaped)` (เปลี่ยนเป็น success)

```dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ed = ErrorHandler.handle(err);

    final Response<Map<String, dynamic>> shaped = (err.response != null)
        ? Response<Map<String, dynamic>>(
            requestOptions: err.response!.requestOptions,
            data: {
              'status': false,
              'message': ed.message,
              'error_code': ed.code,
              'raw': err.response!.data,
            },
            statusCode: err.response!.statusCode,
            statusMessage: err.response!.statusMessage,
            headers: err.response!.headers,
            isRedirect: err.response!.isRedirect,
            redirects: err.response!.redirects,
            extra: Map<String, dynamic>.from(err.response!.extra ?? const {}),
          )
        : Response<Map<String, dynamic>>(
            requestOptions: err.requestOptions,
            statusCode: ed.code > 0 ? ed.code : null,
            data: {
              'status': false,
              'message': ed.message,
              'error_code': ed.code,
            },
          );

    // แนวทางที่ 1: คงเป็น error ต่อไป (ให้ชั้นบนจับ)
    handler.next(err.copyWith(response: shaped));

    // แนวทางที่ 2: เปลี่ยนเป็น success (อยาก handle ในชั้น response)
    // handler.resolve(shaped);
  }
}
```

---

## ApiResult<T> + Unit (สรุปแก่นสำคัญ)

- `ApiResult.success(data)` และ `ApiResult.failure(...)`
- ฟิลด์เมตา: `statusCode`, `source`, `raw`, `requestId`, `durationMs`
- helpers:
  - `fromDioResponse<T>(response, decoder)` — แปลง response + decode เป็น T
  - `fromDioEmpty(response)` — สำหรับ 204/DELETE/ไม่มีบอดี้ -> `ApiResult<Unit>`
  - `fromDioException<T>(e)` — แปลงข้อผิดพลาดที่โยนจาก Dio

> โค้ดเต็มของ `ApiResult` อยู่ในไฟล์ `api_result.dart` (คุณมีแล้วจากบทสนทนาก่อนหน้า)

---

## ตัวอย่างการใช้งาน (ละเอียด)

> สมมติโครงสร้างตอบกลับของเซิร์ฟเวอร์เป็นแบบนี้:
>
> ```json
> { "data": { "id": "u_1", "email": "john@doe.com", "name": "John" } }
> ```

### 1) โมเดลและดีโค้ดเดอร์

```dart
class User {
  final String id;
  final String email;
  final String name;
  User({required this.id, required this.email, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}

// decoder สำหรับ ApiResult.fromDioResponse
User decodeUser(dynamic json) {
  // ปรับตามโครงสร้างจริง เช่น json['data'] หรือ json โดยตรง
  final map = (json is Map<String, dynamic>) ? json['data'] : null;
  if (map is Map<String, dynamic>) {
    return User.fromJson(map);
  }
  throw const FormatException('unexpected response shape');
}
```

### 2) เรียก GET -> แปลงเป็น ApiResult<User>

```dart
final dio = DioClient().dio;

Future<ApiResult<User>> fetchMe() async {
  try {
    final res = await dio.get('/users/me');
    // สำเร็จ -> decode เป็น User
    return ApiResult.fromDioResponse<User>(res, decodeUser);
  } on DioException catch (e) {
    // ผิดพลาด -> แปลงด้วย ErrorHandler + เมตาดาทา (status/raw/requestId/latency)
    return ApiResult.fromDioException<User>(e);
  }
}
```

### 3) เรียก POST พร้อม body และรองรับ error

```dart
Future<ApiResult<User>> createUser({required String email, required String name}) async {
  try {
    final res = await dio.post(
      '/users',
      data: {'email': email, 'name': name},
    );
    return ApiResult.fromDioResponse<User>(res, decodeUser);
  } on DioException catch (e) {
    return ApiResult.fromDioException<User>(e);
  }
}
```

### 4) เรียก DELETE ที่ไม่ส่งบอดี้กลับ (ใช้ Unit)

```dart
Future<ApiResult<Unit>> deleteSession() async {
  try {
    final res = await dio.delete('/sessions/current');
    // กรณี 204/ไม่มีบอดี้ -> success(Unit)
    return ApiResult.fromDioEmpty(res);
  } on DioException catch (e) {
    return ApiResult.fromDioException<Unit>(e);
  }
}
```

### 5) ใช้งานผลลัพธ์ในชั้น UI/Bloc

```dart
final result = await fetchMe();

result.fold(
  onSuccess: (user) {
    // ใช้ user ได้ตรงๆ
    print('Hello, ${user.name}');
  },
  onFailure: (msg, code) {
    // แสดงข้อความ + โค้ด (หรือแม้แต่ดู result.raw เพื่อดีบัก)
    print('Error ($code): $msg');
  },
);
```

### 6) ตัวอย่าง mapping error message เพิ่มเติม

```dart
final result = await createUser(email: 'a@b.com', name: 'A');
final uiResult = result.mapError((msg, code) {
  if (code == 422) return 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
  if (code == 409) return 'อีเมลนี้ถูกใช้งานแล้ว';
  return msg ?? 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';
});
```

---

## คำแนะนำและทิปส์

- **Refresh token flow**: ถ้ามีการรีเฟรชโทเค็นใน Interceptor แยกอีกตัว ให้ล็อค queue (เช่นใช้ flag ใน `extra`) และ retry เฉพาะคำขอที่ล้มเหลวด้วย 401 เพื่อลดการยิงซ้ำ
- **Web/Browser**: ถ้ารันบน Flutter Web อาจต้องใช้ `BrowserHttpClientAdapter` และตั้งค่า CORS ฝั่งเซิร์ฟเวอร์ให้ถูก
- **CancelToken**: รองรับการยกเลิกคำขอในหน้าจอที่สลับเร็วๆ เพื่อลด `setState` บนหน้าจอที่ปิดไปแล้ว
- **อัปโหลดไฟล์**: ระวังอย่า log เนื้อไฟล์เต็มก้อน ใช้ `FormData(fields/files count)` แทน
- **validateStatus**: หากตั้งให้รับทุกสถานะ ควรให้ `ErrorInterceptor` เป็นจุดเดียวในการแปลง error -> ApiResult ที่สม่ำเสมอ

---

## เช็กลิสต์ก่อนใช้งานจริง

- [x] ตั้ง `connectTimeout / sendTimeout / receiveTimeout`
- [x] ใช้ `Headers.acceptHeader` (และตั้ง `content-type` เฉพาะที่จำเป็น)
- [x] ลง `LoggingInterceptor` และ redact header ลับ
- [x] ตั้ง `validateStatus`/`receiveDataWhenStatusError` ให้ตรงกับ flow
- [x] `ErrorInterceptor` ประกอบ `Response` เอง + เก็บ `raw`
- [x] `ErrorHandler` ดึงข้อความจากเซิร์ฟเวอร์ถ้ามี และ map สถานะครบถ้วน
- [x] ใช้ `ApiResult<T>` + `Unit` สำหรับ no-content
- [x] ทุกที่ที่เรียก API: แปลงเป็น `ApiResult` เสมอ (`fromDioResponse`, `fromDioEmpty`, `fromDioException`)

---

## ภาคผนวก: โค้ดประกอบที่จำเป็นสั้นๆ

**Unit**
```dart
class Unit {
  const Unit();
  @override
  String toString() => 'Unit';
}
const unit = Unit();
```

**โครงของ ApiResult (ตัดมาเฉพาะแก่น)**
```dart
class ApiResult<T> {
  // fields: success, data, errorMessage, errorCode, statusCode, source, raw, requestId, durationMs
  // factory: success(), failure()
  // methods: map(), mapError(), fold()
  // static helpers: fromDioResponse(), fromDioEmpty(), fromDioException()
}
```

**การใช้ใน Repository**
```dart
class UserRepo {
  final Dio _dio;
  UserRepo(this._dio);

  Future<ApiResult<User>> fetchMe() async {
    try {
      final res = await _dio.get('/users/me');
      return ApiResult.fromDioResponse<User>(res, (j) => User.fromJson(j['data']));
    } on DioException catch (e) {
      return ApiResult.fromDioException<User>(e);
    }
  }
}
```

---

> ถ้าต้องการไฟล์ตัวอย่างโค้ดเต็มๆ ของ `LoggingInterceptor`, `ErrorInterceptor`, `ErrorHandler`, `ApiResult` ในโปรเจ็กต์จริง แจ้งได้ครับ ผมจะแพ็กเป็นโฟลเดอร์พร้อมใช้งานให้ทันที