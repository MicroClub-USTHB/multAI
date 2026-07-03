import 'package:flutter/material.dart';
import 'app_exception.dart';
import 'error_presentation.dart';

class ErrorMapper {
  const ErrorMapper();

  String getUserFriendlyMessage(AppException exception) {
    return _productionMessage(exception);
  }

  String getLogMessage(AppException exception) {
    return exception.debugInfo;
  }

  ErrorPresentation mapToPresentation(AppException exception) {
    return switch (exception) {
      NetworkException _ => _networkPresentation(exception),
      TimeoutException _ => _timeoutPresentation(exception),
      RateLimitException _ => _rateLimitPresentation(exception),
      AuthenticationException _ => _authPresentation(exception),
      ServerException _ => _serverPresentation(exception),
      NotFoundException _ => _notFoundPresentation(exception),
      ValidationException _ => _validationPresentation(exception),
      CacheException _ => _cachePresentation(exception),
      AIProviderUnavailableException _ => _aiUnavailablePresentation(exception),
      UnknownException _ => _unknownPresentation(exception),
      _ => _unknownPresentation(exception),
    };
  }

  String _message(AppException e, String fallback) {
    return e.message.isNotEmpty ? e.message : fallback;
  }

  ErrorPresentation _networkPresentation(AppException e) {
    return ErrorPresentation(
      title: 'No Internet Connection',
      description: _message(
        e,
        'Please check your internet connection and try again.',
      ),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.wifi_off_rounded,
    );
  }

  ErrorPresentation _timeoutPresentation(AppException e) {
    return ErrorPresentation(
      title: 'Request Timed Out',
      description: _message(e, 'The request took too long. Please try again.'),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.timer_off_rounded,
    );
  }

  ErrorPresentation _rateLimitPresentation(AppException e) {
    return ErrorPresentation(
      title: 'Too Many Requests',
      description: _message(e, 'Please wait before trying again.'),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.speed_rounded,
    );
  }

  ErrorPresentation _authPresentation(AppException e) {
    return ErrorPresentation(
      title: 'Session Expired',
      description: _message(e, 'Authentication failed. Please sign in again.'),
      actionLabel: 'Sign In',
      action: ErrorAction.signIn,
      illustration: Icons.lock_outline_rounded,
    );
  }

  ErrorPresentation _serverPresentation(ServerException e) {
    final status = e.statusCode;
    if (status == 403) {
      return ErrorPresentation(
        title: 'Access Denied',
        description: _message(
          e,
          "You don't have permission to access this resource.",
        ),
        actionLabel: 'Go Back',
        action: ErrorAction.goBack,
        illustration: Icons.lock_outline_rounded,
      );
    }
    if (status == 404) {
      return ErrorPresentation(
        title: 'Not Found',
        description: _message(e, 'The requested resource could not be found.'),
        actionLabel: 'Retry',
        action: ErrorAction.retry,
        illustration: Icons.search_off_rounded,
      );
    }
    if (status == 409) {
      return ErrorPresentation(
        title: 'Conflict',
        description: _message(
          e,
          'The requested operation conflicts with current data.',
        ),
        actionLabel: 'Retry',
        action: ErrorAction.retry,
        illustration: Icons.error_outline_rounded,
      );
    }
    if (status == 422) {
      return ErrorPresentation(
        title: 'Validation Error',
        description: _message(e, 'Please check your input and try again.'),
        actionLabel: 'Retry',
        action: ErrorAction.retry,
        illustration: Icons.error_outline_rounded,
      );
    }
    if (status == 429) {
      return ErrorPresentation(
        title: 'Too Many Requests',
        description: _message(e, 'Please wait before trying again.'),
        actionLabel: 'Retry',
        action: ErrorAction.retry,
        illustration: Icons.hourglass_empty_rounded,
      );
    }
    if (status != null && status >= 500) {
      return ErrorPresentation(
        title: 'Server Error',
        description: _message(
          e,
          'Something went wrong on our servers. Please try again.',
        ),
        actionLabel: 'Retry',
        action: ErrorAction.retry,
        illustration: Icons.error_outline_rounded,
      );
    }
    return ErrorPresentation(
      title: 'Server Error',
      description: _message(e, 'Something went wrong. Please try again.'),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.error_outline_rounded,
    );
  }

  ErrorPresentation _notFoundPresentation(AppException e) {
    return ErrorPresentation(
      title: 'Not Found',
      description: _message(e, 'The requested resource could not be found.'),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.search_off_rounded,
    );
  }

  ErrorPresentation _validationPresentation(AppException e) {
    return ErrorPresentation(
      title: 'Validation Error',
      description: _message(e, 'Please check your input and try again.'),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.error_outline_rounded,
    );
  }

  ErrorPresentation _cachePresentation(AppException e) {
    return ErrorPresentation(
      title: 'Something Went Wrong',
      description: _message(e, 'Please try again.'),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.error_outline_rounded,
    );
  }

  ErrorPresentation _aiUnavailablePresentation(AppException e) {
    return ErrorPresentation(
      title: 'Service Unavailable',
      description: _message(
        e,
        'The AI service is temporarily unavailable.',
      ),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.cloud_off_rounded,
    );
  }

  ErrorPresentation _unknownPresentation(AppException e) {
    return ErrorPresentation(
      title: 'Something Went Wrong',
      description: _message(e, 'Please try again later.'),
      actionLabel: 'Retry',
      action: ErrorAction.retry,
      illustration: Icons.error_outline_rounded,
    );
  }

  String _productionMessage(AppException exception) {
    return switch (exception) {
      NetworkException _ =>
        'Unable to connect. Check your internet connection.',
      TimeoutException _ =>
        'The request is taking longer than expected. Please try again.',
      RateLimitException _ =>
        'Too many requests. Please wait a moment and try again.',
      AuthenticationException _ =>
        'Authentication failed. Please sign in again.',
      AIProviderUnavailableException _ =>
        'The AI service is temporarily unavailable.',
      NotFoundException _ => 'The requested resource was not found.',
      ValidationException _ =>
        exception.message.isNotEmpty
            ? exception.message
            : 'Invalid input. Please check your data.',
      ServerException _ =>
        exception.message.isNotEmpty
            ? exception.message
            : 'A server error occurred. Please try again later.',
      CacheException _ => 'Something went wrong. Please try again.',
      UnknownException _ => 'Something went wrong. Please try again later.',
      _ => 'Something went wrong. Please try again later.',
    };
  }
}
