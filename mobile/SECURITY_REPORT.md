# Security Report

## Issues Found and Fixes Applied

### 1. Hardcoded Sensitive Paths
**Location**: `lib/core/security/device_security.dart`
**Issue**: Hardcoded paths for root detection (both Android and iOS).
**Severity**: Low
**Status**: Mitigated (paths are non-sensitive but should be configurable)

### 2. Insecure Storage for Tokens
**Location**: Auth flow
**Issue**: Previously used SharedPreferences for token storage.
**Fix**: Tokens are now stored using `FlutterSecureStorage` (AES-256 encrypted on Android, Keychain on iOS).
**Severity**: High → Fixed

### 3. Sensitive Data in Logs
**Location**: `lib/core/network/network_info.dart`, `lib/core/security/session_manager.dart`
**Issue**: `debugPrint` exposed sensitive information in release builds.
**Fix**: Removed all `debugPrint` calls from production code paths.
**Severity**: High → Fixed

### 4. Hardcoded API Base URLs
**Location**: `.env` file
**Issue**: `BASE_URL=http://192.168.100.2:8000` - development URL with HTTP
**Fix**: Added `EnvValidator.validateProduction()` check that warns if HTTPS is not used in production.
**Severity**: Medium → Mitigated

### 5. Missing API Endpoint Authorization
**Location**: All auth endpoints
**Issue**: Auth endpoints were missing `/user/auth/` prefix and were incorrectly mapped.
**Fix**: All endpoints now correctly map to backend routes with proper authentication requirements.
**Severity**: High → Fixed

### 6. Missing Auth Response Fields
**Location**: `lib/features/auth/domain/entities/auth_entity.dart`
**Issue**: Auth response was missing `sessionId`, `expiresIn`, `userId`, `isNewUser`.
**Fix**: Added all missing fields from backend contract.
**Severity**: High → Fixed

### 7. Duplicate HTTP Clients
**Location**: `ApiClient` (http) and `DioClient` (dio)
**Issue**: Two competing HTTP clients causing maintenance burden and potential security gaps.
**Severity**: Medium
**Status**: Identified for future consolidation to single Dio-based client.

### 8. Combined Register/Login Endpoint
**Location**: `lib/core/constants/end_points.dart`
**Issue**: Used a single `/auth/register-login` endpoint that doesn't exist on backend.
**Fix**: Split into separate `/user/auth/register` and `/user/auth/login` endpoints.
**Severity**: Critical → Fixed
