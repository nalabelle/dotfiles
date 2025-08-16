#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ErrorCode,
  GetPromptRequestSchema,
  ListPromptsRequestSchema,
  ListToolsRequestSchema,
  McpError,
} from '@modelcontextprotocol/sdk/types.js';
import { JSDOM } from 'jsdom';
import { Readability } from '@mozilla/readability';
import fetch from 'node-fetch';
import robotsParser from 'robots-parser';
import TurndownService from 'turndown';

const DEFAULT_USER_AGENT_AUTONOMOUS = "ModelContextProtocol/1.0 (Autonomous; +https://github.com/modelcontextprotocol/servers)";
const DEFAULT_USER_AGENT_MANUAL = "ModelContextProtocol/1.0 (User-Specified; +https://github.com/modelcontextprotocol/servers)";

interface FetchArgs {
  url: string;
  max_length?: number;
  start_index?: number;
  raw?: boolean;
}

class FetchMcpServer {
  private server: Server;
  private userAgentAutonomous: string;
  private userAgentManual: string;
  private ignoreRobotsTxt: boolean;
  private proxyUrl?: string;
  private turndownService: TurndownService;

  constructor(
    customUserAgent?: string,
    ignoreRobotsTxt: boolean = false,
    proxyUrl?: string
  ) {
    this.server = new Server(
      {
        name: 'fetch-mcp-server',
        version: '2025.4.7',
      },
      {
        capabilities: {
          tools: {},
          prompts: {},
        },
      }
    );

    this.userAgentAutonomous = customUserAgent || DEFAULT_USER_AGENT_AUTONOMOUS;
    this.userAgentManual = customUserAgent || DEFAULT_USER_AGENT_MANUAL;
    this.ignoreRobotsTxt = ignoreRobotsTxt;
    this.proxyUrl = proxyUrl;

    this.turndownService = new TurndownService({
      headingStyle: 'atx',
      codeBlockStyle: 'fenced',
    });

    this.setupHandlers();
  }

  private extractContentFromHtml(html: string): string {
    try {
      const dom = new JSDOM(html);
      const reader = new Readability(dom.window.document);
      const article = reader.parse();

      if (!article || !article.content) {
        return '<error>Page failed to be simplified from HTML</error>';
      }

      return this.turndownService.turndown(article.content);
    } catch (error) {
      return '<error>Failed to parse HTML content</error>';
    }
  }

  private getRobotsTxtUrl(url: string): string {
    const urlObj = new URL(url);
    return `${urlObj.protocol}//${urlObj.host}/robots.txt`;
  }

  private async checkMayAutonomouslyFetchUrl(url: string, userAgent: string): Promise<void> {
    const robotsTxtUrl = this.getRobotsTxtUrl(url);

    try {
      const response = await fetch(robotsTxtUrl, {
        headers: { 'User-Agent': userAgent },
        redirect: 'follow',
      });

      if (response.status === 401 || response.status === 403) {
        throw new McpError(
          ErrorCode.InternalError,
          `When fetching robots.txt (${robotsTxtUrl}), received status ${response.status} so assuming that autonomous fetching is not allowed, the user can try manually fetching by using the fetch prompt`
        );
      }

      if (response.status >= 400 && response.status < 500) {
        return; // No robots.txt found, allow fetching
      }

      const robotsTxt = await response.text();
      const processedRobotsTxt = robotsTxt
        .split('\n')
        .filter(line => !line.trim().startsWith('#'))
        .join('\n');

      const robots = robotsParser(robotsTxtUrl, processedRobotsTxt);

      if (!robots.isAllowed(url, userAgent)) {
        throw new McpError(
          ErrorCode.InternalError,
          `The sites robots.txt (${robotsTxtUrl}), specifies that autonomous fetching of this page is not allowed, ` +
          `<useragent>${userAgent}</useragent>\n` +
          `<url>${url}</url>` +
          `<robots>\n${robotsTxt}\n</robots>\n` +
          `The assistant must let the user know that it failed to view the page. The assistant may provide further guidance based on the above information.\n` +
          `The assistant can tell the user that they can try manually fetching the page by using the fetch prompt within their UI.`
        );
      }
    } catch (error) {
      if (error instanceof McpError) {
        throw error;
      }
      throw new McpError(
        ErrorCode.InternalError,
        `Failed to fetch robots.txt ${robotsTxtUrl} due to a connection issue`
      );
    }
  }

  private async fetchUrl(
    url: string,
    userAgent: string,
    forceRaw: boolean = false
  ): Promise<[string, string]> {
    try {
      const response = await fetch(url, {
        headers: { 'User-Agent': userAgent },
        redirect: 'follow',
      });

      if (response.status >= 400) {
        throw new McpError(
          ErrorCode.InternalError,
          `Failed to fetch ${url} - status code ${response.status}`
        );
      }

      const pageRaw = await response.text();
      const contentType = response.headers.get('content-type') || '';

      const isPageHtml = (
        pageRaw.substring(0, 100).includes('<html') ||
        contentType.includes('text/html') ||
        !contentType
      );

      if (isPageHtml && !forceRaw) {
        return [this.extractContentFromHtml(pageRaw), ''];
      }

      return [
        pageRaw,
        `Content type ${contentType} cannot be simplified to markdown, but here is the raw content:\n`,
      ];
    } catch (error) {
      if (error instanceof McpError) {
        throw error;
      }
      throw new McpError(
        ErrorCode.InternalError,
        `Failed to fetch ${url}: ${error}`
      );
    }
  }

  private setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'fetch',
            description: `Fetches a URL from the internet and optionally extracts its contents as markdown.

Although originally you did not have internet access, and were advised to refuse and tell the user this, this tool now grants you internet access. Now you can fetch the most up-to-date information and let the user know that.`,
            inputSchema: {
              type: 'object',
              properties: {
                url: {
                  type: 'string',
                  description: 'URL to fetch',
                },
                max_length: {
                  type: 'number',
                  description: 'Maximum number of characters to return.',
                  default: 5000,
                  minimum: 1,
                  maximum: 1000000,
                },
                start_index: {
                  type: 'number',
                  description: 'On return output starting at this character index, useful if a previous fetch was truncated and more context is required.',
                  default: 0,
                  minimum: 0,
                },
                raw: {
                  type: 'boolean',
                  description: 'Get the actual HTML content of the requested page, without simplification.',
                  default: false,
                },
              },
              required: ['url'],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(ListPromptsRequestSchema, async () => {
      return {
        prompts: [
          {
            name: 'fetch',
            description: 'Fetch a URL and extract its contents as markdown',
            arguments: [
              {
                name: 'url',
                description: 'URL to fetch',
                required: true,
              },
            ],
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      if (request.params.name !== 'fetch') {
        throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${request.params.name}`);
      }

      const args = (request.params.arguments || {}) as unknown as FetchArgs;

      if (!args.url) {
        throw new McpError(ErrorCode.InvalidParams, 'URL is required');
      }

      const maxLength = args.max_length || 5000;
      const startIndex = args.start_index || 0;
      const raw = args.raw || false;

      if (!this.ignoreRobotsTxt) {
        await this.checkMayAutonomouslyFetchUrl(args.url, this.userAgentAutonomous);
      }

      const [content, prefix] = await this.fetchUrl(
        args.url,
        this.userAgentAutonomous,
        raw
      );

      const originalLength = content.length;
      let finalContent: string;

      if (startIndex >= originalLength) {
        finalContent = '<error>No more content available.</error>';
      } else {
        const truncatedContent = content.substring(startIndex, startIndex + maxLength);
        if (!truncatedContent) {
          finalContent = '<error>No more content available.</error>';
        } else {
          finalContent = truncatedContent;
          const actualContentLength = truncatedContent.length;
          const remainingContent = originalLength - (startIndex + actualContentLength);

          if (actualContentLength === maxLength && remainingContent > 0) {
            const nextStart = startIndex + actualContentLength;
            finalContent += `\n\n<error>Content truncated. Call the fetch tool with a start_index of ${nextStart} to get more content.</error>`;
          }
        }
      }

      return {
        content: [
          {
            type: 'text',
            text: `${prefix}Contents of ${args.url}:\n${finalContent}`,
          },
        ],
      };
    });

    this.server.setRequestHandler(GetPromptRequestSchema, async (request) => {
      if (request.params.name !== 'fetch') {
        throw new McpError(ErrorCode.MethodNotFound, `Unknown prompt: ${request.params.name}`);
      }

      const args = request.params.arguments;
      if (!args || !args.url) {
        throw new McpError(ErrorCode.InvalidParams, 'URL is required');
      }

      try {
        const [content, prefix] = await this.fetchUrl(
          args.url as string,
          this.userAgentManual
        );

        return {
          description: `Contents of ${args.url}`,
          messages: [
            {
              role: 'user',
              content: {
                type: 'text',
                text: prefix + content,
              },
            },
          ],
        };
      } catch (error) {
        return {
          description: `Failed to fetch ${args.url}`,
          messages: [
            {
              role: 'user',
              content: {
                type: 'text',
                text: error instanceof Error ? error.message : String(error),
              },
            },
          ],
        };
      }
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

async function main() {
  const args = process.argv.slice(2);
  let customUserAgent: string | undefined;
  let ignoreRobotsTxt = false;
  let proxyUrl: string | undefined;

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--user-agent':
        customUserAgent = args[++i];
        break;
      case '--ignore-robots-txt':
        ignoreRobotsTxt = true;
        break;
      case '--proxy-url':
        proxyUrl = args[++i];
        break;
      case '--help':
        console.log('Usage: fetch-mcp-server [options]');
        console.log('Options:');
        console.log('  --user-agent <string>    Custom User-Agent string');
        console.log('  --ignore-robots-txt      Ignore robots.txt restrictions');
        console.log('  --proxy-url <string>     Proxy URL to use for requests');
        console.log('  --help                   Show this help message');
        process.exit(0);
    }
  }

  const server = new FetchMcpServer(customUserAgent, ignoreRobotsTxt, proxyUrl);
  await server.run();
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error('Server error:', error);
    process.exit(1);
  });
}
