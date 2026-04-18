#!/bin/bash
set -e

PROJECT_ID="httpsms-deploy-01357"
REGION="europe-west1"
API_SERVICE="httpsms-api"
REPO="httpsms"

echo "========================================"
echo "  httpSMS API Deploy to Google Cloud Run"
echo "========================================"

# 1. Build API using Cloud Build
echo ">>> Building API via Cloud Build..."
gcloud builds submit --tag ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/api:latest ./api \
  --project=$PROJECT_ID

# 2. Deploy API to Cloud Run
echo ">>> Deploying API to Cloud Run..."
gcloud run deploy $API_SERVICE \
  --image=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/api:latest \
  --region=$REGION \
  --platform=managed \
  --allow-unauthenticated \
  --port=8000 \
  --project=$PROJECT_ID

echo ""
echo "========================================"
echo "  API RE-DEPLOY COMPLETE! 🎉"
echo "========================================"
