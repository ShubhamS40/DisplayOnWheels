# Use Node.js LTS version as the base image
FROM node:20-alpine AS base

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm ci

# Copy all project files
COPY . .

# Expose port 3000
EXPOSE 3000

# Run the Next.js application in development mode
CMD ["npm", "run", "dev"]
