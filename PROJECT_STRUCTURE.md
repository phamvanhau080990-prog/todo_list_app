# Cấu trúc dự án Todo List

## Mục đích tổng quan

Dự án này là một ứng dụng todo list dạng phân tách frontend-backend:

- Frontend: Flutter, cung cấp giao diện người dùng để xem, thêm, sửa, xóa và đánh dấu todo.
- Backend: FastAPI + SQLAlchemy, cung cấp API REST để lưu trữ và xử lý dữ liệu todo.
- Cơ sở dữ liệu: SQLite (file `todo_backend/todo.db`).

Tài liệu này dùng làm căn cứ để mở rộng dự án sau này, đặc biệt khi thêm tính năng, module mới hoặc tách service.

---

## Cấu trúc thư mục chính

```text
todo_list_app/
├── .github/                     # Cấu hình dành cho GitHub, ví dụ Copilot instructions
├── operation/                   # Script vận hành và tiện ích hệ thống
│   └── duckdns/                 # Script cập nhật DNS DuckDNS
├── test/                        # Script kiểm thử tải / kiểm thử hiệu năng
├── todo_backend/                # Backend API
│   ├── database.py              # Cấu hình kết nối và tạo bảng DB
│   ├── main.py                  # Entry point của FastAPI, định nghĩa API endpoints
│   ├── models.py                # Model ORM cho Todo
│   ├── schemas.py               # Schema Pydantic cho request/response
│   ├── todo.db                  # Cơ sở dữ liệu SQLite local
│   └── venv/                    # Môi trường ảo Python
├── todo_frontend/               # Frontend Flutter
│   ├── android/                 # Project Android native
│   ├── ios/                     # Project iOS native
│   ├── lib/                     # Source code Flutter chính
│   │   ├── config/              # Cấu hình chung như endpoint API
│   │   ├── models/              # Model dữ liệu dùng trong frontend
│   │   ├── services/            # Logic gọi API và xử lý dữ liệu
│   │   └── main.dart            # Entry point của ứng dụng Flutter
│   ├── test/                    # Test Flutter
│   ├── web/                     # Build web
│   ├── windows/                 # Project Windows native
│   ├── pubspec.yaml             # Cấu hình package Flutter và dependencies
│   └── README.md                # Hướng dẫn chạy frontend
└── PROJECT_STRUCTURE.md         # Tài liệu cấu trúc dự án hiện tại
```

---

## Ý nghĩa từng thành phần

### 1. Thư mục gốc

- `todo_list_app/`
  - Là thư mục gốc chứa toàn bộ dự án.
  - Nên dùng làm nơi lưu tài liệu thiết kế, hướng dẫn vận hành và các script chung.

### 2. Thư mục `.github/`

- Chứa cấu hình liên quan đến GitHub.
- Trong dự án này, có thể dùng để lưu `copilot-instructions.md` hoặc các workflow CI/CD.

### 3. Thư mục `operation/`

- Chứa các script phục vụ vận hành hệ thống.
- Ví dụ:
  - `todo_backend_startup.bat`: khởi động backend.
  - `duckdns/update_duckdns.bat`: cập nhật DNS DuckDNS nếu hệ thống dùng domain động.

### 4. Thư mục `test/`

- Chứa các script kiểm thử tải / kiểm thử hiệu năng.
- Có thể dùng để kiểm tra mức độ chịu tải của API hoặc ứng dụng.

### 5. Thư mục `todo_backend/`

Là phần server-side của ứng dụng.

#### `database.py`
- Quản lý kết nối cơ sở dữ liệu.
- Tạo engine SQLAlchemy và SessionLocal.
- Dùng để khởi tạo kết nối với SQLite.

#### `main.py`
- File entry point của FastAPI.
- Định nghĩa các endpoint:
  - `GET /todos`
  - `POST /todos`
  - `PUT /todos/{todo_id}`
  - `DELETE /todos/{todo_id}`
- Chịu trách nhiệm xử lý request và tương tác với database.

#### `models.py`
- Định nghĩa model dữ liệu `Todo`.
- Là lớp ORM biểu diễn bảng dữ liệu trong database.

#### `schemas.py`
- Định nghĩa schema dùng cho request và response.
- Giúp FastAPI validate dữ liệu đầu vào và đầu ra.
- Phù hợp để tách riêng logic dữ liệu và logic API.

#### `todo.db`
- File cơ sở dữ liệu SQLite local.
- Dùng để lưu trữ dữ liệu todo trong môi trường phát triển.

#### `venv/`
- Môi trường ảo Python cho backend.
- Không nên đưa vào git nếu không cần thiết.

### 6. Thư mục `todo_frontend/`

Là phần client-side của ứng dụng.

#### `lib/main.dart`
- File chính của ứng dụng Flutter.
- Chứa UI chính, xử lý hiển thị danh sách todo và các thao tác CRUD.
- Hiện tại có thể chứa cả UI và logic gọi API, nhưng về lâu dài nên tách thành các file riêng hơn.

#### `lib/config/`
- Chứa cấu hình dùng chung cho frontend.
- Ví dụ: endpoint API (`api_endpoints.dart`).

#### `lib/models/`
- Chứa model dữ liệu biểu diễn cho các object trên frontend.
- Dùng để làm việc với dữ liệu trong Dart thay vì dùng map thông thường.

#### `lib/services/`
- Chứa lớp service để gọi HTTP API.
- Nên tách riêng phần giao tiếp backend khỏi UI để dễ bảo trì và mở rộng.

#### `pubspec.yaml`
- File cấu hình package Flutter.
- Chứa dependencies như `http`, `flutter_lints`, và thông tin project.

#### `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`
- Là project native tương ứng với từng nền tảng.
- Dùng để build và chạy ứng dụng trên mobile/desktop/web.

---

## Mở rộng trong tương lai

Khi dự án phát triển, nên giữ nguyên cấu trúc phân tầng sau:

- Backend:
  - Tách router, service, repository, model rõ ràng.
  - Có thể thêm file `routers/`, `services/`, `repositories/`.

- Frontend:
  - Tách UI và logic API.
  - Có thể thêm:
    - `lib/screens/` cho các màn hình
    - `lib/widgets/` cho component tái sử dụng
    - `lib/providers/` hoặc `lib/blocs/` nếu dùng state management

- Tổng thể:
  - Thêm file `README.md` ở gốc để hướng dẫn cài đặt và chạy toàn bộ hệ thống.
  - Thêm `.gitignore` đầy đủ để loại bỏ file build, thư mục ảo và file dữ liệu local.

---

## Ghi chú phát triển

- Hiện tại dự án đang ở mức MVP (Minimum Viable Product), nên cấu trúc còn khá đơn giản.
- Với mục tiêu mở rộng lâu dài, nên ưu tiên:
  1. Tách logic API khỏi UI.
  2. Tách model và service rõ ràng.
  3. Dùng cấu trúc thư mục nhất quán cho cả backend và frontend.
  4. Giữ tài liệu này cập nhật mỗi khi thay đổi cấu trúc hoặc thêm module mới.
