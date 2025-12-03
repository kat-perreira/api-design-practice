# BookHub Publisher API Documentation

## Overview

BookHub is an online marketplace connecting book publishers with readers worldwide. This document outlines the comprehensive API specifications for publishers to manage their book inventory programmatically.

## Base URL
```
https://api.bookhub.com/v1
```

## Authentication

All API endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Common Headers

### Required Headers
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
X-Publisher-ID: <publisher_uuid>
```

### Optional Headers
```http
X-Request-ID: <request_uuid>
X-Idempotency-Key: <idempotency_key>
X-API-Version: v1.2
```

## Book Schema

### Core Fields
- **title** (string, required): Book title, max 255 characters
- **author** (string, required): Author name, max 255 characters
- **description** (string, required): Book description, max 5000 characters
- **language** (string, required): ISO 639-1 format (e.g., 'en' or 'en-US')
- **publisher** (string, required): Publisher name, max 255 characters
- **publishedDate** (string, required): ISO 8601 format (YYYY-MM-DD)
- **isbn** (string, required): Valid ISBN-10 or ISBN-13
- **price** (number, required): Price in USD, must be positive
- **status** (string): PENDING, ACTIVE, or INACTIVE
- **coverImages** (array): URLs of cover images, 1-5 items
- **genres** (array): Genre categories, 1-5 items
- **bookFormat** (string): "Paperback", "Hardcover", or "eBook"

### System Fields
- **createdDate** (string): ISO 8601 timestamp
- **updatedDate** (string): ISO 8601 timestamp
- **inactiveDate** (string): ISO 8601 timestamp
- **ratingsByStars** (object): Rating distribution
- **numberOfReviews** (number): Total review count

## API Endpoints

### 1. Create Book
Creates a new book in PENDING status.

**Endpoint:** `POST /books`

#### Request Body Example
```json
{
    "title": "The Great Adventure",
    "author": "Jane Smith",
    "description": "An epic tale of discovery...",
    "language": "en-US",
    "publisher": "BookWorld Publishing",
    "publishedDate": "2024-01-15",
    "isbn": "978-0-123456-47-2",
    "price": 29.99,
    "coverImages": [
        "https://bookhub.com/covers/great-adventure-front.jpg"
    ],
    "genres": ["Adventure", "Fiction"],
    "bookFormat": "Hardcover"
}
```

#### Success Response (201 Created)
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

### 2. Get All Books
Retrieves all books for the authenticated publisher.

**Endpoint:** `GET /books`

#### Query Parameters
- page (integer): Page number, default 1
- limit (integer): Items per page, default 20, max 100
- status (string): Filter by status
- sort (string): Sort field
- order (string): Sort direction (asc/desc)

#### Success Response (200 OK)
```json
{
    "status": "success",
    "data": {
        "books": [...],
        "pagination": {
            "currentPage": 1,
            "totalPages": 5,
            "totalItems": 98,
            "itemsPerPage": 20
        }
    }
}
```

### 3. Finalize Book
Changes a book's status from PENDING to ACTIVE.

**Endpoint:** `PATCH /books/{bookId}/finalize`

#### Success Response (200 OK)
```json
{
    "status": "success",
    "data": {
        "bookId": "b12345678",
        "title": "The Great Adventure",
        "status": "ACTIVE",
        "updatedDate": "2024-01-30T14:30:00Z"
    },
    "message": "Book successfully finalized"
}
```

## Caching Strategy

### Cache Headers
```http
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 15 Jan 2024 15:30:00 GMT
Cache-Control: private, max-age=3600
Vary: Accept, Authorization
```

### Conditional Requests
Use If-None-Match and If-Modified-Since headers for efficient caching:
```http
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
If-Modified-Since: Wed, 15 Jan 2024 15:30:00 GMT
```

## Rate Limiting

### Limits
- Create/Update: 100 requests per hour
- Read operations: 1000 requests per hour
- Finalize: 100 requests per minute

### Rate Limit Headers
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1643553600
```

## Error Handling

### Common Error Responses

#### 400 Bad Request
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
            }
        ]
    }
}
```

#### 401 Unauthorized
```json
{
    "success": false,
    "error": {
        "code": "UNAUTHORIZED",
        "message": "Invalid or expired authentication token"
    }
}
```

#### 403 Forbidden
```json
{
    "success": false,
    "error": {
        "code": "FORBIDDEN",
        "message": "Insufficient permissions to access this resource"
    }
}
```

## Best Practices

1. **Idempotency**
   - Use X-Idempotency-Key for write operations
   - Keys expire after 24 hours
   - Ensures safe retries of failed requests

2. **Request Tracking**
   - Include X-Request-ID in all requests
   - Helps with debugging and support
   - Preserved across the request lifecycle

3. **API Versioning**
   - URL path versioning (/v1/books)
   - Header versioning (X-API-Version)
   - Both methods supported

4. **Security**
   - All requests must use HTTPS
   - JWT tokens must be valid and not expired
   - Publishers can only access their own books

5. **Caching**
   - Implement ETags for efficient caching
   - Honor Cache-Control directives
   - Use conditional requests when possible

## Implementation Notes

1. All timestamps use ISO 8601 format in UTC
2. ISBNs support both ISBN-10 and ISBN-13 formats
3. Book status transitions: PENDING → ACTIVE → INACTIVE
4. Cover image URLs must be valid and accessible
5. Genre lists are case-sensitive
6. Price values must include exactly 2 decimal places
7. All text fields have maximum length restrictions

## Support

For API support or questions, contact:
- Email: api-support@bookhub.com
- Developer Portal: https://developers.bookhub.com
