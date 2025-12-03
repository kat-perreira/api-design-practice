# BookHub Publisher API Specification - Book Endpoints

## Overview

This document outlines the API specifications for retrieving books in the BookHub platform. These endpoints are specifically designed for publishers to manage their book inventory.

## Authentication

All API requests must include a valid JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Base URL

```
https://api.bookhub.com/v1
```

## Caching Strategy

The API implements a comprehensive caching strategy using both ETag and Last-Modified headers to optimize performance and reduce server load. Clients should implement conditional requests using these headers to minimize unnecessary data transfer.

### Cache Headers

The following cache-related headers are included in responses:

1. `ETag`: A unique identifier for the specific version of a resource
2. `Last-Modified`: Timestamp when the resource was last modified
3. `Cache-Control`: Directives for caching behavior
4. `Vary`: Headers that should be considered when caching responses

### Conditional Requests

Clients can make conditional requests using:

1. `If-None-Match`: Send the ETag value to check if content has changed
2. `If-Modified-Since`: Send the Last-Modified value to check for updates

If the content hasn't changed, the server will respond with a 304 Not Modified status.

## Endpoints

### Get All Books

Retrieves all books associated with the authenticated publisher.

**Endpoint:** `GET /books`

**Authentication Required:** Yes

**Query Parameters:**

| Parameter  | Type    | Required | Description                                      |
|------------|---------|----------|--------------------------------------------------|
| page       | integer | No       | Page number for pagination (default: 1)          |
| limit      | integer | No       | Number of books per page (default: 20, max: 100) |
| status     | string  | No       | Filter by status (PENDING, ACTIVE, INACTIVE)     |
| sort       | string  | No       | Sort field (e.g., publishedDate, title)          |
| order      | string  | No       | Sort order (asc, desc)                          |

**Response Headers:**

```
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 15 Jan 2024 15:30:00 GMT
Cache-Control: private, max-age=3600
Vary: Accept, Authorization
```

**Success Response (200 OK)**

```json
{
    "status": "success",
    "data": {
        "books": [
            {
                "id": "book123",
                "title": "The Great Adventure",
                "author": "Jane Smith",
                "description": "An epic journey through time...",
                "language": "English",
                "publisher": "Adventure Books Inc",
                "publishedDate": "2024-01-15",
                "isbn": "978-3-16-148410-0",
                "price": 29.99,
                "status": "ACTIVE",
                "createdDate": "2024-01-01T10:00:00Z",
                "updatedDate": "2024-01-15T15:30:00Z",
                "inactiveDate": null,
                "coverImages": [
                    "https://bookhub.com/images/book123-cover1.jpg",
                    "https://bookhub.com/images/book123-cover2.jpg"
                ],
                "genres": ["Adventure", "Fantasy"],
                "bookFormat": "Hardcover",
                "ratingsByStars": {
                    "1": 10,
                    "2": 20,
                    "3": 30,
                    "4": 40,
                    "5": 50
                },
                "numberOfReviews": 150
            }
        ],
        "pagination": {
            "currentPage": 1,
            "totalPages": 5,
            "totalItems": 98,
            "itemsPerPage": 20
        }
    }
}
```

**Not Modified Response (304)**

Returned when the resource hasn't changed since the last request (based on ETag or Last-Modified headers).

**Error Responses**

401 Unauthorized
```json
{
    "status": "error",
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired authentication token"
}
```

403 Forbidden
```json
{
    "status": "error",
    "code": "FORBIDDEN",
    "message": "Insufficient permissions to access this resource"
}
```

500 Internal Server Error
```json
{
    "status": "error",
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred"
}
```

### Get Single Book

Retrieves detailed information about a specific book.

**Endpoint:** `GET /books/{bookId}`

**Authentication Required:** Yes

**URL Parameters:**

| Parameter | Type   | Required | Description        |
|-----------|--------|----------|--------------------|
| bookId    | string | Yes      | Unique book ID     |

**Response Headers:**

```
ETag: "66b65df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 15 Jan 2024 15:30:00 GMT
Cache-Control: private, max-age=3600
Vary: Accept, Authorization
```

**Success Response (200 OK)**

```json
{
    "status": "success",
    "data": {
        "book": {
            "id": "book123",
            "title": "The Great Adventure",
            "author": "Jane Smith",
            "description": "An epic journey through time...",
            "language": "English",
            "publisher": "Adventure Books Inc",
            "publishedDate": "2024-01-15",
            "isbn": "978-3-16-148410-0",
            "price": 29.99,
            "status": "ACTIVE",
            "createdDate": "2024-01-01T10:00:00Z",
            "updatedDate": "2024-01-15T15:30:00Z",
            "inactiveDate": null,
            "coverImages": [
                "https://bookhub.com/images/book123-cover1.jpg",
                "https://bookhub.com/images/book123-cover2.jpg"
            ],
            "genres": ["Adventure", "Fantasy"],
            "bookFormat": "Hardcover",
            "ratingsByStars": {
                "1": 10,
                "2": 20,
                "3": 30,
                "4": 40,
                "5": 50
            },
            "numberOfReviews": 150
        }
    }
}
```

**Not Modified Response (304)**

Returned when the resource hasn't changed since the last request (based on ETag or Last-Modified headers).

**Error Responses**

401 Unauthorized
```json
{
    "status": "error",
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired authentication token"
}
```

403 Forbidden
```json
{
    "status": "error",
    "code": "FORBIDDEN",
    "message": "Insufficient permissions to access this resource"
}
```

404 Not Found
```json
{
    "status": "error",
    "code": "NOT_FOUND",
    "message": "Book not found"
}
```

500 Internal Server Error
```json
{
    "status": "error",
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred"
}
```

## Rate Limiting

All API endpoints are subject to rate limiting:
- 1000 requests per hour per publisher
- Rate limit headers are included in all responses:
  - X-RateLimit-Limit: Maximum number of requests allowed per hour
  - X-RateLimit-Remaining: Number of requests remaining in the current time window
  - X-RateLimit-Reset: Time when the rate limit will reset (Unix timestamp)

## Cache Implementation Guidelines

### Client-Side Caching

Clients should implement the following caching strategies:

1. Store the ETag and Last-Modified values received in responses
2. Include If-None-Match and/or If-Modified-Since headers in subsequent requests
3. Handle 304 Not Modified responses appropriately by using cached data
4. Respect Cache-Control directives
5. Consider the Vary header when caching responses

### Cache Duration

1. List endpoints (GET /books):
   - Cache-Control: private, max-age=3600 (1 hour)
   - Vary: Accept, Authorization
   - Conditional requests supported

2. Individual book endpoints (GET /books/{bookId}):
   - Cache-Control: private, max-age=3600 (1 hour)
   - Vary: Accept, Authorization
   - Conditional requests supported

### Cache Invalidation

Clients should invalidate their cache when:

1. Receiving a 200 response with new content
2. Receiving error responses (4xx, 5xx)
3. Cache-Control max-age expires
4. Making modifications to resources (POST, PUT, DELETE requests)

## Notes

1. All timestamps are returned in ISO 8601 format (UTC)
2. The API uses standard HTTP status codes to indicate success or failure
3. Publishers can only access their own books
4. The response format is consistent across all endpoints
5. Pagination is cursor-based to handle large datasets efficiently
6. Cache headers are included in all responses to optimize performance
7. ETags are strong validators unless explicitly specified as weak (W/ prefix)
8. Cache-Control headers may be adjusted based on resource volatility
