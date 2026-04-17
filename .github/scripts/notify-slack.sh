#!/usr/bin/env bash
# notify-slack.sh — Slack notifications for HyBid demo app update workflows.
# Deploy this file to: .github/scripts/notify-slack.sh in the demo repo.
#
# Required env vars (set in the workflow step):
#   SLACK_BOT_TOKEN            xoxb-... bot token
#   SLACK_IOS_RELEASES_CHANNEL channel ID (e.g. C0123456789)
#   STATUS                     "success" or "failure"
#   DEMO_TITLE                 e.g. "HyBid Standalone Demo"
#
# Picked up automatically from the job-level env:
#   HYBID_VERSION, ADAPTER_VERSION  (whichever apply to this demo)
#   PR_URL                          (written to GITHUB_ENV by the commit step)
#
# BUILD_URL is computed automatically from GHA built-in env vars.

set -euo pipefail

if [ -z "${SLACK_BOT_TOKEN:-}" ] || [ -z "${SLACK_IOS_RELEASES_CHANNEL:-}" ]; then
  echo "⚠️  Missing SLACK_BOT_TOKEN or SLACK_IOS_RELEASES_CHANNEL — skipping."
  exit 0
fi

PAYLOAD=$(python3 - <<'PYEOF'
import json, os

status  = os.environ.get('STATUS', 'success')
title   = os.environ['DEMO_TITLE']
channel = os.environ['SLACK_IOS_RELEASES_CHANNEL']

# Build URL from GHA built-ins (always available inside a workflow step)
server  = os.environ.get('GITHUB_SERVER_URL', 'https://github.com')
repo    = os.environ.get('GITHUB_REPOSITORY', '')
run_id  = os.environ.get('GITHUB_RUN_ID', '')
build   = f"{server}/{repo}/actions/runs/{run_id}"

adapter = os.environ.get('ADAPTER_VERSION', '').strip()
hybid   = os.environ.get('HYBID_VERSION',   '').strip()
pr_url  = os.environ.get('PR_URL',          '').strip()

# Primary version label for the notification text
version = adapter or hybid or 'unknown'
pr_link = pr_url or build

# ── Fields ───────────────────────────────────────────────────────────────────
fields = []
if adapter:
    fields.append({'type': 'mrkdwn', 'text': f'*Adapter Version:*\n{adapter}'})
if hybid:
    fields.append({'type': 'mrkdwn', 'text': f'*HyBid SDK:*\n{hybid}'})
if not adapter and not hybid:
    fields.append({'type': 'mrkdwn', 'text': f'*Version:*\n{version}'})

# ── Footer block ─────────────────────────────────────────────────────────────
footer = {
    'type': 'context',
    'elements': [{'type': 'mrkdwn', 'text': 'Generated automatically by GitHub Actions 🚀'}],
}

# ── Payload ──────────────────────────────────────────────────────────────────
if status == 'failure':
    fields.append({'type': 'mrkdwn', 'text': f'*GHA Run:*\n<{build}|View run>'})
    payload = {
        'channel': channel,
        'text': f'❌ {title} update FAILED — v{version}',
        'attachments': [{
            'color': '#E01E5A',
            'blocks': [
                {'type': 'header',
                 'text': {'type': 'plain_text', 'text': f'❌ {title} Update FAILED'}},
                {'type': 'section', 'fields': fields},
                {'type': 'section',
                 'text': {'type': 'mrkdwn',
                          'text': '*Failure context:*\nFailed to update dependencies or open PR. '
                                  'Check the GHA run for details.'}},
                footer,
            ],
        }],
    }
else:
    fields.append({'type': 'mrkdwn', 'text': f'*PR:*\n<{pr_link}|View PR>'})
    fields.append({'type': 'mrkdwn', 'text': f'*GHA Run:*\n<{build}|View run>'})
    payload = {
        'channel': channel,
        'text': f'📱 {title} — PR opened for v{version}',
        'attachments': [{
            'color': '#2EB67D',
            'blocks': [
                {'type': 'header',
                 'text': {'type': 'plain_text', 'text': f'📱 {title} Update'}},
                {'type': 'section', 'fields': fields},
                footer,
            ],
        }],
    }

print(json.dumps(payload))
PYEOF
)

resp=$(printf '%s' "$PAYLOAD" | curl -sS -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data @-)

if command -v jq &>/dev/null; then
  ok=$(echo "$resp" | jq -r '.ok' 2>/dev/null || echo "parse_error")
  [ "$ok" = "true" ] || { echo "❌ Slack failed: $(echo "$resp" | jq -r '.error // empty')"; echo "$resp"; exit 1; }
else
  echo "$resp" | grep -qE '"ok"[[:space:]]*:[[:space:]]*true' \
    || { echo "❌ Slack failed"; echo "$resp"; exit 1; }
fi
echo "✅ Slack notification sent"
