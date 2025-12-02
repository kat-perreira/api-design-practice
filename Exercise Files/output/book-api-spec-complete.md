# BookHub API Specification - Create Book Endpoint

## Overview
This document outlines the API specification for creating a new book in the BookHub platform. Publishers can use this endpoint to upload book information to the marketplace.

## Endpoint Details

**URL**: `/api/v1/books`  
**Method**: `POST`  
**Authentication**: Required (JWT Token)

## Request Model

### Headers

#### Required Headers
```json
{
    "Authorization": {
        "description": "JWT Bearer token for authentication",
        "format": "Bearer <jwt_token>",
        "required": true,
        "example": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    },
    "Content-Type": {
        "description": "Media type of the request body",
        "value": "application/json",
        "required": true
    },
    "Accept": {
        "description": "Media type(s) that is/are acceptable for the response",
        "value": "application/json",
        "required": true
    },
    "X-Publisher-ID": {
        "description": "Unique identifier for the publisher",
        "format": "uuid",
        "required": true,
        "example": "123e4567-e89b-12d3-a456-426614174000"
    }
}
```

#### Optional Headers
```json
{
    "X-Request-ID": {
        "description": "Unique identifier for the request for tracking purposes",
        "format": "uuid",
        "required": false,
        "example": "550e8400-e29b-41d4-a716-446655440000"
    },
    "X-Idempotency-Key": {
        "description": "Unique key to ensure idempotency of the request",
        "format": "string",
        "required": false,
        "example": "2024-01-30-create-great-adventure-book"
    },
    "X-API-Version": {
        "description": "Specific API version to use (defaults to latest if not specified)",
        "format": "string",
        "required": false,
        "example": "v1.2"
    }
}
```

#### Example Headers
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
Accept: application/json
X-Publisher-ID: 123e4567-e89b-12d3-a456-426614174000
X-Request-ID: 550e8400-e29b-41d4-a716-446655440000
X-Idempotency-Key: 2024-01-30-create-great-adventure-book
X-API-Version: v1.2
```

### Request Body Schema
```json
{
    "title": {
        "type": "string",
        "required": true,
        "minLength": 1,
        "maxLength": 255,
        "description": "The title of the book"
    },
    "author": {
        "type": "string",
        "required": true,
        "minLength": 1,
        "maxLength": 255,
        "description": "The author of the book"
    },
    "description": {
        "type": "string",
        "required": true,
        "maxLength": 5000,
        "description": "Detailed description of the book"
    },
    "language": {
        "type": "string",
        "required": true,
        "pattern": "^[a-zA-Z]{2}(-[a-zA-Z]{2})?$",
        "description": "Language code (ISO 639-1 format, e.g., 'en' or 'en-US')"
    },
    "publisher": {
        "type": "string",
        "required": true,
        "minLength": 1,
        "maxLength": 255,
        "description": "Name of the publisher"
    },
    "publishedDate": {
        "type": "string",
        "required": true,
        "format": "date",
        "description": "Publication date in ISO 8601 format (YYYY-MM-DD)"
    },
    "isbn": {
        "type": "string",
        "required": true,
        "pattern": "^(?:ISBN(?:-1[03])?:? )?(?=[0-9X]{10}$|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}$|97[89][0-9]{10}$|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$",
        "description": "Valid ISBN-10 or ISBN-13 number"
    },
    "price": {
        "type": "number",
        "required": true,
        "minimum": 0,
        "description": "Price of the book in USD"
    },
    "coverImages": {
        "type": "array",
        "required": true,
        "minItems": 1,
        "maxItems": 5,
        "items": {
            "type": "string",
            "format": "uri",
            "description": "URL of the book cover image"
        },
        "description": "Array of cover image URLs"
    },
    "genres": {
        "type": "array",
        "required": true,
        "minItems": 1,
        "maxItems": 5,
        "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 50
        },
        "description": "Array of genre categories"
    },
    "bookFormat": {
        "type": "string",
        "required": true,
        "enum": ["Paperback", "Hardcover", "eBook"],
        "description": "Format of the book"
    }
}
```

### Example Request
```json
{
    "title": "The Great Adventure",
    "author": "Jane Smith",
    "description": "An epic tale of discovery and courage...",
    "language": "en-US",
    "publisher": "BookWorld Publishing",
    "publishedDate": "2024-01-15",
    "isbn": "978-0-123456-47-2",
    "price": 29.99,
    "coverImages": [
        "https://bookhub.com/covers/great-adventure-front.jpg",
        "https://bookhub.com/covers/great-adventure-back.jpg"
    ],
    "genres": ["Adventure", "Fiction", "Young Adult"],
    "bookFormat": "Hardcover"
}
```

## Success Response

### Status Code
`201 Created`

### Response Headers
```json
{
    "Location": "/api/v1/books/{bookId}",
    "Content-Type": "application/json"
}
```

### Response Body Schema
```json
{
    "success": {
        "type": "boolean",
        "value": true
    },
    "message": {
        "type": "string",
        "description": "Success message"
    },
    "data": {
        "type": "object",
        "properties": {
            "bookId": {
                "type": "string",
                "description": "Unique identifier for the created book"
            },
            "title": {
                "type": "string"
            },
            "status": {
                "type": "string",
                "enum": ["PENDING"]
            },
            "createdDate": {
                "type": "string",
                "format": "date-time"
            }
        }
    }
}
```

### Example Success Response
```json
{
    "success": true,
    "message": "Book created successfully",
    "data": {
        "bookId": "b12345678",
        "title": "The Great Adventure",
        "status": "PENDING",
        "createdDate": "2024-01-30T14:30:00Z"
    }
}
```

## Error Responses

### Validation Error
**Status Code**: `400 Bad Request`

```json
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid request parameters",
        "details": [
            {
                "field": "isbn",
                "message": "Invalid ISBN format"
            },
            {
                "field": "price",
                "message": "Price must be greater than 0"
            }
        ]
    }
}
```

### Authentication Error
**Status Code**: `401 Unauthorized`

```json
{
    "success": false,
    "error": {
        "code": "UNAUTHORIZED",
        "message": "Invalid or missing authentication token"
    }
}
```

### Server Error
**Status Code**: `500 Internal Server Error`

```json
{
    "success": false,
    "error": {
        "code": "INTERNAL_SERVER_ERROR",
        "message": "An unexpected error occurred while processing your request"
    }
}
```

## Request Processing

### Idempotency
The API supports idempotent requests through the `X-Idempotency-Key` header. When provided:
- Multiple identical requests with the same idempotency key will only create one book
- Subsequent requests within a 24-hour window will return the same response as the first request
- After 24 hours, the idempotency key expires and can be reused

### Request Tracking
The `X-Request-ID` header enables end-to-end request tracking:
- If provided, it will be included in all logging and error reporting
- The same ID will be returned in the response headers
- Useful for debugging and support inquiries

### Versioning
API versioning is supported through two mechanisms:
1. URL path versioning (e.g., `/api/v1/books`)
2. The `X-API-Version` header for fine-grained version control

## Notes

1. The book status is automatically set to "PENDING" upon creation
2. All text fields have appropriate length limitations to prevent abuse
3. ISBN format supports both ISBN-10 and ISBN-13 formats
4. Cover images must be valid URLs and are limited to 5 images
5. Genres are limited to 5 categories per book
6. The price must be a positive number
7. The response includes the Location header for retrieving the created book

## Rate Limiting
- Rate limit: 100 requests per hour per publisher
- Rate limit headers are included in the response:
  - X-RateLimit-Limit
  - X-RateLimit-Remaining
  - X-RateLimit-Reset
