import type { DefaultTheme, LocaleSpecificConfig } from 'vitepress'

export const enConfig: LocaleSpecificConfig<DefaultTheme.Config> = {
  title: 'Code80 Docs',
  description: 'Code80 AI API Gateway Documentation',
  themeConfig: {
    nav: [
      { text: 'Claude Code', link: '/en/claudecode/' },
      { text: 'Codex CLI', link: '/en/codex/' },
      { text: 'Gemini CLI', link: '/en/gemini/' },
      {
        text: 'Guide',
        items: [
          { text: 'API Key Management', link: '/en/guide/api-keys' },
          { text: 'Billing & Subscriptions', link: '/en/guide/billing' },
          { text: 'Tool Comparison', link: '/en/guide/comparison' },
          { text: 'FAQ', link: '/en/guide/faq' }
        ]
      },
      {
        text: 'About',
        items: [
          { text: 'Terms of Service', link: '/en/guide/terms' },
          { text: 'Privacy Policy', link: '/en/guide/privacy' }
        ]
      }
    ],
    sidebar: {
      '/en/claudecode/': [
        {
          text: 'Claude Code',
          items: [
            { text: 'Overview & Quick Start', link: '/en/claudecode/' },
            { text: 'Installation', link: '/en/claudecode/install' },
            { text: 'Configuration', link: '/en/claudecode/config' },
            { text: 'Tips & Tricks', link: '/en/claudecode/tips' },
            { text: 'FAQ', link: '/en/claudecode/faq' }
          ]
        },
        {
          text: 'Other Tools',
          items: [
            { text: 'Codex CLI', link: '/en/codex/' },
            { text: 'Gemini CLI', link: '/en/gemini/' }
          ]
        }
      ],
      '/en/codex/': [
        {
          text: 'Codex CLI',
          items: [
            { text: 'Overview & Quick Start', link: '/en/codex/' },
            { text: 'Installation', link: '/en/codex/install' },
            { text: 'Configuration', link: '/en/codex/config' },
            { text: 'Tips & Tricks', link: '/en/codex/tips' },
            { text: 'FAQ', link: '/en/codex/faq' }
          ]
        },
        {
          text: 'Other Tools',
          items: [
            { text: 'Claude Code', link: '/en/claudecode/' },
            { text: 'Gemini CLI', link: '/en/gemini/' }
          ]
        }
      ],
      '/en/gemini/': [
        {
          text: 'Gemini CLI',
          items: [
            { text: 'Overview & Quick Start', link: '/en/gemini/' },
            { text: 'Installation', link: '/en/gemini/install' },
            { text: 'Configuration', link: '/en/gemini/config' },
            { text: 'Tips & Tricks', link: '/en/gemini/tips' },
            { text: 'FAQ', link: '/en/gemini/faq' }
          ]
        },
        {
          text: 'Other Tools',
          items: [
            { text: 'Claude Code', link: '/en/claudecode/' },
            { text: 'Codex CLI', link: '/en/codex/' }
          ]
        }
      ],
      '/en/guide/': [
        {
          text: 'Guide',
          items: [
            { text: 'API Key Management', link: '/en/guide/api-keys' },
            { text: 'Billing & Subscriptions', link: '/en/guide/billing' },
            { text: 'Tool Comparison', link: '/en/guide/comparison' },
            { text: 'FAQ', link: '/en/guide/faq' }
          ]
        },
        {
          text: 'About',
          items: [
            { text: 'Terms of Service', link: '/en/guide/terms' },
            { text: 'Privacy Policy', link: '/en/guide/privacy' }
          ]
        }
      ]
    },
    editLink: {
      pattern: 'https://github.com/yiancode/code80-docs/edit/main/:path',
      text: 'Edit this page on GitHub'
    }
  }
}
