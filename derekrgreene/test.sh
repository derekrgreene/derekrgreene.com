#!/bin/bash

# Your webhook endpoint (adjust the URL as needed)
WEBHOOK_URL="http://localhost:4000/api/deploy/webhook"
SECRET="78fa3810-e5b2-4508-8136-52a564c3ea25"

# Test payload (GitHub push event format)
PAYLOAD='{
  "ref": "refs/heads/main",
  "commits": [
    {
      "id": "abc123def456",
      "message": "Deploy to PROD - fix user login bug",
      "author": {
        "name": "Test User",
        "email": "test@example.com"
      }
    }
  ]
}'

# Generate the signature
SIGNATURE=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$SECRET" | sed 's/^.* //')

# Test 1: Valid webhook with PROD in commit message (should trigger deployment)
echo "=== Test 1: Valid webhook with PROD commit ==="
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: sha256=$SIGNATURE" \
  -d "$PAYLOAD"

echo -e "\n\n"

# Test 2: Valid webhook without PROD in commit message (should not trigger deployment)
PAYLOAD_NO_PROD='{
  "ref": "refs/heads/main",
  "commits": [
    {
      "id": "abc123def456",
      "message": "Fix minor bug in user interface",
      "author": {
        "name": "Test User",
        "email": "test@example.com"
      }
    }
  ]
}'

SIGNATURE_NO_PROD=$(echo -n "$PAYLOAD_NO_PROD" | openssl dgst -sha256 -hmac "$SECRET" | sed 's/^.* //')

echo "=== Test 2: Valid webhook without PROD commit ==="
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: sha256=$SIGNATURE_NO_PROD" \
  -d "$PAYLOAD_NO_PROD"

echo -e "\n\n"

# Test 3: Invalid signature (should fail)
echo "=== Test 3: Invalid signature ==="
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: sha256=invalid_signature_here" \
  -d "$PAYLOAD"

echo -e "\n\n"

# Test 4: Wrong event type (should fail)
echo "=== Test 4: Wrong event type ==="
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: pull_request" \
  -H "X-Hub-Signature-256: sha256=$SIGNATURE" \
  -d "$PAYLOAD"

echo -e "\n"
