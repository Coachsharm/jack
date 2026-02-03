const fs = require('fs');
const path = require('path');

// Configuration
const BLOG_URL = 'https://openclaw.ai/blog/introducing-openclaw';
const OUTPUT_DIR = path.resolve('C:/Users/hisha/Code/Jack/OpenClaw_Docs/blog');

// Ensure output directory exists
if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    console.log(`Created directory: ${OUTPUT_DIR}`);
}

async function syncBlog() {
    const fetch = (await import('node-fetch')).default;
    const cheerio = require('cheerio');
    const TurndownService = require('turndown');
    const turndownService = new TurndownService();

    console.log(`Fetching blog post: ${BLOG_URL}...`);

    try {
        const response = await fetch(BLOG_URL);
        if (!response.ok) {
            console.warn(`Failed to fetch ${BLOG_URL}: ${response.statusText}`);
            return;
        }

        const html = await response.text();
        const $ = cheerio.load(html);

        // Extract main content
        const content = $('main').html() || $('article').html() || $('body').html();

        if (content) {
            const markdown = turndownService.turndown(content);
            const filePath = path.join(OUTPUT_DIR, 'introducing-openclaw.md');

            fs.writeFileSync(filePath, markdown);
            console.log(`Saved blog post: introducing-openclaw.md`);
        } else {
            console.warn(`No content found for ${BLOG_URL}`);
        }

    } catch (error) {
        console.error(`Error processing blog:`, error.message);
    }
}

syncBlog().catch(console.error);
