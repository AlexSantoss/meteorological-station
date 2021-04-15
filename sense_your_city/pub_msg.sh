#!/bin/bash
function b64tr() { base64 -w 0 | tr '+/' '-_' | tr -d '=$'; }
function b64sed() { base64 | sed s/\+/-/ | sed -E s/=+$//; }

timeiat=$(date +%s)
timeexp=$(expr $timeiat + 30)

header=$(echo -n '{"typ":"JWT","alg":"RS256"}' | b64tr )
payload=$(echo -n '{"iat":'"$timeiat"',"exp":'"$timeexp"',"aud":"caixinhas"}' | b64tr )
signature=$(echo -n $header.$payload | openssl dgst -binary -sha256 -sign a.key | b64tr )

token=$header.$payload.$signature
msg=$(echo -n "$1" | b64tr )

curl -X POST \
  -H 'authorization: Bearer '"$token" \
  -H 'content-type: application/json' \
  -H 'cache-control: no-cache' \
  --data '{"binary_data": "'$msg'"}' \
  'https://cloudiotdevice.googleapis.com/v1/projects/caixinhas/locations/us-central1/registries/caixinhas/devices/roberto:publishEvent'
