#!/bin/bash
set -e

PROJECT_ID="httpsms-deploy-01357"
REGION="europe-west1"
API_SERVICE="httpsms-api"
WEB_SERVICE="httpsms-web"
REPO="httpsms"

echo "========================================"
echo "  httpSMS Deploy to Google Cloud Run"
echo "========================================"

# 1. Get API URL
API_URL=$(gcloud run services describe $API_SERVICE --region=$REGION --format="value(status.url)" --project=$PROJECT_ID)
echo ">>> API is running at: $API_URL"

# 2. Prepare environment for Nuxt build
echo ">>> Preparing .env file for Nuxt build..."
cat > ./web/.env <<EOF
API_BASE_URL=$API_URL
$(cat ./web/.env.production | grep -E "FIREBASE_|APP_|CHECKOUT_|PUSHER_|CLOUDFLARE_")
EOF

# 3. Build Web App using Cloud Build
echo ">>> Building Web app via Cloud Build..."
gcloud builds submit --tag ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/web:latest ./web \
  --project=$PROJECT_ID

# Clean up temporary .env file
rm ./web/.env

# 4. Deploy Web App to Cloud Run
echo ">>> Deploying Web to Cloud Run..."
gcloud run deploy $WEB_SERVICE \
  --image=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/web:latest \
  --region=$REGION \
  --platform=managed \
  --allow-unauthenticated \
  --port=3000 \
  --memory=256Mi \
  --cpu=1 \
  --project=$PROJECT_ID

# 5. Get final URL
WEB_URL=$(gcloud run services describe $WEB_SERVICE --region=$REGION --format="value(status.url)" --project=$PROJECT_ID)

echo ""
echo "========================================"
echo "  RE-DEPLOY COMPLETE! 🎉"
echo "========================================"
echo ""
echo "  🌐 Web URL: $WEB_URL"
echo "  🔧 API URL: $API_URL"
echo "========================================"
