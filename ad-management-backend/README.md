# Ad Management Backend

## Docker Setup Instructions

This repository contains a Dockerized version of the Ad Management Backend application.

### Prerequisites

- Docker and Docker Compose installed on your machine
- Git (to clone the repository)

### Setup Instructions

1. Clone the repository (if you haven't already):
   ```
   git clone <repository-url>
   cd ad-management-backend
   ```

2. Build and start the Docker containers:
   ```
   docker-compose up -d
   ```

3. The application will be available at:
   ```
   https://displayonwheels.com
   ```

### Environment Variables

The following environment variables are configured in the docker-compose.yml file:

- `DATABASE_URL`: Connection string for the MySQL database
- `JWT_SECRET`: Secret key for JWT token generation
- `NODE_ENV`: Set to 'production' for production environment

### Services

The Docker Compose setup includes the following services:

1. **app**: The Node.js application
2. **db**: MySQL database
3. **redis**: Redis for caching and session management

### Volumes

The following volumes are created to persist data:

- `mysql-data`: Stores MySQL database files
- `redis-data`: Stores Redis data
- `./temp-uploads:/app/temp-uploads`: Maps the local temp-uploads directory to the container

### Stopping the Application

To stop the application, run:
```
docker-compose down
```

To stop the application and remove all data volumes, run:
```
docker-compose down -v
```

### Troubleshooting

- If you encounter any issues, check the logs with:
  ```
  docker-compose logs
  ```

- To check logs for a specific service:
  ```
  docker-compose logs app
  docker-compose logs db
  docker-compose logs redis
  ```