const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const DOCS_BASE_URL = 'https://docs.openclaw.ai';
const OUTPUT_DIR = path.resolve('/Users/coachsharm/Code/Jack/OpenClaw_Docs');
const LAST_UPDATED_FILE = path.join(OUTPUT_DIR, 'LAST_UPDATED.txt');

// Ensure output directory exists
if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    console.log(`Created directory: ${OUTPUT_DIR}`);
}

// Comprehensive list of all OpenClaw documentation pages
const PAGES = [
    // Getting Started
    '/getting-started',
    '/start/getting-started',
    '/start/wizard',
    '/start/setup',
    '/start/pairing',
    '/start/openclaw',
    '/start/showcase',
    '/start/hubs',
    '/start/onboarding',
    '/start/lore',

    // Help & Troubleshooting
    '/help',
    '/help/troubleshooting',
    '/help/faq',

    // Installation
    '/install',
    '/install/installer',
    '/install/updating',
    '/install/development-channels',
    '/install/uninstall',
    '/install/ansible',
    '/install/nix',
    '/install/docker',
    '/install/bun',
    '/railway',
    '/render',
    '/northflank',

    // CLI Commands
    '/cli',
    '/cli/setup',
    '/cli/onboard',
    '/cli/configure',
    '/cli/doctor',
    '/cli/dashboard',
    '/cli/reset',
    '/cli/uninstall',
    '/cli/browser',
    '/cli/message',
    '/cli/agent',
    '/cli/agents',
    '/cli/status',
    '/cli/health',
    '/cli/sessions',
    '/cli/channels',
    '/cli/directory',
    '/cli/skills',
    '/cli/plugins',
    '/cli/memory',
    '/cli/models',
    '/cli/logs',
    '/cli/system',
    '/cli/nodes',
    '/cli/approvals',
    '/cli/gateway',
    '/cli/tui',
    '/cli/voicecall',
    '/cli/cron',
    '/cli/dns',
    '/cli/docs',
    '/cli/hooks',
    '/cli/pairing',
    '/cli/security',
    '/cli/update',
    '/cli/sandbox',

    // Core Concepts
    '/concepts/architecture',
    '/concepts/agent',
    '/concepts/agent-loop',
    '/concepts/system-prompt',
    '/concepts/context',
    '/token-use',
    '/concepts/oauth',
    '/concepts/agent-workspace',
    '/concepts/memory',
    '/concepts/multi-agent',
    '/concepts/compaction',
    '/concepts/session',
    '/concepts/session-pruning',
    '/concepts/sessions',
    '/concepts/session-tool',
    '/concepts/presence',
    '/concepts/channel-routing',
    '/concepts/messages',
    '/concepts/streaming',
    '/concepts/markdown-formatting',
    '/concepts/groups',
    '/concepts/group-messages',
    '/concepts/typing-indicators',
    '/concepts/queue',
    '/concepts/retry',
    '/concepts/model-providers',
    '/concepts/models',
    '/concepts/model-failover',
    '/concepts/usage-tracking',
    '/concepts/timezone',
    '/concepts/typebox',

    // Gateway
    '/gateway',
    '/gateway/configuration',
    '/gateway/configuration-examples',
    '/gateway/discovery',
    '/gateway/remote',
    '/gateway/security',
    '/gateway/troubleshooting',

    // Channels
    '/channels/telegram',
    '/channels/discord',
    '/channels/mattermost',
    '/channels/imessage',
    '/channels/whatsapp',
    '/channels/slack',
    '/channels/signal',

    // Platforms
    '/platforms/macos',
    '/platforms/ios',
    '/platforms/android',
    '/platforms/windows',
    '/platforms/linux',

    // Web & Control UI
    '/web',
    '/web/webchat',
    '/web/control-ui',

    // Nodes
    '/nodes',
    '/nodes/images',
    '/nodes/audio',

    // Tools & Skills
    '/tools/skills',
    '/tools/skills-config',
    '/tools/slash-commands',

    // Automation
    '/automation/cron-jobs',
    '/automation/webhook',
    '/automation/gmail-pubsub',

    // Reference
    '/reference/templates/AGENTS',
    '/reference/rpc'
];

async function installDependencies() {
    try {
        require.resolve('cheerio');
        require.resolve('turndown');
        require.resolve('node-fetch');
    } catch (e) {
        console.log('Installing dependencies...');
        execSync('npm install cheerio turndown node-fetch', { cwd: __dirname, stdio: 'inherit' });
    }
}

async function syncDocs() {
    await installDependencies();

    const fetch = (await import('node-fetch')).default;
    const cheerio = require('cheerio');
    const TurndownService = require('turndown');
    const turndownService = new TurndownService();

    console.log(`Starting sync from ${DOCS_BASE_URL}...`);

    for (const page of PAGES) {
        const url = `${DOCS_BASE_URL}${page}`;
        try {
            console.log(`Fetching ${url}...`);
            const response = await fetch(url);
            if (!response.ok) {
                console.warn(`Failed to fetch ${url}: ${response.statusText}`);
                continue;
            }
            const html = await response.text();
            const $ = cheerio.load(html);

            // Extract main content
            // Assuming standard Docusaurus/Nextra structure, often main content is in 'main' or 'article'
            const content = $('main').html() || $('article').html() || $('body').html();

            if (content) {
                const markdown = turndownService.turndown(content);
                const filename = page.replace(/\//g, '_').replace(/^_/, '') + '.md';
                const filePath = path.join(OUTPUT_DIR, filename);

                fs.writeFileSync(filePath, markdown);
                console.log(`Saved ${filename}`);
            } else {
                console.warn(`No content found for ${url}`);
            }

        } catch (error) {
            console.error(`Error processing ${url}:`, error.message);
        }
    }

    const timestamp = new Date().toISOString();
    const readmeContent = `# OpenClaw Documentation Reference

This directory contains the official OpenClaw documentation, synced from [docs.openclaw.ai](https://docs.openclaw.ai).

**DO NOT EDIT MANUALLY.** This folder is synchronized using the \`sync-docs\` skill.

## Status
- **Source**: ${DOCS_BASE_URL}
- **Last Updated**: ${timestamp}
`;

    fs.writeFileSync(LAST_UPDATED_FILE, `Last updated: ${timestamp}\nSource: ${DOCS_BASE_URL}\n`);
    fs.writeFileSync(path.join(OUTPUT_DIR, 'README.md'), readmeContent);
    console.log(`Sync complete. Timestamp and README updated.`);
}

syncDocs().catch(console.error);
