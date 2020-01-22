#!/bin/bash -e

# ---------------------------------------------------------------------------
# This script is a Terraform External Data Source
# See https://www.terraform.io/docs/providers/external/data_source.html
# Example usage:
#   echo '{"environment": "staging", "service_name": "membership-service"}' | generic/ecs_service/get-task.sh
# ---------------------------------------------------------------------------

eval "$(jq -r '@sh "ENVIRONMENT=\(.environment) SERVICE_NAME=\(.service_name)"')"

SERVICE=$(aws ecs describe-services --cluster "sbires-services-${ENVIRONMENT}" --service "${SERVICE_NAME}")
DEPLOYMENT_COUNT=$(echo "${SERVICE}" | jq -r '.services[].deployments | length')
TASK_ARN=$(echo "${SERVICE}" | jq -r '.services[].deployments[].taskDefinition')
TASK_NAME=$(echo "${TASK_ARN}" | sed 's:.*/::')

# If the service doesn't exist, return a sample Hello World application

if [[ -z "${TASK_ARN}" ]]; then
  echo "[get-task.sh] WARNING: There is no service called ${SERVICE_NAME}" 1>&2
  HELLO_TASK=$(aws ecs describe-task-definition --task-definition hello-world | jq -r '.taskDefinition.taskDefinitionArn' | sed 's:.*/::')
  jq -n --arg task_name "${HELLO_TASK}" '{ "task_name": $task_name }'
  exit 0
fi

# We cannot proceed if a deployment is in progress
# - the user won't want to reset to the old task definition
# - but the new one might not be stable 

if [[ "${DEPLOYMENT_COUNT}" -gt 1 ]]; then
  DEPLOYMENT=$(echo "${TASK_NAME}" | tr -s '\n' ' ')
  echo "[get-task.sh] ERROR: Deployment in progress for ${SERVICE_NAME}" 1>&2
  echo "  ${DEPLOYMENT}" 1>&2
  echo "  Please try again later" 1>&2
  exit 1
fi

# All good, return the current task definition
echo "[get-task.sh] INFO: ${SERVICE_NAME} currently running ${TASK_NAME}" 1>&2
jq -n --arg task_name "${TASK_NAME}" '{ "task_name": $task_name }'
