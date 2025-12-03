# Create Book Request Model

## Overview

This document defines the request body schema for the Create Book API endpoint (`POST /api/v1/books`).

## Request Body Schema

### JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CreateBookRequest",
  "type": "object",
  "required": ["title", "author", "isbn", "price"],
  "properties": {
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500,
      "description": "The title of the book"
    },
    "author": {
      "type": "string",
      "minLength": 1,
      "maxLength": 200,
      "description": "The author of the book"
    },
    "description": {
      "type": "string",
      "maxLength": 5000,
      "description": "A detailed description of the book"
    },
    "language": {
      "type": "string",
      "pattern": "^[a-z]{2}(-[A-Z]{2})?$",
      "description": "Language code in ISO 639-1 format (e.g., 'en', 'es', 'fr-CA')"
    },
    "publishedDate": {
      "type": "string",
      "format": "date",
      "description": "Publication date in ISO 8601 format (YYYY-MM-DD)"
    },
    "isbn": {
      "type": "string",
      "pattern": "^(?:ISBN(?:-1[03])?:? )?(?=[0-9X]{10}$|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}$|97[89][0-9]{10}$|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$",
      "description": "International Standard Book Number (ISBN-10 or ISBN-13)"
    },
    "price": {
      "type": "number",
      "minimum": 0,
      "multipleOf": 0.01,
      "description": "Price in USD"
    },
    "coverImages": {
      "type": "array",
      "items": {
        "type": "string",
        "format": "uri"
      },
      "maxItems": 10,
      "description": "Array of cover image URLs"
    },
    "genres": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 50
      },
      "maxItems": 10,
      "description": "Array of genre classifications"
    },
    "bookFormat": {
      "type": "string",
      "enum": ["Paperback", "Hardcover", "eBook"],
      "description": "The format of the book"
    }
  }
}
```

## Field Definitions

### Required Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `title` | string | 1-500 characters | The title of the book |
| `author` | string | 1-200 characters | The author's name |
| `isbn` | string | Valid ISBN-10 or ISBN-13 | International Standard Book Number |
| `price` | number | ≥ 0, max 2 decimal places | Price in USD |

### Optional Fields

| Field | Type | Constraints | Default | Description |
|-------|------|-------------|---------|-------------|
| `description` | string | Max 5000 characters | `null` | Book description/synopsis |
| `language` | string | ISO 639-1 code | `"en"` | Language of the book |
| `publishedDate` | string | ISO 8601 date | `null` | Publication date |
| `coverImages` | array | Max 10 URLs | `[]` | Cover image URLs |
| `genres` | array | Max 10 items | `[]` | Genre classifications |
| `bookFormat` | string | Enum value | `null` | Physical/digital format |

## Example Request Bodies

### Minimal Request (Required Fields Only)

```json
{
  "title": "The Art of API Design",
  "author": "Jane Developer",
  "isbn": "978-3-16-148410-0",
  "price": 29.99
}
```

### Complete Request (All Fields)

```json
{
  "title": "The Art of API Design",
  "author": "Jane Developer",
  "description": "A comprehensive guide to designing robust, scalable, and developer-friendly APIs. This book covers RESTful principles, authentication patterns, versioning strategies, and real-world examples from leading tech companies.",
  "language": "en",
  "publishedDate": "2025-01-15",
  "isbn": "978-3-16-148410-0",
  "price": 29.99,
  "coverImages": [
    "https://cdn.bookhub.com/covers/api-design-front.jpg",
    "https://cdn.bookhub.com/covers/api-design-back.jpg"
  ],
  "genres": [
    "Technology",
    "Programming",
    "Software Engineering"
  ],
  "bookFormat": "Paperback"
}
```

### eBook Example

```json
{
  "title": "Learning Ruby on Rails",
  "author": "Kat Perreira",
  "description": "A beginner-friendly introduction to web development with Ruby on Rails.",
  "language": "en",
  "publishedDate": "2025-06-01",
  "isbn": "978-0-13-468599-1",
  "price": 19.99,
  "coverImages": [
    "https://cdn.bookhub.com/covers/rails-guide.jpg"
  ],
  "genres": [
    "Technology",
    "Web Development",
    "Ruby"
  ],
  "bookFormat": "eBook"
}
```

## Validation Rules

### Title
- Must not be empty
- Maximum 500 characters
- Leading/trailing whitespace is trimmed

### Author
- Must not be empty
- Maximum 200 characters
- Can include multiple authors separated by commas

### ISBN
- Must be a valid ISBN-10 or ISBN-13 format
- Hyphens and spaces are optional
- Must be unique across the platform
- Examples:
  - `978-3-16-148410-0` (ISBN-13 with hyphens)
  - `9783161484100` (ISBN-13 without hyphens)
  - `0-06-112008-1` (ISBN-10)

### Price
- Must be a non-negative number
- Maximum 2 decimal places
- Stored and charged in USD
- Example: `29.99`

### Language
- ISO 639-1 two-letter code
- Optional regional subtag (ISO 3166-1 alpha-2)
- Examples: `en`, `es`, `fr-CA`, `pt-BR`

### Published Date
- ISO 8601 date format: `YYYY-MM-DD`
- Can be a future date (for pre-orders)
- Example: `2025-01-15`

### Cover Images
- Must be valid HTTPS URLs
- Allowed domains: `cdn.bookhub.com`, `images.bookhub.com`
- Maximum 10 images
- Recommended dimensions: 1500x2400 pixels (1:1.6 aspect ratio)

### Genres
- Maximum 10 genres per book
- Each genre: 1-50 characters
- Common genres: Fiction, Non-Fiction, Technology, Romance, Mystery, Science Fiction, Biography, etc.

### Book Format
- Must be one of: `Paperback`, `Hardcover`, `eBook`
- Case-sensitive

## Server-Set Fields

The following fields are automatically set by the server and should NOT be included in the request:

| Field | Value |
|-------|-------|
| `bookId` | Auto-generated MongoDB ObjectId |
| `publisher` | Extracted from JWT token |
| `status` | Always `PENDING` for new books |
| `createdDate` | Current UTC timestamp |
| `updatedDate` | Current UTC timestamp |
| `inactiveDate` | `null` |
| `ratingsByStars` | `{}` (empty object) |
| `numberOfReviews` | `0` |

