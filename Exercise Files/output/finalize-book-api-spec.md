# Book Finalization API Specification

## Overview
This API endpoint allows publishers to finalize a book, changing its status from PENDING to ACTIVE. Once a book is finalized, it becomes available for users to search and order through the BookHub platform.

## Endpoint Details

### HTTP Method and Path
```
PATCH /api/v1/books/{bookId}/finalize
```

### Path Parameters
| Parameter | Type   | Required | Description                                     |
|-----------|--------|----------|-------------------------------------------------|
| bookId    | string | Yes      | The unique identifier of the book to finalize   |

### Request Headers
| Header Name      | Required | Description                                        |
|-----------------|----------|----------------------------------------------------|
| Authorization   | Yes      | Bearer token for authentication (JWT)              |
| Content-Type    | Yes      | application/json                                   |

### Request Body
No request body is required for this endpoint.

### Success Response

#### Status Code
`200 OK`

#### Response Body
```json
{
    "status": "success",
    "data": {
        "bookId": "string",
        "title": "string",
        "status": "ACTIVE",
        "updatedDate": "string (ISO 8601 format)"
    },
    "message": "Book successfully finalized"
}
```

### Error Responses

#### 400 Bad Request
Returned when the book is not in PENDING status.
```json
{
    "status": "error",
    "code": "INVALID_BOOK_STATUS",
    "message": "Only books in PENDING status can be finalized",
    "details": {
        "currentStatus": "string"
    }
}
```

#### 404 Not Found
Returned when the specified book does not exist.
```json
{
    "status": "error",
    "code": "BOOK_NOT_FOUND",
    "message": "Book not found",
    "details": {
        "bookId": "string"
    }
}
```

#### 401 Unauthorized
Returned when the JWT token is missing or invalid.
```json
{
    "status": "error",
    "code": "UNAUTHORIZED",
    "message": "Invalid or missing authentication token"
}
```

#### 403 Forbidden
Returned when the publisher does not have permission to finalize this book.
```json
{
    "status": "error",
    "code": "FORBIDDEN",
    "message": "You do not have permission to finalize this book"
}
```

### Required Book Fields
Before a book can be finalized, the following fields must be present and valid:
- Title
- Author
- Description
- Language
- Publisher
- Published Date
- ISBN
- Price
- Cover Images (at least one)
- Genres (at least one)
- Book format

If any required field is missing or invalid, the finalization request will fail with a 400 Bad Request response.

### Business Rules
1. Only books in PENDING status can be finalized
2. All required fields must be present and valid
3. Only the publisher who created the book can finalize it
4. The updatedDate field will be automatically set to the current timestamp
5. Once a book is finalized (ACTIVE), it becomes visible to users in search results

### Rate Limiting
- Rate limit: 100 requests per minute per publisher
- Rate limit headers will be included in the response:
  - X-RateLimit-Limit
  - X-RateLimit-Remaining
  - X-RateLimit-Reset

### Security Considerations
1. The endpoint requires JWT authentication
2. The JWT token must contain the publisher's ID and appropriate permissions
3. The system validates that the publisher owns the book before allowing finalization
4. All requests must be made over HTTPS

### Example Usage

#### cURL Request
```bash
curl -X PATCH \
  'https://api.bookhub.com/api/v1/books/123e4567-e89b-12d3-a456-426614174000/finalize' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'Content-Type: application/json'
```

#### Success Response Example
```json
{
    "status": "success",
    "data": {
        "bookId": "123e4567-e89b-12d3-a456-426614174000",
        "title": "The Great Adventure",
        "status": "ACTIVE",
        "updatedDate": "2025-01-30T14:30:00Z"
    },
    "message": "Book successfully finalized"
}
```

### Changelog
- 2025-01-30: Initial version of the API specification
