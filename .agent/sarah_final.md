Restarted systemd service: openclaw-gateway.service
Agents:
- main (default)
  Identity: ≡ƒñû Jack (IDENTITY.md)
  Workspace: ~/.openclaw/workspace
  Agent dir: ~/.openclaw/agents/main/agent
  Model: google-antigravity/claude-opus-4-6
  Routing rules: 0
  Routing: default (no explicit rules)
- sarah
  Workspace: ~/.openclaw/workspace-sarah
  Agent dir: ~/.openclaw/agents/sarah/agent
  Model: google-antigravity/claude-opus-4-6
  Routing rules: 1
  Routing rules:
    - telegram accountId=sarah
- john
  Workspace: ~/openclaw-clients/john/data/.openclaw
  Agent dir: ~/openclaw-clients/john/data/.openclaw/agents/main/agent
  Model: anthropic/claude-sonnet-4-5
  Routing rules: 0
- ross
  Workspace: ~/openclaw-clients/ross/workspace
  Agent dir: ~/openclaw-clients/ross/workspace/agents/main/agent
  Model: anthropic/claude-opus-4-6
  Routing rules: 0
Routing rules map channel/account/peer to an agent. Use --bindings for full rules.
Channel status reflects local config/creds. For live health: openclaw channels status --probe.
