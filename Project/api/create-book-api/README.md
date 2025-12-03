# Create Book API Specification

## Overview

This document specifies the RESTful API for creating a new book in the BookHub platform. Publishers use this endpoint to upload book information to the marketplace. Books are created with a `PENDING` status by default and must be finalized before becoming available to users.

## Quick Reference

| Attribute | Value |
|-----------|-------|
| **Endpoint** | `POST /api/v1/books` |
| **Authentication** | JWT Bearer Token |
| **Content-Type** | application/json |
| **Rate Limit** | 100 requests/minute |

## API Flow Diagram

```mermaid
sequenceDiagram
    participant Publisher
    participant API as BookHub API
    participant Auth as Auth Service
    participant DB as MongoDB

    Note over Publisher,DB: Create Book Flow

    Publisher->>API: POST /api/v1/books<br/>Authorization: Bearer {jwt}<br/>Content-Type: application/json<br/><br/>{book data}
    
    activate API
    
    API->>Auth: Validate JWT Token
    activate Auth
    
    alt Token Invalid
        Auth-->>API: Invalid Token
        API-->>Publisher: 401 Unauthorized<br/>{"code": "UNAUTHORIZED"}
    else Token Valid
        Auth-->>API: Publisher ID + Permissions
        deactivate Auth
        
        API->>API: Validate Request Body
        
        alt Validation Failed
            API-->>Publisher: 400 Bad Request<br/>{"code": "VALIDATION_ERROR"}
        else Validation Passed
            
            API->>DB: Check ISBN Uniqueness
            activate DB
            
            alt ISBN Exists
                DB-->>API: Duplicate Found
                API-->>Publisher: 409 Conflict<br/>{"code": "DUPLICATE_ISBN"}
            else ISBN Unique
                DB-->>API: No Duplicate
                
                API->>DB: Insert Book (status: PENDING)
                DB-->>API: Book Created
                deactivate DB
                
                API-->>Publisher: 201 Created<br/>{"status": "success", "data": {...}}
            end
        end
    end
    
    deactivate API
```

## Book Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PENDING: POST /api/v1/books
    PENDING --> ACTIVE: PATCH /api/v1/books/{id}/finalize
    PENDING --> PENDING: PUT /api/v1/books/{id}
    ACTIVE --> INACTIVE: DELETE /api/v1/books/{id}
    INACTIVE --> [*]
    
    note right of PENDING: Book is created but not visible to users
    note right of ACTIVE: Book is searchable and orderable
    note right of INACTIVE: Book is soft-deleted
```

## Files in this Specification

| File | Description |
|------|-------------|
| [request-model.md](./request-model.md) | Create Book request body schema |
| [success-response.md](./success-response.md) | Successful creation response schema |
| [error-response.md](./error-response.md) | Error response schemas for all failure cases |

## Endpoint Details

### HTTP Method and Path

```
POST /api/v1/books
```

### Request Headers

| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token for authentication (JWT) |
| Content-Type | Yes | Must be `application/json` |
| X-Request-ID | No | Optional unique request identifier for tracing |

### Authentication

All requests must include a valid JWT token in the Authorization header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

The JWT payload must contain:
- `publisherId`: The unique identifier of the publisher
- `permissions`: Array including `books:create`

## Example Usage

### cURL Request

```bash
curl -X POST 'https://api.bookhub.com/api/v1/books' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "The Art of API Design",
    "author": "Jane Developer",
    "description": "A comprehensive guide to designing robust APIs",
    "language": "en",
    "publishedDate": "2025-01-15",
    "isbn": "978-3-16-148410-0",
    "price": 29.99,
    "coverImages": ["https://cdn.bookhub.com/covers/api-design.jpg"],
    "genres": ["Technology", "Programming"],
    "bookFormat": "Paperback"
  }'
```

### Success Response

```json
{
  "status": "success",
  "data": {
    "bookId": "507f1f77bcf86cd799439011",
    "title": "The Art of API Design",
    "author": "Jane Developer",
    "status": "PENDING",
    "createdDate": "2025-12-02T18:30:00Z"
  },
  "message": "Book created successfully. Use PATCH /api/v1/books/{bookId}/finalize to make it available to users.",
  "links": {
    "self": "/api/v1/books/507f1f77bcf86cd799439011",
    "finalize": "/api/v1/books/507f1f77bcf86cd799439011/finalize"
  }
}
```

## Business Rules

1. **Default Status**: All newly created books have status `PENDING`
2. **ISBN Uniqueness**: Each ISBN must be unique across the platform
3. **Publisher Association**: The book is automatically associated with the authenticated publisher
4. **Required Fields**: Title, Author, ISBN, and Price are mandatory
5. **Timestamps**: `createdDate` and `updatedDate` are set automatically by the server
6. **Finalization Required**: Books must be finalized before becoming visible to users

## Rate Limiting

| Limit | Value |
|-------|-------|
| Requests per minute | 100 |
| Burst limit | 20 |

Rate limit headers included in responses:
- `X-RateLimit-Limit`: Maximum requests per window
- `X-RateLimit-Remaining`: Remaining requests in current window
- `X-RateLimit-Reset`: Unix timestamp when the window resets

## Security Considerations

1. All requests must be made over HTTPS
2. JWT tokens expire after 1 hour
3. Publishers can only create books under their own account
4. Input validation prevents injection attacks
5. File URLs (cover images) are validated for allowed domains

## Changelog

| Date | Version | Description |
|------|---------|-------------|
| 2025-12-02 | 1.0.0 | Initial specification |

