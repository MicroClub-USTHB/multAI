# Backend Alignment Report

## API Mismatches Found and Fixes Applied

### 1. Auth Endpoint Paths (ALL WRONG)
| Endpoint | Old Flutter Path | Backend Path | Fix Applied |
|---|---|---|---|
| Register | `/auth/register-login` | `/user/auth/register` | ✅ Split into separate endpoints |
| Login | `/auth/register-login` | `/user/auth/login` | ✅ Split into separate endpoints |
| Refresh | `/auth/refresh` | `/user/auth/refresh` | ✅ Fixed |
| Logout | `/auth/logout` | `/user/auth/logout` | ✅ Fixed |
| Me | `/auth/me` | `/user/auth/me` | ✅ Fixed |
| Revoke Device | `/auth/revoke-device` | `/user/auth/revoke-device` | ✅ Fixed |
| Update Token | `/auth/devices/token` | `/user/auth/devices/token` | ✅ Fixed |
| Inactivate Device | `/auth/devices/inactivate` | `/user/auth/devices/inactivate` | ✅ Fixed |

### 2. Auth Response Model Mismatch
| Field | Backend | Old Flutter | Fix |
|---|---|---|---|
| `access_token` | ✅ String | ✅ String | ✅ |
| `refresh_token` | ✅ String | ✅ String | ✅ |
| `session_id` | ✅ String | ❌ Missing | ✅ Added |
| `expires_in` | ✅ int | ❌ Missing | ✅ Added |
| `user_id` | ✅ UUID | ❌ Missing | ✅ Added |
| `is_new_user` | ✅ bool | ❌ Missing | ✅ Added |

### 3. Auth Request Fields
| Field | Backend | Flutter | Match |
|---|---|---|---|
| `email` | EmailStr | String | ✅ |
| `password` | String (8-128 chars) | String | ✅ |
| `device_name` | String (1-64) | String | ✅ |
| `device_type` | String (1-32) | String | ✅ |
| `device_id` | UUID | String | ✅ |

### 4. Notification Response
| Field | Backend Response | Flutter Parsing | Match |
|---|---|---|---|
| `items` | `list[UserNotificationSchema]` | ✅ `json['items']` | ✅ |
| `id` | UUID | String | ✅ |
| `type` | String | NotificationType enum | ✅ |
| `payload` | dict[str, Any] | Map<String, dynamic> | ✅ |
| `read_at` | datetime \| None | DateTime? | ✅ |
| `created_at` | datetime | DateTime | ✅ |

### 5. Photo Approval Endpoints
| Endpoint | Backend | Flutter | Match |
|---|---|---|---|
| GET approvals | `/user/photos/approvals?status&limit&offset` | ✅ Same | ✅ |
| POST decision | `/user/photos/{photo_id}/decision` | ✅ Same | ✅ |

### 6. Photos Endpoints
| Endpoint | Backend | Flutter | Match |
|---|---|---|---|
| GET my photos | `/user/photos?event_id&sort&limit&offset` | ✅ Same params | ✅ |
| GET event photos | `/user/photos/event/{event_id}?sort&limit&offset` | ✅ Same | ✅ |
| GET image | `/user/photos/{photo_id}/image` | ✅ Same | ✅ |

### 7. Event Endpoints
| Endpoint | Backend | Flutter | Match |
|---|---|---|---|
| GET my events | `/user/event/me` | ✅ Same | ✅ |
| POST join | `/user/event/join` | ✅ Same | ✅ |

### 8. Face Enrollment
| Endpoint | Backend | Flutter | Match |
|---|---|---|---|
| POST enroll | `/user/enroll` | ✅ Same path | ✅ |
| Upload field | `files: List[UploadFile]` | ❌ Individual field names | ✅ Fixed to use `files` field |
