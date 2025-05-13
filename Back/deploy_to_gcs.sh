#!/bin/bash

# Build the Docker image
docker-compose build

# Save the image to a tar file
docker save -o backend.tar web

# Upload to Google Cloud Storage
gsutil cp backend.tar gs://your-bucket-name/backend.tar

# Clean up
rm backend.tar

echo "Deployment completed successfully!" 