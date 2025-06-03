@echo off
echo Deploying Ad Management Backend...

REM Pull latest changes if in a git repository
if exist ".git" (
  echo Pulling latest changes...
  git pull
)

REM Build and start containers
echo Building and starting Docker containers...
docker-compose down
docker-compose build --no-cache
docker-compose up -d

echo Waiting for services to start...
timeout /t 5 /nobreak > nul

REM Check if services are running
echo Checking services status...
docker-compose ps

echo Deployment completed successfully!
echo The application is now running at https://displayonwheels.com