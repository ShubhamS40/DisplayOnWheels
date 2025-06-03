#!/bin/bash

# Exit on error
set -e

echo "Deploying Ad Management Backend..."

# Pull latest changes if in a git repository
if [ -d ".git" ]; then
  echo "Pulling latest changes..."
  git pull
fi

# Build and start containers
echo "Building and starting Docker containers..."
docker-compose down
docker-compose build --no-cache
docker-compose up -d

echo "Waiting for services to start..."
sleep 5

# Check if services are running
echo "Checking services status..."
docker-compose ps

echo "Deployment completed successfully!"
echo "The application is now running at https://displayonwheels.com"