### Project Requirements

At the moment, the company gathers the information from publishers in form of excel sheets and then manually uploads the information to their database. This is a very time consuming process and the company is looking to automate this process by providing an API to the publishers. The task is to design the APIs for the publishers to upload and manage their books.
The API should be able to provide the following capabilities to a publisher:

- Upload a book
  - Ensure status is `PENDING` by default. This means that the book is not yet available for users to search and order.
  - There must be a way to finalize the book and make it available for users to search and order.
- Update a book
- Delete a book
- Get a book
- Get all books
