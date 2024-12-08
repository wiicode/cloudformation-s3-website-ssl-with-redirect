#!/bin/bash

# File containing subdomains
SUBDOMAIN_FILE="build_domains.txt"
TEMPLATE_FILE="cloudformation-s3-website-ssl-with-redirect.yaml"
ACM_CERTIFICATE_ARN="arn:aws:acm:us-east-1:YOURACCOUNT:certificate/YOURGUID"
HOSTED_ZONE_ID="ENTERYOURZONE"
REDIRECT_TARGET="ENTERYOURREDIRECT"

# Loop through subdomains and update stacks
while read -r SUBDOMAIN; do
  STACK_NAME=$(echo "$SUBDOMAIN" | cut -d. -f1)
  echo "Updating stack for subdomain: $SUBDOMAIN (stack name: $STACK_NAME)"

  aws cloudformation update-stack --stack-name "$STACK_NAME" \
    --template-body "file://$TEMPLATE_FILE" \
    --parameters \
    ParameterKey=BucketName,ParameterValue="$SUBDOMAIN" \
    ParameterKey=RedirectTarget,ParameterValue="$REDIRECT_TARGET" \
    ParameterKey=DomainName,ParameterValue="$SUBDOMAIN" \
    ParameterKey=ACMCertificateARN,ParameterValue="$ACM_CERTIFICATE_ARN" \
    ParameterKey=HostedZoneId,ParameterValue="$HOSTED_ZONE_ID" \
    --capabilities CAPABILITY_NAMED_IAM

  if [[ $? -eq 0 ]]; then
    echo "Stack update initiated for $SUBDOMAIN"
  else
    echo "Failed to initiate stack update for $SUBDOMAIN"
  fi
done < "$SUBDOMAIN_FILE"
