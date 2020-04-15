function collect-evidence () {
  set -e
  local evidence_name=$1
  local evidence_status=$2
  local evidence_details=$3
  local evidence_path="raw/ci/${PIPELINE_RUN_ID}/${evidence_name}.json"
  local content="{ \"commit_sha\": \"$GIT_COMMIT\", \"status\": \"$evidence_status\", \"details\": \"$evidence_details\", \"job_id\": \"$PIPELINE_RUN_ID\" }"
  local encoded_content=$(echo "$content" | base64)

  if [ -z "$evidence_name" ]; then
    echo "Evidence name must be provided"
    return 1
  fi

  if [ -z "$evidence_status" ]; then
    echo "Evidence status must be provided"
    return 1
  fi

  if [ -z "$evidence_details" ]; then
    echo "Evidence details must be provided"
    return 1
  fi

  if [ -z "$PIPELINE_RUN_ID" ]; then
    echo "PIPELINE_RUN_ID must be provided"
    return 1
  fi

  if [ -z "$GIT_COMMIT" ]; then
    echo "GIT_COMMIT must be provided"
    return 1
  fi

  if [ -z "$EVIDENCE_LOCKER_REPO" ]; then
    echo "EVIDENCE_LOCKER_REPO must be provided"
    return 1
  fi

  if [ -z "$GHE_TOKEN" ]; then
    echo "GHE_TOKEN must be provided"
    return 1
  fi

  echo "Uploading evidence ${evidence_name} for job ${PIPELINE_RUN_ID}"

  curl https://github.ibm.com/api/v3/repos/${EVIDENCE_LOCKER_REPO}/contents/${evidence_path} \
    -d "{\"content\":\"${encoded_content}\",\"message\":\"Upload ${evidence_name} for ${PIPELINE_RUN_ID}\"}" \
    -H "Authorization: Bearer ${GHE_TOKEN}" \
    -H "Content-Type: application/json" \
    -X PUT
}
