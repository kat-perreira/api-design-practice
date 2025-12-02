# BookHub API Documentation: Book Creation Endpoint

## Introduction

This document provides comprehensive documentation for the Book Creation API endpoint of the BookHub platform. This endpoint enables publishers to programmatically add new books to the BookHub marketplace. The API follows RESTful principles, uses JSON for data exchange, and implements date-based versioning through custom headers.

## Base URL

```
https://api.bookhub.com/api
```

Note: The version is no longer included in the URL path, as it's now handled through headers.

## API Versioning

The API uses date-based versioning through custom headers. This allows for cleaner URLs while maintaining strict version control.

### Version Header

All requests must include the `api-version` header:

```http
api-version: 2024-12-25
```

### Available Versions

- `2024-12-25`: Initial stable release
- `2025-02-02-preview`: Beta features including bulk upload
- `2025-03-15`: Latest stable release with bulk upload support

### Version-Specific Features

#### 2024-12-25 (Initial Release)
- Basic book creation
- Single book operations
- Standard pricing model

#### 2025-02-02-preview
- Bulk upload capabilities (beta)
- Enhanced validation rules
- Improved error reporting

#### 2025-03-15
- Stable bulk upload feature
- Advanced pricing options
- Extended metadata support

## Endpoint Details

**Method**: POST  
**Path**: `/books`  
**Full URL**: `https://api.bookhub.com/api/books`

## Security

All API requests must be made over HTTPS. Requests over plain HTTP will be rejected. The API uses JWT (JSON Web Tokens) for authentication, with tokens that must be included in the Authorization header of each request.

## Headers

### Required Headers

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
api-version: 2024-12-25
```

Each required header serves a specific purpose in ensuring secure and reliable API communication:

1. **Authorization**
   - Format: `Bearer <jwt_token>`
   - Description: Authenticates the publisher making the request
   - Validation Rules:
     - Must start with "Bearer " followed by a valid JWT token
     - Token must not be expired
     - Token must contain publisher scope
   - Example: `Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

2. **Content-Type**
   - Required Value: `application/json`
   - Description: Specifies the format of the request payload
   - Validation Rules:
     - Case-insensitive match
     - No additional parameters allowed

3. **Accept**
   - Required Value: `application/json`
   - Description: Indicates the expected response format
   - Validation Rules:
     - Case-insensitive match
     - No additional parameters allowed

4. **api-version**
   - Required Value: Valid date-based version (e.g., "2024-12-25")
   - Description: Specifies the API version to use
   - Validation Rules:
     - Must be a valid version date
     - Preview versions must include "-preview" suffix
   - Examples:
     - Production: `api-version: 2024-12-25`
     - Preview: `api-version: 2025-02-02-preview`

### Optional Headers

```http
Idempotency-Key: <unique_request_id>
X-Request-ID: <request_tracking_id>
If-Match: <etag>
X-Publisher-ID: <publisher_identifier>
```

[Previous optional headers section remains unchanged]

## Request Body

The request body structure varies by API version. Below are the version-specific schemas:

### Version 2024-12-25

```json
{
  "title": {
    "type": "string",
    "required": true,
    "max_length": 255
  },
  // [Previous schema fields remain unchanged]
}
```

### Version 2025-02-02-preview

```json
{
  "title": {
    "type": "string",
    "required": true,
    "max_length": 255
  },
  // [Previous fields remain unchanged]
  "additional_metadata": {
    "type": "object",
    "required": false,
    "properties": {
      "edition_number": {
        "type": "integer",
        "minimum": 1
      },
      "series_name": {
        "type": "string",
        "max_length": 255
      },
      "series_position": {
        "type": "integer",
        "minimum": 1
      }
    }
  },
  "bulk_upload_id": {
    "type": "string",
    "format": "uuid",
    "description": "Reference to a bulk upload batch (Preview feature)"
  }
}
```

### Version 2025-03-15

```json
{
  // [Previous fields from 2025-02-02-preview remain]
  "pricing": {
    "type": "object",
    "required": true,
    "properties": {
      "base_price": {
        "type": "number",
        "required": true,
        "min": 0.01
      },
      "currency": {
        "type": "string",
        "enum": ["USD", "EUR", "GBP"]
      },
      "promotional_price": {
        "type": "number",
        "required": false,
        "min": 0.01
      },
      "promotional_end_date": {
        "type": "string",
        "format": "date-time",
        "required": false
      }
    }
  }
}
```

## Success Response

The response structure also varies by version:

### Version 2024-12-25

[Previous success response structure remains unchanged]

### Version 2025-02-02-preview

Adds the following fields to the response:

```json
{
  "status": "success",
  "message": "Book created successfully",
  "data": {
    // [Previous fields remain]
    "bulk_upload_info": {
      "batch_id": "string (UUID)",
      "batch_status": "string",
      "batch_progress": {
        "total": "number",
        "processed": "number",
        "failed": "number"
      }
    },
    "additional_metadata": {
      "edition_number": "number",
      "series_name": "string",
      "series_position": "number"
    }
  }
}
```

### Version 2025-03-15

Adds the following fields to the preview version response:

```json
{
  "status": "success",
  "message": "Book created successfully",
  "data": {
    // [Previous fields remain]
    "pricing": {
      "base_price": "number",
      "currency": "string",
      "promotional_price": "number",
      "promotional_end_date": "string (ISO 8601)",
      "price_history": [{
        "price": "number",
        "currency": "string",
        "effective_date": "string (ISO 8601)"
      }]
    }
  }
}
```

## Error Responses

Error responses include version-specific fields:

### Version 2024-12-25

[Previous error response structure remains unchanged]

### Version 2025-02-02-preview

Adds detailed validation context:

```json
{
  "status": "error",
  "message": "Validation error",
  "errors": [{
    "field": "string",
    "error": "string",
    "description": "string",
    "validation_context": {
      "rule": "string",
      "constraint": "any",
      "provided_value": "any"
    }
  }],
  "bulk_upload_errors": {
    "batch_id": "string (UUID)",
    "failed_items": [{
      "index": "number",
      "errors": ["string"]
    }]
  }
}
```

### Version 2025-03-15

Adds pricing-specific errors:

```json
{
  "status": "error",
  "message": "Validation error",
  "errors": [{
    // [Previous fields remain]
    "pricing_errors": [{
      "currency": "string",
      "error": "string",
      "allowed_currencies": ["string"]
    }]
  }]
}
```

## Version Migration Guide

### Migrating from 2024-12-25 to 2025-03-15

1. Update the `api-version` header to "2025-03-15"
2. Modify the price field structure to use the new pricing object
3. Add any additional metadata if applicable
4. Test with the preview version before switching to production

### Testing Multiple Versions

You can test different versions of the API simultaneously:

```javascript
// Production version
await fetch('/api/books', {
  headers: {
    'api-version': '2024-12-25'
  }
});

// Preview features
await fetch('/api/books', {
  headers: {
    'api-version': '2025-02-02-preview'
  }
});
```

## Version Lifecycle

- New versions are announced 60 days before release
- Preview versions are available for at least 30 days
- Old versions are supported for 12 months after a new version is released
- Emergency security patches may be applied to all supported versions
- Deprecation notices are sent 6 months before version sunset

## Rate Limiting

Rate limits vary by version:

- 2024-12-25: 100 requests per minute
- 2025-02-02-preview: 200 requests per minute (beta)
- 2025-03-15: 150 requests per minute

Rate limit headers included in all responses:
```http
X-RateLimit-Limit: <limit>
X-RateLimit-Remaining: <remaining>
X-RateLimit-Reset: <timestamp>
```

## Support

For technical support or questions about specific API versions:
- Email: api-support@bookhub.com
- API Documentation: https://docs.bookhub.com
- Status Page: https://status.bookhub.com
- Version Status: https://docs.bookhub.com/versions