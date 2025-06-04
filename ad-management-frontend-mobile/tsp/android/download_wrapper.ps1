# PowerShell script to download Gradle wrapper files

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path "gradle/wrapper" | Out-Null

# Download gradle-wrapper.jar
Invoke-WebRequest -Uri "https://github.com/gradle/gradle/raw/v7.5.0/gradle/wrapper/gradle-wrapper.jar" -OutFile "gradle/wrapper/gradle-wrapper.jar"

# Download gradlew.bat
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gradle/gradle/v7.5.0/gradlew.bat" -OutFile "gradlew.bat"

# Download gradlew
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gradle/gradle/v7.5.0/gradlew" -OutFile "gradlew"

# Make gradlew executable (not necessary on Windows, but good practice)

Write-Host "Gradle wrapper files downloaded successfully!" -ForegroundColor Green