#!/usr/bin/env bash
echo "Testing the API endpoint..."
echo curl -X POST \
  -H \"Content-Type: application/json\" \
  -d "'"'{"message": "Is this line secure?"}'"'" \
  https://ghost.hurated.com/interact
  
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "Is this line secure?"}' \
  https://ghost.hurated.com/interact
  