# Performance Report

## Bottlenecks Found and Optimizations Applied

### 1. Auto-loading 20 Photo Images on Gallery Load
**Location**: `lib/features/gallery/presentation/bloc/gallery_bloc.dart:47-49`
**Issue**: Immediately loads 20 photo images when gallery is displayed.
**Impact**: Network burst, potential memory pressure.
**Recommendation**: Implement lazy loading with viewport-based loading.

### 2. Two HTTP Clients
**Location**: ApiClient (http) and DioClient (dio) both instantiated
**Issue**: Duplicate network stacks consume memory.
**Status**: Identified for consolidation.

### 3. Repeated Package Info Calls
**Location**: `lib/core/network/api_client.dart:37-39`
**Issue**: `PackageInfo.fromPlatform()` called on every request.
**Optimization**: Should be fetched once and cached.

### 4. Repeated Device Info Calls
**Location**: `lib/core/network/api_client.dart:41-52`
**Issue**: `DeviceInfoPlugin` created and queried on every request.
**Optimization**: Should be fetched once and cached.

### 5. Network Check Before Every API Call
**Location**: `lib/core/network/api_client.dart:57-61`
**Issue**: `checkConnection()` called before every request adds 3-second timeout.
**Impact**: Adds latency even when connected.
**Recommendation**: Use reactive connectivity monitoring instead of per-request checks.

### 6. Heavy debugPrint in Release
**Location**: Multiple files
**Fix**: Removed debugPrint calls from production paths.
**Impact**: Reduced I/O in release builds.

### 7. No Request Caching
**Issue**: GET requests (notifications, events, photos) are fetched fresh on every load.
**Recommendation**: Add HTTP caching headers and local cache layer.
