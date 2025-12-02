# API Design Practice

A repository for practicing and mastering API design patterns, best practices, and architectural decisions. This is a learning space to work through API design concepts and interview preparation.

## Purpose

- 🏗️ Practice designing robust, scalable APIs
- 📚 Learn from real-world API design patterns
- 🎯 Prepare for senior-level engineering interviews
- 📖 Document learnings and design decisions

## Getting Started

### Running the HTTP Server Example

```bash
# Start the server
ruby workspace/practice.rb

# In another terminal, test the endpoints
curl http://localhost:3000/api/users
curl http://localhost:3000/api/users/1
curl -X POST http://localhost:3000/api/users -H 'Content-Type: application/json' -d '{"name":"New User","email":"new@example.com"}'
curl -X DELETE http://localhost:3000/api/users/2
```

## How HTTP Works

Below is a visual representation of the HTTP request-response cycle implemented in our server:

```mermaid
sequenceDiagram
    participant Client as Client (curl/browser)
    participant Server as HTTP Server<br/>(localhost:3000)
    participant Router as Request Router
    participant Handler as Route Handler
    participant DB as In-Memory Database

    Note over Client,DB: Example: GET /api/users/1
    
    Client->>Server: HTTP Request<br/>GET /api/users/1 HTTP/1.1<br/>Host: localhost:3000<br/>Accept: application/json
    
    activate Server
    Note over Server: Parse request line<br/>method, path, version
    
    Server->>Router: route_request("GET", "/api/users/1", nil)
    activate Router
    
    Note over Router: Match path pattern<br/>/api/users/(\d+)
    
    Router->>Handler: handle_get_user(1)
    activate Handler
    
    Handler->>DB: Lookup user with id=1
    activate DB
    DB-->>Handler: { id: 1, name: "Kat", ... }
    deactivate DB
    
    Handler->>Handler: build_response(200, "OK", user_data)
    Note over Handler: Construct HTTP response<br/>with headers and body
    
    Handler-->>Router: HTTP Response
    deactivate Handler
    Router-->>Server: HTTP Response
    deactivate Router
    
    Server->>Client: HTTP/1.1 200 OK<br/>Content-Type: application/json<br/>Content-Length: 156<br/><br/>{ "id": 1, "name": "Kat", ... }
    deactivate Server
    
    Note over Client: Parse and display response
```

### Request Flow Breakdown

1. **Client sends HTTP request** - Contains method (GET/POST/etc), path, headers, and optional body
2. **Server accepts connection** - TCPServer listens on port 3000 and accepts incoming connections
3. **Parse request** - Extracts method, path, HTTP version, headers, and body
4. **Route matching** - Router checks path patterns to find the right handler
5. **Handler execution** - Executes business logic (fetch/create/update/delete data)
6. **Build response** - Constructs HTTP response with status code, headers, and body
7. **Send response** - Server sends formatted HTTP response back to client
8. **Close connection** - Connection is closed after response is sent

### HTTP Request Structure

```
GET /api/users/1 HTTP/1.1          ← Request Line (Method, Path, Version)
Host: localhost:3000                ← Headers
Accept: application/json            ← Headers
                                    ← Empty line separates headers from body
                                    ← Body (optional, not used in GET)
```

### HTTP Response Structure

```
HTTP/1.1 200 OK                     ← Status Line (Version, Code, Message)
Content-Type: application/json      ← Headers
Content-Length: 156                 ← Headers
Date: Tue, 02 Dec 2025 10:30:00 GMT ← Headers
                                    ← Empty line separates headers from body
{                                   ← Body (JSON data)
  "id": 1,
  "name": "Kat Perreira",
  "email": "kat@example.com"
}
```

## Topics

- RESTful API design principles
- API versioning and compatibility
- Error handling and status codes
- Authentication and authorization
- Rate limiting and throttling
- API documentation
- Microservices communication patterns

## Author

Kat Perreira ♡