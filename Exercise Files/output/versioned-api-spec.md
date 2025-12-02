# BookHub Publisher API Documentation

## Overview

BookHub's Publisher API enables programmatic management of book inventory on the BookHub marketplace. This documentation outlines the complete API specifications with versioning support.

## API Versioning Strategy

BookHub API uses date-based versioning through custom headers, allowing for cleaner URLs while maintaining strict version control.

### Version Header

All requests must include the `api-version` header:
```http
api-version: 2024-12-25
```

### Available Versions

- `2024-12-25`: Initial stable release with core functionality
- `2025-02-02-preview`: Beta features including bulk upload capabilities
- `2025-03-15`: Latest stable release with enhanced features

### Version-Specific Features

#### 2024-12-25 (Initial Release)
- Basic book management operations
- Single book operations
- Standard pricing model
- Core validation rules

#### 2025-02-02-preview
- Bulk upload capabilities (beta)
- Enhanced validation rules
- Improved error reporting
- Additional metadata support

#### 2025-03-15
- Stable bulk upload feature
- Advanced pricing options
- Extended metadata support
- Improved response structures

## Base URL
```
https://api.bookhub.com/api
```

## Authentication

All endpoints require JWT authentication. Include the token in the Authorization header:
```http
Authorization: Bearer <jwt_token>
```

## Common Headers

### Required Headers
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
api-version: <version-date>
```

### Optional Headers
```http
Idempotency-Key: <unique_request_id>
X-Request-ID: <request_tracking_id>
X-Publisher-ID: <publisher_uuid>
```

## Book Schema

The book schema varies by API version. Here are the version-specific schemas:

### Version 2024-12-25 (Base Schema)

```json
{
    "title": {
        "type": "string",
        "required": true,
        "max_length": 255
    },
    "author": {
        "type": "string",
        "required": true,
        "max_length": 255
    },
    "description": {
        "type": "string",
        "required": true,
        "max_length": 5000
    },
    "language": {
        "type": "string",
        "required": true,
        "pattern": "^[a-z]{2}(-[A-Z]{2})?$"
    },
    "publisher": {
        "type": "string",
        "required": true,
        "max_length": 255
    },
    "publishedDate": {
        "type": "string",
        "required": true,
        "format": "date"
    },
    "isbn": {
        "type": "string",
        "required": true,
        "pattern": "^(?:ISBN(?:-1[03])?:? )?(?=[0-9X]{10}$|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}$|97[89][0-9]{10}$|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$"
    },
    "price": {
        "type": "number",
        "required": true,
        "minimum": 0.01
    },
    "status": {
        "type": "string",
        "enum": ["PENDING", "ACTIVE", "INACTIVE"],
        "default": "PENDING"
    },
    "coverImages": {
        "type": "array",
        "items": {
            "type": "string",
            "format": "uri"
        },
        "minItems": 1,
        "maxItems": 5
    },
    "genres": {
        "type": "array",
        "items": {
            "type": "string"
        },
        "minItems": 1,
        "maxItems": 5
    },
    "bookFormat": {
        "type": "string",
        "enum": ["Paperback", "Hardcover", "eBook"]
    }
}
```

### Version 2025-02-02-preview (Additional Fields)

Includes all fields from 2024-12-25 plus:

```json
{
    "additional_metadata": {
        "type": "object",
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
        "format": "uuid"
    }
}
```

### Version 2025-03-15 (Enhanced Pricing)

Includes all fields from 2025-02-02-preview plus:

```json
{
    "pricing": {
        "type": "object",
        "required": true,
        "properties": {
            "base_price": {
                "type": "number",
                "required": true,
                "minimum": 0.01
            },
            "currency": {
                "type": "string",
                "enum": ["USD", "EUR", "GBP"]
            },
            "promotional_price": {
                "type": "number",
                "minimum": 0.01
            },
            "promotional_end_date": {
                "type": "string",
                "format": "date-time"
            }
        }
    }
}
```

## API Endpoints

### 1. Create Book (POST /books)

#### Version-Specific Behaviors

2024-12-25:
- Basic book creation
- Single book validation
- Simple pricing structure

2025-02-02-preview:
- Bulk upload support
- Enhanced metadata validation
- Preview of advanced pricing features

2025-03-15:
- Full bulk upload support
- Complete pricing management
- Advanced metadata handling

#### Success Response Examples

2024-12-25:
```json
{
    "status": "success",
    "message": "Book created successfully",
    "data": {
        "bookId": "b12345678",
        "title": "The Great Adventure",
        "status": "PENDING",
        "createdDate": "2024-01-30T14:30:00Z"
    }
}
```

2025-02-02-preview:
```json
{
    "status": "success",
    "message": "Book created successfully",
    "data": {
        "bookId": "b12345678",
        "title": "The Great Adventure",
        "status": "PENDING",
        "createdDate": "2024-01-30T14:30:00Z",
        "bulk_upload_info": {
            "batch_id": "550e8400-e29b-41d4-a716-446655440000",
            "batch_status": "processing",
            "batch_progress": {
                "total": 100,
                "processed": 45,
                "failed": 2
            }
        },
        "additional_metadata": {
            "edition_number": 2,
            "series_name": "Adventure Chronicles",
            "series_position": 1
        }
    }
}
```

2025-03-15:
```json
{
    "status": "success",
    "message": "Book created successfully",
    "data": {
        "bookId": "b12345678",
        "title": "The Great Adventure",
        "status": "PENDING",
        "createdDate": "2024-01-30T14:30:00Z",
        "pricing": {
            "base_price": 29.99,
            "currency": "USD",
            "promotional_price": 24.99,
            "promotional_end_date": "2024-03-01T23:59:59Z"
        }
    }
}
```

## Error Handling

Error responses are version-specific and include increasingly detailed information:

### Version 2024-12-25
```json
{
    "status": "error",
    "message": "Validation error",
    "errors": [{
        "field": "isbn",
        "error": "Invalid ISBN format"
    }]
}
```

### Version 2025-02-02-preview
```json
{
    "status": "error",
    "message": "Validation error",
    "errors": [{
        "field": "isbn",
        "error": "Invalid ISBN format",
        "validation_context": {
            "rule": "isbn_format",
            "provided_value": "123-456-789",
            "expected_format": "ISBN-13"
        }
    }],
    "bulk_upload_errors": {
        "batch_id": "550e8400-e29b-41d4-a716-446655440000",
        "failed_items": [{
            "index": 5,
            "errors": ["Invalid ISBN format"]
        }]
    }
}
```

### Version 2025-03-15
```json
{
    "status": "error",
    "message": "Validation error",
    "errors": [{
        "field": "pricing",
        "error": "Invalid pricing configuration",
        "validation_context": {
            "rule": "promotional_price",
            "constraint": "must_be_less_than_base_price",
            "provided_value": {
                "base_price": 29.99,
                "promotional_price": 34.99
            }
        }
    }]
}
```

## Version Migration Guide

### Migrating from 2024-12-25 to 2025-03-15

1. Update the `api-version` header
2. Restructure price field to use new pricing object
3. Add additional metadata if applicable
4. Update error handling to accommodate new response formats
5. Test with preview version before production switch

### Breaking Changes

2024-12-25 to 2025-02-02-preview:
- New required metadata fields
- Enhanced validation rules
- Modified error response structure

2025-02-02-preview to 2025-03-15:
- New pricing structure
- Required currency specification
- Additional response fields

## Version Lifecycle

- New versions announced 60 days before release
- Preview versions available for 30+ days
- Old versions supported for 12 months after new release
- Security patches applied to all supported versions
- Deprecation notices sent 6 months before sunset

## Rate Limiting

Version-specific rate limits:
- 2024-12-25: 100 requests/minute
- 2025-02-02-preview: 200 requests/minute
- 2025-03-15: 150 requests/minute

Rate limit headers:
```http
X-RateLimit-Limit: <limit>
X-RateLimit-Remaining: <remaining>
X-RateLimit-Reset: <timestamp>
```

## Support

For version-specific support:
- Email: api-support@bookhub.com
- Documentation: https://docs.bookhub.com
- Version Status: https://docs.bookhub.com/versions
