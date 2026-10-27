#!/usr/bin/env bash
# Create an API-driven Terraform Cloud run and save its cost-estimate response.
set -euo pipefail

TFC_HOST="${TFC_HOST:-app.terraform.io}"
TFC_ORGANIZATION="${TFC_ORGANIZATION:-travis-dev}"
TFC_WORKSPACE="${TFC_WORKSPACE:-example-terraform-api}"
TFC_TOKEN="${TFC_TOKEN:-}"
TFC_RUN_MESSAGE="${TFC_RUN_MESSAGE:-API-driven cost-estimate experiment}"
TFC_CREATE_WORKSPACE="${TFC_CREATE_WORKSPACE:-false}"
TFC_RUN_ACTION="${TFC_RUN_ACTION:-}"
TFC_RUN_ACTION_ID="${TFC_RUN_ACTION_ID:-}"
POLL_INTERVAL_SECONDS="${POLL_INTERVAL_SECONDS:-2}"
MAX_POLLS="${MAX_POLLS:-120}"

if [[ -z "$TFC_TOKEN" && -f "$HOME/.terraform.d/credentials.tfrc.json" ]]; then
  TFC_TOKEN="$(jq -r --arg host "$TFC_HOST" '.credentials[$host].token // empty' \
    "$HOME/.terraform.d/credentials.tfrc.json")"
fi

if [[ -z "$TFC_TOKEN" ]]; then
  echo "Set TFC_TOKEN to a Terraform Cloud user or team API token." >&2
  exit 1
fi

api_url="https://${TFC_HOST}/api/v2"
request_body="$(mktemp)"
response_body="$(mktemp)"
archive="$(mktemp "${TMPDIR:-/tmp}/terraform-config.XXXXXX.tar.gz")"
trap 'rm -f "$request_body" "$response_body" "$archive"' EXIT

api_request() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local http_code

  if [[ -n "$body" ]]; then
    http_code="$(curl --silent --show-error --output "$response_body" --write-out '%{http_code}' \
      --request "$method" \
      --header "Authorization: Bearer $TFC_TOKEN" \
      --header "Content-Type: application/vnd.api+json" \
      --data-binary "@$body" \
      "$api_url$path")"
  else
    http_code="$(curl --silent --show-error --output "$response_body" --write-out '%{http_code}' \
      --request "$method" \
      --header "Authorization: Bearer $TFC_TOKEN" \
      --header "Content-Type: application/vnd.api+json" \
      "$api_url$path")"
  fi

  if ((http_code < 200 || http_code >= 300)); then
    cat "$response_body" >&2
    echo "Terraform Cloud API request failed: $method $path (HTTP $http_code)" >&2
    return 1
  fi
}

if [[ -n "$TFC_RUN_ACTION" || -n "$TFC_RUN_ACTION_ID" ]]; then
  if [[ -z "$TFC_RUN_ACTION" || -z "$TFC_RUN_ACTION_ID" ]]; then
    echo "Set both TFC_RUN_ACTION and TFC_RUN_ACTION_ID." >&2
    exit 1
  fi
  if [[ "$TFC_RUN_ACTION" != "cancel" && "$TFC_RUN_ACTION" != "discard" ]]; then
    echo "TFC_RUN_ACTION must be cancel or discard." >&2
    exit 1
  fi
  jq -n '{data: {type: "runs"}}' >"$request_body"
  api_request POST "/runs/${TFC_RUN_ACTION_ID}/actions/${TFC_RUN_ACTION}" "$request_body"
  echo "Requested ${TFC_RUN_ACTION} for run: $TFC_RUN_ACTION_ID"
  exit 0
fi

workspace_path="/organizations/${TFC_ORGANIZATION}/workspaces/${TFC_WORKSPACE}"
if ! api_request GET "$workspace_path"; then
  if [[ "$TFC_CREATE_WORKSPACE" != "true" ]]; then
    echo "Workspace $TFC_ORGANIZATION/$TFC_WORKSPACE was not found or is not accessible." >&2
    echo "Set TFC_CREATE_WORKSPACE=true only when bootstrapping a new workspace." >&2
    exit 1
  fi
  jq -n --arg name "$TFC_WORKSPACE" '{
    data: {
      type: "workspaces",
      attributes: {
        name: $name,
        "execution-mode": "remote",
        "auto-apply": false,
        "terraform-version": "1.17.0"
      }
    }
  }' >"$request_body"
  api_request POST "/organizations/${TFC_ORGANIZATION}/workspaces" "$request_body"
fi
workspace_id="$(jq -r '.data.id' "$response_body")"
echo "Using workspace: $TFC_WORKSPACE ($workspace_id)"

jq -n '{data: {
  type: "configuration-versions",
  attributes: {"auto-queue-runs": false}
}}' >"$request_body"
api_request POST "/workspaces/${workspace_id}/configuration-versions" "$request_body"
configuration_version_id="$(jq -r '.data.id' "$response_body")"
upload_url="$(jq -r '.data.attributes["upload-url"]' "$response_body")"

tar \
  --exclude='./.terraform' \
  --exclude='./.terraform.lock.hcl' \
  --exclude='./terraform.tfstate*' \
  --exclude='./cost-estimate-*.json' \
  --create --gzip --file "$archive" \
  -C "$(dirname "$0")" .
curl --fail --silent --show-error --request PUT \
  --header "Content-Type: application/octet-stream" \
  --upload-file "$archive" \
  "$upload_url"

jq -n \
  --arg workspace_id "$workspace_id" \
  --arg configuration_version_id "$configuration_version_id" \
  --arg message "$TFC_RUN_MESSAGE" \
  '{
    data: {
      type: "runs",
      attributes: {message: $message, "auto-apply": false},
      relationships: {
        workspace: {data: {type: "workspaces", id: $workspace_id}},
        "configuration-version": {
          data: {type: "configuration-versions", id: $configuration_version_id}
        }
      }
    }
  }' >"$request_body"
api_request POST "/runs" "$request_body"
run_id="$(jq -r '.data.id' "$response_body")"
echo "Created run: $run_id"

for ((poll = 1; poll <= MAX_POLLS; poll++)); do
  api_request GET "/runs/${run_id}"
  run_status="$(jq -r '.data.attributes.status' "$response_body")"
  echo "Run status: $run_status"

  if [[ "$run_status" == "planned_and_finished" || "$run_status" == "cost_estimated" ]]; then
    break
  fi
  if [[ "$run_status" == *"errored" || "$run_status" == "canceled" || "$run_status" == "discarded" ]]; then
    cat "$response_body" >&2
    echo "Run did not reach cost estimation." >&2
    exit 1
  fi
  sleep "$POLL_INTERVAL_SECONDS"
done

if ((poll > MAX_POLLS)); then
  echo "Timed out waiting for run $run_id." >&2
  exit 1
fi

cost_estimate_id="$(jq -r '.data.relationships["cost-estimate"].data.id // empty' "$response_body")"
if [[ -z "$cost_estimate_id" ]]; then
  echo "Run reached cost_estimated without a cost-estimate relationship." >&2
  exit 1
fi

api_request GET "/cost-estimates/${cost_estimate_id}"
output_file="$(dirname "$0")/cost-estimate-${run_id}.json"
cp "$response_body" "$output_file"

echo "Saved cost-estimate response to $output_file"
jq '{id: .data.id, status: .data.attributes.status, attributes: .data.attributes}' "$output_file"
