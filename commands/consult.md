---
description: Get second opinions from other AI models on the current work
---

Consult other AI models to stress-test your current work. You are the
orchestrator and synthesizer — other models are consultants, not peers.

## Setup

Requires Codespace secrets: `LITELLM_BASE` (proxy URL) and `LITELLM_KEY`.
If secrets are missing, tell the user and stop.

**Note:** `LITELLM_KEY` already includes the `sk-` prefix — do NOT double it
(use `$LITELLM_KEY` directly, not `sk-$LITELLM_KEY`).

## Model Discovery

Query `$LITELLM_BASE/v1/models` to see what's available. The proxy key
controls which models are visible — only accessible models will be returned.

From the available models, pick by role based on the task:
- **Chat** (plan/design critique): a strong general-purpose chat model
- **Reasoning** (deep analysis): a reasoning/thinking model if available
- **Codex** (code review): a codex model if available — these use the
  `/v1/responses` endpoint with `input` and `max_output_tokens` params,
  not `/v1/chat/completions`

Exclude models that are clearly non-text (image, audio, embed, realtime,
tts, whisper, moderation, dall-e, sora). Prefer the latest version when
multiple candidates exist. When unsure, just pick the most capable-looking
model available.

Set `max_tokens` >= 8192 for reasoning models to avoid empty responses.

**Practical note:** Model discovery responses can be large. Save to a
temp file before parsing to avoid truncation:
```bash
curl -s -H "Authorization: Bearer $LITELLM_KEY" \
  "$LITELLM_BASE/v1/models" -o /tmp/models.json
```

## Model Validation

After selecting models, **validate each one before framing the prompt**.
Send a cheap probe request (e.g., `"Say OK"`) to each selected model
using its correct endpoint and format. Check for a 200 response with
non-empty content.

- **Chat/Reasoning models**: POST to `/v1/chat/completions` with
  `max_tokens: 16` and message `"Say OK"`
- **Codex models**: POST to `/v1/responses` with `max_output_tokens: 64`
  and input `"Say OK"`

If a model fails validation:
1. Drop it and look for an alternative in the same role from the
   discovered model list (e.g., if `codex-mini-latest` fails, try
   `gpt-5.2-codex` or another codex variant)
2. If no alternative works for that role, skip the role entirely
3. Report which models passed/failed before proceeding
4. Require at least ONE model to pass validation before continuing

This avoids wasting time framing context and waiting on long calls
that will fail.

## Process

If `$ARGUMENTS` is provided, use it as the user's instruction for what
to consult on. Otherwise default to critiquing the current discussion.

1. **Frame**: Summarize the current discussion into a self-contained
   prompt. Other models have NO codebase access — include enough context
   but translate project-specific details to generic terms.
   **Never include API keys, credentials, tokens, or passwords in the
   framed prompt.** Code and diffs are fine — secrets are not.
2. **Call**: Send to selected models in parallel. Use `jq -n` for JSON safety.
3. **Synthesize**: Present each response, then YOUR synthesis that
   evaluates advice against what you know about this codebase. Filter
   out suggestions that don't apply. Recommend next steps.
4. **Offer**: Ask if user wants to act on findings, go deeper, or
   run another round.

## Error Handling

If a model call fails (non-200 status, timeout, malformed JSON):
- Show the error briefly, do NOT retry the same call
- Continue with responses from models that succeeded
- If ALL calls fail, report the errors and suggest the user check
  VPN connectivity and proxy status
