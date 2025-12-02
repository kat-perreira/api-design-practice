# Create Book Success Response Model

## Overview

This document defines the success response schema for the Create Book API endpoint (`POST /api/v1/books`). A successful response indicates that the book has been created in the system with `PENDING` status.

## Response Details

### HTTP Status Code

```
201 Created
```

### Response Headers

| Header | Description |
|--------|-------------|
| `Content-Type` | `application/json` |
| `Location` | URL to the newly created book resource |
| `X-Request-ID` | Echo of the request ID (if provided) |
| `X-RateLimit-Limit` | Maximum requests per window |
| `X-RateLimit-Remaining` | Remaining requests in current window |
| `X-RateLimit-Reset` | Unix timestamp when the window resets |

### Response Body Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CreateBookSuccessResponse",
  "type": "object",
  "required": ["status", "data", "message"],
  "properties": {
    "status": {
      "type": "string",
      "const": "success",
      "description": "Indicates the request was successful"
    },
    "data": {
      "type": "object",
      "required": ["bookId", "title", "author", "isbn", "price", "status", "createdDate"],
      "properties": {
        "bookId": {
          "type": "string",
          "description": "Unique identifier for the book (MongoDB ObjectId)"
        },
        "title": {
          "type": "string",
          "description": "The title of the book"
        },
        "author": {
          "type": "string",
          "description": "The author of the book"
        },
        "description": {
          "type": "string",
          "description": "Book description"
        },
        "language": {
          "type": "string",
          "description": "Language code"
        },
        "publisher": {
          "type": "string",
          "description": "Publisher identifier"
        },
        "publishedDate": {
          "type": "string",
          "format": "date",
          "description": "Publication date"
        },
        "isbn": {
          "type": "string",
          "description": "ISBN"
        },
        "price": {
          "type": "number",
          "description": "Price in USD"
        },
        "status": {
          "type": "string",
          "const": "PENDING",
          "description": "Book status (always PENDING for new books)"
        },
        "createdDate": {
          "type": "string",
          "format": "date-time",
          "description": "Creation timestamp in ISO 8601 format"
        },
        "updatedDate": {
          "type": "string",
          "format": "date-time",
          "description": "Last update timestamp in ISO 8601 format"
        },
        "coverImages": {
          "type": "array",
          "items": { "type": "string" },
          "description": "Cover image URLs"
        },
        "genres": {
          "type": "array",
          "items": { "type": "string" },
          "description": "Genre classifications"
        },
        "bookFormat": {
          "type": "string",
          "description": "Book format"
        },
        "ratingsByStars": {
          "type": "object",
          "description": "Rating distribution (empty for new books)"
        },
        "numberOfReviews": {
          "type": "integer",
          "description": "Review count (0 for new books)"
        }
      }
    },
    "message": {
      "type": "string",
      "description": "Human-readable success message"
    },
    "links": {
      "type": "object",
      "description": "HATEOAS links for related actions",
      "properties": {
        "self": {
          "type": "string",
          "description": "URL to this book resource"
        },
        "finalize": {
          "type": "string",
          "description": "URL to finalize the book"
        },
        "update": {
          "type": "string",
          "description": "URL to update the book"
        },
        "delete": {
          "type": "string",
          "description": "URL to delete the book"
        }
      }
    }
  }
}
```

## Example Response

### Headers

```http
HTTP/1.1 201 Created
Content-Type: application/json
Location: https://api.bookhub.com/api/v1/books/507f1f77bcf86cd799439011
X-Request-ID: req_abc123xyz
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1733165460
```

### Body (Minimal Request)

Response when only required fields were provided:

```json
{
  "status": "success",
  "data": {
    "bookId": "507f1f77bcf86cd799439011",
    "title": "The Art of API Design",
    "author": "Jane Developer",
    "description": null,
    "language": "en",
    "publisher": "pub_12345",
    "publishedDate": null,
    "isbn": "978-3-16-148410-0",
    "price": 29.99,
    "status": "PENDING",
    "createdDate": "2025-12-02T18:30:00Z",
    "updatedDate": "2025-12-02T18:30:00Z",
    "inactiveDate": null,
    "coverImages": [],
    "genres": [],
    "bookFormat": null,
    "ratingsByStars": {},
    "numberOfReviews": 0
  },
  "message": "Book created successfully. Use PATCH /api/v1/books/{bookId}/finalize to make it available to users.",
  "links": {
    "self": "/api/v1/books/507f1f77bcf86cd799439011",
    "finalize": "/api/v1/books/507f1f77bcf86cd799439011/finalize",
    "update": "/api/v1/books/507f1f77bcf86cd799439011",
    "delete": "/api/v1/books/507f1f77bcf86cd799439011"
  }
}
```

### Body (Complete Request)

Response when all fields were provided:

```json
{
  "status": "success",
  "data": {
    "bookId": "507f1f77bcf86cd799439011",
    "title": "The Art of API Design",
    "author": "Jane Developer",
    "description": "A comprehensive guide to designing robust, scalable, and developer-friendly APIs.",
    "language": "en",
    "publisher": "pub_12345",
    "publishedDate": "2025-01-15",
    "isbn": "978-3-16-148410-0",
    "price": 29.99,
    "status": "PENDING",
    "createdDate": "2025-12-02T18:30:00Z",
    "updatedDate": "2025-12-02T18:30:00Z",
    "inactiveDate": null,
    "coverImages": [
      "https://cdn.bookhub.com/covers/api-design-front.jpg",
      "https://cdn.bookhub.com/covers/api-design-back.jpg"
    ],
    "genres": [
      "Technology",
      "Programming",
      "Software Engineering"
    ],
    "bookFormat": "Paperback",
    "ratingsByStars": {},
    "numberOfReviews": 0
  },
  "message": "Book created successfully. Use PATCH /api/v1/books/{bookId}/finalize to make it available to users.",
  "links": {
    "self": "/api/v1/books/507f1f77bcf86cd799439011",
    "finalize": "/api/v1/books/507f1f77bcf86cd799439011/finalize",
    "update": "/api/v1/books/507f1f77bcf86cd799439011",
    "delete": "/api/v1/books/507f1f77bcf86cd799439011"
  }
}
```

## Response Fields Explained

### Core Fields

| Field | Description |
|-------|-------------|
| `status` | Always `"success"` for 201 responses |
| `data` | Object containing the created book resource |
| `message` | Human-readable message with next steps |
| `links` | HATEOAS links for discoverability |

### Data Object Fields

| Field | Description |
|-------|-------------|
| `bookId` | MongoDB ObjectId, unique identifier |
| `title` | Book title as submitted |
| `author` | Author name as submitted |
| `description` | Book description (null if not provided) |
| `language` | ISO 639-1 language code (defaults to "en") |
| `publisher` | Publisher ID extracted from JWT token |
| `publishedDate` | Publication date (null if not provided) |
| `isbn` | ISBN as submitted |
| `price` | Price in USD |
| `status` | Always `"PENDING"` for new books |
| `createdDate` | Server-generated timestamp (ISO 8601) |
| `updatedDate` | Same as createdDate initially |
| `inactiveDate` | Always `null` for new books |
| `coverImages` | Array of image URLs (empty array if not provided) |
| `genres` | Array of genre strings (empty array if not provided) |
| `bookFormat` | Format enum value (null if not provided) |
| `ratingsByStars` | Empty object for new books |
| `numberOfReviews` | Always `0` for new books |

### HATEOAS Links

The `links` object provides URLs for related actions, enabling API discoverability:

| Link | HTTP Method | Description |
|------|-------------|-------------|
| `self` | GET | Retrieve this book |
| `finalize` | PATCH | Finalize the book (change status to ACTIVE) |
| `update` | PUT | Update book details |
| `delete` | DELETE | Soft-delete the book |

## Notes

1. **Status is always PENDING**: New books cannot be created with ACTIVE status
2. **Publisher is server-set**: Extracted from JWT, cannot be overridden
3. **Timestamps are UTC**: All dates use ISO 8601 format in UTC timezone
4. **Empty arrays vs null**: Arrays default to empty `[]`, other optional fields default to `null`
5. **Location header**: Use this for idempotent retry logic

