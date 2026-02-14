{
  "ok": true,
  "ts": 1771055231776,
  "durationMs": 1000,
  "channels": {
    "telegram": {
      "configured": true,
      "tokenSource": "none",
      "running": false,
      "mode": null,
      "lastStartAt": null,
      "lastStopAt": null,
      "lastError": null,
      "probe": {
        "ok": true,
        "status": null,
        "error": null,
        "elapsedMs": 667,
        "bot": {
          "id": 8023616765,
          "username": "thrive2bot",
          "canJoinGroups": true,
          "canReadAllGroupMessages": true,
          "supportsInlineQueries": true
        },
        "webhook": {
          "url": "",
          "hasCustomCert": false
        }
      },
      "lastProbeAt": 1771055231443,
      "accountId": "default",
      "accounts": {
        "default": {
          "configured": true,
          "tokenSource": "none",
          "running": false,
          "mode": null,
          "lastStartAt": null,
          "lastStopAt": null,
          "lastError": null,
          "probe": {
            "ok": true,
            "status": null,
            "error": null,
            "elapsedMs": 667,
            "bot": {
              "id": 8023616765,
              "username": "thrive2bot",
              "canJoinGroups": true,
              "canReadAllGroupMessages": true,
              "supportsInlineQueries": true
            },
            "webhook": {
              "url": "",
              "hasCustomCert": false
            }
          },
          "lastProbeAt": 1771055231443,
          "accountId": "default"
        },
        "sarah": {
          "configured": true,
          "tokenSource": "none",
          "running": false,
          "mode": null,
          "lastStartAt": null,
          "lastStopAt": null,
          "lastError": null,
          "probe": {
            "ok": true,
            "status": null,
            "error": null,
            "elapsedMs": 333,
            "bot": {
              "id": 8326665388,
              "username": "thrive5bot",
              "canJoinGroups": true,
              "canReadAllGroupMessages": false,
              "supportsInlineQueries": false
            },
            "webhook": {
              "url": "",
              "hasCustomCert": false
            }
          },
          "lastProbeAt": 1771055231776,
          "accountId": "sarah"
        }
      }
    }
  },
  "channelOrder": [
    "telegram"
  ],
  "channelLabels": {
    "telegram": "Telegram"
  },
  "heartbeatSeconds": 1800,
  "defaultAgentId": "main",
  "agents": [
    {
      "agentId": "main",
      "isDefault": true,
      "heartbeat": {
        "enabled": true,
        "every": "30m",
        "everyMs": 1800000,
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.",
        "target": "last",
        "ackMaxChars": 300
      },
      "sessions": {
        "path": "/root/.openclaw/agents/main/sessions/sessions.json",
        "count": 1,
        "recent": [
          {
            "key": "agent:main:main",
            "updatedAt": 1771055226544,
            "age": 4230
          }
        ]
      }
    },
    {
      "agentId": "sarah",
      "name": "sarah",
      "isDefault": false,
      "heartbeat": {
        "enabled": false,
        "every": "disabled",
        "everyMs": null,
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.",
        "target": "last",
        "ackMaxChars": 300
      },
      "sessions": {
        "path": "/root/.openclaw/agents/sarah/sessions/sessions.json",
        "count": 1,
        "recent": [
          {
            "key": "agent:sarah:main",
            "updatedAt": 1771026473636,
            "age": 28757140
          }
        ]
      }
    },
    {
      "agentId": "john",
      "name": "john",
      "isDefault": false,
      "heartbeat": {
        "enabled": false,
        "every": "disabled",
        "everyMs": null,
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.",
        "target": "last",
        "ackMaxChars": 300
      },
      "sessions": {
        "path": "/root/.openclaw/agents/john/sessions/sessions.json",
        "count": 0,
        "recent": []
      }
    },
    {
      "agentId": "ross",
      "name": "ross",
      "isDefault": false,
      "heartbeat": {
        "enabled": false,
        "every": "disabled",
        "everyMs": null,
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.",
        "target": "last",
        "ackMaxChars": 300
      },
      "sessions": {
        "path": "/root/.openclaw/agents/ross/sessions/sessions.json",
        "count": 0,
        "recent": []
      }
    }
  ],
  "sessions": {
    "path": "/root/.openclaw/agents/main/sessions/sessions.json",
    "count": 1,
    "recent": [
      {
        "key": "agent:main:main",
        "updatedAt": 1771055226544,
        "age": 4230
      }
    ]
  }
}
