# Create Book Error Response Model

## Overview

This document defines all possible error responses for the Create Book API endpoint (`POST /api/v1/books`). Error responses follow a consistent structure across all failure scenarios.

## Error Response Schema

### JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CreateBookErrorResponse",
  "type": "object",
  "required": ["status", "code", "message"],
  "properties": {
    "status": {
      "type": "string",
      "const": "error",
      "description": "Indicates the request failed"
    },
    "code": {
      "type": "string",
      "description": "Machine-readable error code"
    },
    "message": {
      "type": "string",
      "description": "Human-readable error message"
    },
    "details": {
      "type": "object",
      "description": "Additional context about the error"
    },
    "errors": {
      "type": "array",
      "description": "List of validation errors (for 400 responses)",
      "items": {
        "type": "object",
        "properties": {
          "field": {
            "type": "string",
            "description": "The field that failed validation"
          },
          "message": {
            "type": "string",
            "description": "Description of the validation failure"
          },
          "value": {
            "description": "The invalid value that was provided"
          }
        }
      }
    },
    "requestId": {
      "type": "string",
      "description": "Request ID for support reference"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "When the error occurred"
    }
  }
}
```

## Error Responses by Status Code

---

## 400 Bad Request

Returned when the request body is invalid or fails validation.

### Validation Error

**When:** Required fields are missing or field values are invalid.

```json
{
  "status": "error",
  "code": "VALIDATION_ERROR",
  "message": "Request validation failed",
  "errors": [
    {
      "field": "title",
      "message": "Title is required",
      "value": null
    },
    {
      "field": "price",
      "message": "Price must be a non-negative number",
      "value": -5.99
    }
  ],
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

### Invalid ISBN Format

**When:** The ISBN doesn't match ISBN-10 or ISBN-13 format.

```json
{
  "status": "error",
  "code": "INVALID_ISBN_FORMAT",
  "message": "Invalid ISBN format",
  "details": {
    "providedValue": "123-456-789",
    "expectedFormat": "ISBN-10 or ISBN-13 (e.g., 978-3-16-148410-0)"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

### Invalid Language Code

**When:** The language code doesn't match ISO 639-1 format.

```json
{
  "status": "error",
  "code": "INVALID_LANGUAGE_CODE",
  "message": "Invalid language code",
  "details": {
    "providedValue": "english",
    "expectedFormat": "ISO 639-1 code (e.g., 'en', 'es', 'fr-CA')"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

### Invalid Book Format

**When:** The book format isn't one of the allowed values.

```json
{
  "status": "error",
  "code": "INVALID_BOOK_FORMAT",
  "message": "Invalid book format",
  "details": {
    "providedValue": "PDF",
    "allowedValues": ["Paperback", "Hardcover", "eBook"]
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

### Invalid Cover Image URL

**When:** A cover image URL is malformed or from an unauthorized domain.

```json
{
  "status": "error",
  "code": "INVALID_COVER_IMAGE_URL",
  "message": "Invalid cover image URL",
  "details": {
    "providedValue": "http://malicious-site.com/image.jpg",
    "reason": "URL must use HTTPS and be from an allowed domain",
    "allowedDomains": ["cdn.bookhub.com", "images.bookhub.com"]
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

### Malformed JSON

**When:** The request body isn't valid JSON.

```json
{
  "status": "error",
  "code": "MALFORMED_JSON",
  "message": "Request body is not valid JSON",
  "details": {
    "parseError": "Unexpected token } at position 45"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

---

## 401 Unauthorized

Returned when authentication fails.

### Missing Token

**When:** The Authorization header is not provided.

```json
{
  "status": "error",
  "code": "MISSING_AUTH_TOKEN",
  "message": "Authorization header is required",
  "details": {
    "expectedHeader": "Authorization: Bearer <token>"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

### Invalid Token

**When:** The JWT token is malformed or has an invalid signature.

```json
{
  "status": "error",
  "code": "INVALID_AUTH_TOKEN",
  "message": "Invalid authentication token",
  "details": {
    "reason": "Token signature verification failed"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

### Expired Token

**When:** The JWT token has expired.

```json
{
  "status": "error",
  "code": "EXPIRED_AUTH_TOKEN",
  "message": "Authentication token has expired",
  "details": {
    "expiredAt": "2025-12-02T17:30:00Z",
    "currentTime": "2025-12-02T18:30:00Z"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

---

## 403 Forbidden

Returned when the authenticated user lacks permission.

### Insufficient Permissions

**When:** The publisher's JWT doesn't include `books:create` permission.

```json
{
  "status": "error",
  "code": "INSUFFICIENT_PERMISSIONS",
  "message": "You do not have permission to create books",
  "details": {
    "requiredPermission": "books:create",
    "yourPermissions": ["books:read"]
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

### Account Suspended

**When:** The publisher's account has been suspended.

```json
{
  "status": "error",
  "code": "ACCOUNT_SUSPENDED",
  "message": "Your publisher account has been suspended",
  "details": {
    "reason": "Terms of service violation",
    "contactEmail": "support@bookhub.com"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

---

## 409 Conflict

Returned when there's a conflict with existing data.

### Duplicate ISBN

**When:** A book with the same ISBN already exists.

```json
{
  "status": "error",
  "code": "DUPLICATE_ISBN",
  "message": "A book with this ISBN already exists",
  "details": {
    "isbn": "978-3-16-148410-0",
    "existingBookId": "507f1f77bcf86cd799439011"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

---

## 413 Payload Too Large

Returned when the request body exceeds size limits.

```json
{
  "status": "error",
  "code": "PAYLOAD_TOO_LARGE",
  "message": "Request body exceeds maximum size",
  "details": {
    "maxSizeBytes": 1048576,
    "receivedSizeBytes": 2097152
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

---

## 415 Unsupported Media Type

Returned when the Content-Type header is incorrect.

```json
{
  "status": "error",
  "code": "UNSUPPORTED_MEDIA_TYPE",
  "message": "Content-Type must be application/json",
  "details": {
    "providedContentType": "text/plain",
    "supportedContentTypes": ["application/json"]
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

---

## 429 Too Many Requests

Returned when rate limit is exceeded.

```json
{
  "status": "error",
  "code": "RATE_LIMIT_EXCEEDED",
  "message": "Too many requests. Please try again later.",
  "details": {
    "limit": 100,
    "windowSeconds": 60,
    "retryAfterSeconds": 45
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

**Additional Headers:**

```http
Retry-After: 45
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1733165505
```

---

## 500 Internal Server Error

Returned when an unexpected server error occurs.

```json
{
  "status": "error",
  "code": "INTERNAL_SERVER_ERROR",
  "message": "An unexpected error occurred. Please try again later.",
  "details": {
    "supportReference": "ERR-2025120218300012345"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

---

## 503 Service Unavailable

Returned when the service is temporarily unavailable.

```json
{
  "status": "error",
  "code": "SERVICE_UNAVAILABLE",
  "message": "Service temporarily unavailable. Please try again later.",
  "details": {
    "reason": "Database maintenance in progress",
    "estimatedRecoveryTime": "2025-12-02T19:00:00Z"
  },
  "requestId": "req_abc123xyz",
  "timestamp": "2025-12-02T18:30:00Z"
}
```

**Additional Headers:**

```http
Retry-After: 1800
```

---

## Error Code Reference

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | One or more fields failed validation |
| `INVALID_ISBN_FORMAT` | 400 | ISBN doesn't match expected format |
| `INVALID_LANGUAGE_CODE` | 400 | Language code isn't ISO 639-1 |
| `INVALID_BOOK_FORMAT` | 400 | Book format isn't an allowed value |
| `INVALID_COVER_IMAGE_URL` | 400 | Cover image URL is invalid |
| `MALFORMED_JSON` | 400 | Request body isn't valid JSON |
| `MISSING_AUTH_TOKEN` | 401 | Authorization header missing |
| `INVALID_AUTH_TOKEN` | 401 | JWT token is invalid |
| `EXPIRED_AUTH_TOKEN` | 401 | JWT token has expired |
| `INSUFFICIENT_PERMISSIONS` | 403 | Missing required permissions |
| `ACCOUNT_SUSPENDED` | 403 | Publisher account is suspended |
| `DUPLICATE_ISBN` | 409 | ISBN already exists |
| `PAYLOAD_TOO_LARGE` | 413 | Request body too large |
| `UNSUPPORTED_MEDIA_TYPE` | 415 | Wrong Content-Type header |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_SERVER_ERROR` | 500 | Unexpected server error |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily down |

## Error Handling Best Practices

### For API Consumers

1. **Always check the `status` field** first to determine success/failure
2. **Use the `code` field** for programmatic error handling
3. **Display the `message` field** to users when appropriate
4. **Log the `requestId`** for debugging and support requests
5. **Handle `429` errors** by respecting the `Retry-After` header
6. **Implement exponential backoff** for `500` and `503` errors

