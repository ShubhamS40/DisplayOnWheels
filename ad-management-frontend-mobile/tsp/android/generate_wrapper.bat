@echo off
echo Generating Gradle Wrapper...

REM Download the Gradle wrapper jar file
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/gradle/gradle/raw/v7.5.0/gradle/wrapper/gradle-wrapper.jar', 'gradle\wrapper\gradle-wrapper.jar')"

REM Download the Gradle wrapper batch file
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/gradle/gradle/raw/v7.5.0/gradle/wrapper/gradlew.bat', 'gradlew.bat')"

REM Download the Gradle wrapper shell script
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/gradle/gradle/raw/v7.5.0/gradle/wrapper/gradlew', 'gradlew')"

echo Gradle Wrapper generated successfully!