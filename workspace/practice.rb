#!/usr/bin/env ruby
# HTTP Examples in Ruby
# Demonstrates how HTTP works with practical examples

require 'net/http'
require 'json'
require 'uri'
require 'time'

puts "=" * 60
puts "HTTP EXAMPLES IN RUBY"
puts "=" * 60

# ============================================================================
# PART 1: MAKING HTTP REQUESTS (Client Side)
# ============================================================================

puts "\n📤 PART 1: Making HTTP Requests (Acting as a Client)\n"

# Example 1: Simple GET Request
def example_get_request
  puts "\n--- Example 1: GET Request ---"
  
  uri = URI('https://jsonplaceholder.typicode.com/users/1')
  
  # Create the HTTP request
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(uri.path)
  request['Accept'] = 'application/json'
  request['User-Agent'] = 'Ruby HTTP Client'
  
  puts "Sending GET request to: #{uri}"
  puts "Headers: #{request.to_hash}"
  
  # Send the request and get response
  response = http.request(request)
  
  puts "\nResponse Status: #{response.code} #{response.message}"
  puts "Response Headers:"
  response.each_header do |key, value|
    puts "  #{key}: #{value}"
  end
  
  puts "\nResponse Body:"
  user = JSON.parse(response.body)
  puts JSON.pretty_generate(user)
  
rescue StandardError => e
  puts "Error: #{e.message}"
end

# Example 2: POST Request (Creating a Resource)
def example_post_request
  puts "\n--- Example 2: POST Request ---"
  
  uri = URI('https://jsonplaceholder.typicode.com/users')
  
  # Data to send
  user_data = {
    name: "Kat Perreira",
    email: "kat@example.com",
    username: "katperreira"
  }
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri.path)
  request['Content-Type'] = 'application/json'
  request['Accept'] = 'application/json'
  request.body = user_data.to_json
  
  puts "Sending POST request to: #{uri}"
  puts "Request Body: #{request.body}"
  
  response = http.request(request)
  
  puts "\nResponse Status: #{response.code} #{response.message}"
  puts "Response Body:"
  puts JSON.pretty_generate(JSON.parse(response.body))
  
rescue StandardError => e
  puts "Error: #{e.message}"
end

# Example 3: PUT Request (Updating a Resource)
def example_put_request
  puts "\n--- Example 3: PUT Request ---"
  
  uri = URI('https://jsonplaceholder.typicode.com/users/1')
  
  updated_data = {
    id: 1,
    name: "Kat Perreira Updated",
    email: "kat.updated@example.com",
    username: "katperreira"
  }
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Put.new(uri.path)
  request['Content-Type'] = 'application/json'
  request.body = updated_data.to_json
  
  puts "Sending PUT request to: #{uri}"
  puts "Request Body: #{request.body}"
  
  response = http.request(request)
  
  puts "\nResponse Status: #{response.code} #{response.message}"
  puts "Response Body:"
  puts JSON.pretty_generate(JSON.parse(response.body))
  
rescue StandardError => e
  puts "Error: #{e.message}"
end

# Example 4: DELETE Request
def example_delete_request
  puts "\n--- Example 4: DELETE Request ---"
  
#   uri = URI('https://jsonplaceholder.typicode.com/users/1')
  
#   http = Net::HTTP.new(uri.host, uri.port)
#   http.use_ssl = true
  
  request = Net::HTTP::Delete.new(uri.path)
  
  puts "Sending DELETE request to: #{uri}"
  
  response = http.request(request)
  
  puts "\nResponse Status: #{response.code} #{response.message}"
  puts "Resource deleted successfully!" if response.code == '200'
  
rescue StandardError => e
  puts "Error: #{e.message}"
end

# Run the client examples
example_get_request
example_post_request
example_put_request
example_delete_request

# ============================================================================
# PART 2: BUILDING A SIMPLE HTTP SERVER
# ============================================================================

puts "\n" + "=" * 60
puts "📥 PART 2: Building a Simple HTTP Server"
puts "=" * 60

require 'socket'

class SimpleHTTPServer
  def initialize(port = 3000)
    @port = port
    @users = {
      1 => { id: 1, name: "Kat Perreira", email: "kat@example.com", role: "engineer" },
      2 => { id: 2, name: "Jane Doe", email: "jane@example.com", role: "designer" }
    }
    @next_id = 3
  end
  
  def start
    server = TCPServer.new(@port)
    puts "\n🚀 Server started on http://localhost:#{@port}"
    puts "Try these commands in another terminal:"
    puts "  curl http://localhost:#{@port}/api/users"
    puts "  curl http://localhost:#{@port}/api/users/1"
    puts "  curl -X POST http://localhost:#{@port}/api/users -H 'Content-Type: application/json' -d '{\"name\":\"New User\",\"email\":\"new@example.com\"}'"
    puts "\nPress Ctrl+C to stop the server\n\n"
    
    loop do
      client = server.accept
      request_line = client.gets
      
      next unless request_line
      
      # Parse the request
      method, path, version = request_line.split
      
      # Read headers
      headers = {}
      while (line = client.gets) && line != "\r\n"
        key, value = line.split(': ', 2)
        headers[key] = value.strip if value
      end
      
      # Read body if present
      body = nil
      if headers['Content-Length']
        body = client.read(headers['Content-Length'].to_i)
      end
      
      puts "#{Time.now} - #{method} #{path}"
      
      # Route the request
      response = route_request(method, path, body)
      
      # Send response
      client.print response
      client.close
    end
  rescue Interrupt
    puts "\n\n👋 Server shutting down..."
    server.close if server
  end
  
  private
  
  def route_request(method, path, body)
    # Match specific user by ID
    if method == 'GET' && path =~ /^\/api\/users\/(\d+)$/
      user_id = $1.to_i
      handle_get_user(user_id)
    elsif method == 'DELETE' && path =~ /^\/api\/users\/(\d+)$/
      user_id = $1.to_i
      handle_delete_user(user_id)
    # Match all users
    elsif method == 'GET' && path == '/api/users'
      handle_get_users
    elsif method == 'POST' && path == '/api/users'
      handle_create_user(body)
    else
      handle_not_found
    end
  end
  
  def handle_get_users
    build_response(200, 'OK', @users.values)
  end
  
  def handle_get_user(id)
    user = @users[id]
    if user
      build_response(200, 'OK', user)
    else
      build_response(404, 'Not Found', { error: 'User not found' })
    end
  end
  
  def handle_create_user(body)
    return build_response(400, 'Bad Request', { error: 'No body provided' }) unless body
    
    data = JSON.parse(body)
    new_user = {
      id: @next_id,
      name: data['name'],
      email: data['email'],
      role: data['role'] || 'user',
      created_at: Time.now.iso8601
    }
    
    @users[@next_id] = new_user
    @next_id += 1
    
    build_response(201, 'Created', new_user)
  rescue JSON::ParserError
    build_response(400, 'Bad Request', { error: 'Invalid JSON' })
  end
  
  def handle_delete_user(id)
    if @users.delete(id)
      build_response(204, 'No Content', nil)
    else
      build_response(404, 'Not Found', { error: 'User not found' })
    end
  end
  
  def handle_not_found
    build_response(404, 'Not Found', { error: 'Endpoint not found' })
  end
  
  def build_response(status_code, status_message, data)
    body = data ? JSON.pretty_generate(data) : ''
    
    response = "HTTP/1.1 #{status_code} #{status_message}\r\n"
    response += "Content-Type: application/json\r\n"
    response += "Content-Length: #{body.bytesize}\r\n"
    response += "Connection: close\r\n"
    response += "Date: #{Time.now.httpdate}\r\n"
    response += "\r\n"
    response += body
    
    response
  end
end

# Uncomment the line below to start the server
# (Comment out the client examples above first)
SimpleHTTPServer.new(3000).start

puts "\n" + "=" * 60
puts "💡 To run the HTTP server:"
puts "   1. Comment out the client examples (lines 124-127)"
puts "   2. Uncomment the last line: SimpleHTTPServer.new(3000).start"
puts "   3. Run: ruby practice.rb"
puts "=" * 60

