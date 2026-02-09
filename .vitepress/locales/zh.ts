import type { DefaultTheme, LocaleSpecificConfig } from 'vitepress'

export const zhConfig: LocaleSpecificConfig<DefaultTheme.Config> = {
  title: 'Code80 文档',
  description: 'Code80 AI API 网关平台文档',
  themeConfig: {
    nav: [
      { text: 'Claude Code', link: '/zh/claudecode/' },
      { text: 'Codex CLI', link: '/zh/codex/' },
      { text: 'Gemini CLI', link: '/zh/gemini/' },
      {
        text: '使用指南',
        items: [
          { text: 'API Key 管理', link: '/zh/guide/api-keys' },
          { text: '计费与订阅', link: '/zh/guide/billing' },
          { text: '工具功能对比', link: '/zh/guide/comparison' },
          { text: '常见问题', link: '/zh/guide/faq' }
        ]
      },
      {
        text: '关于',
        items: [
          { text: '服务条款', link: '/zh/guide/terms' },
          { text: '隐私政策', link: '/zh/guide/privacy' }
        ]
      }
    ],
    sidebar: {
      '/zh/claudecode/': [
        {
          text: 'Claude Code',
          items: [
            { text: '概述与快速开始', link: '/zh/claudecode/' },
            { text: '安装详解', link: '/zh/claudecode/install' },
            { text: '配置详解', link: '/zh/claudecode/config' },
            { text: '使用技巧', link: '/zh/claudecode/tips' },
            { text: '常见问题', link: '/zh/claudecode/faq' }
          ]
        },
        {
          text: '其他工具',
          items: [
            { text: 'Codex CLI', link: '/zh/codex/' },
            { text: 'Gemini CLI', link: '/zh/gemini/' }
          ]
        }
      ],
      '/zh/codex/': [
        {
          text: 'Codex CLI',
          items: [
            { text: '概述与快速开始', link: '/zh/codex/' },
            { text: '安装详解', link: '/zh/codex/install' },
            { text: '配置详解', link: '/zh/codex/config' },
            { text: '使用技巧', link: '/zh/codex/tips' },
            { text: '常见问题', link: '/zh/codex/faq' }
          ]
        },
        {
          text: '其他工具',
          items: [
            { text: 'Claude Code', link: '/zh/claudecode/' },
            { text: 'Gemini CLI', link: '/zh/gemini/' }
          ]
        }
      ],
      '/zh/gemini/': [
        {
          text: 'Gemini CLI',
          items: [
            { text: '概述与快速开始', link: '/zh/gemini/' },
            { text: '安装详解', link: '/zh/gemini/install' },
            { text: '配置详解', link: '/zh/gemini/config' },
            { text: '使用技巧', link: '/zh/gemini/tips' },
            { text: '常见问题', link: '/zh/gemini/faq' }
          ]
        },
        {
          text: '其他工具',
          items: [
            { text: 'Claude Code', link: '/zh/claudecode/' },
            { text: 'Codex CLI', link: '/zh/codex/' }
          ]
        }
      ],
      '/zh/guide/': [
        {
          text: '使用指南',
          items: [
            { text: 'API Key 管理', link: '/zh/guide/api-keys' },
            { text: '计费与订阅', link: '/zh/guide/billing' },
            { text: '工具功能对比', link: '/zh/guide/comparison' },
            { text: '常见问题', link: '/zh/guide/faq' }
          ]
        },
        {
          text: '关于',
          items: [
            { text: '服务条款', link: '/zh/guide/terms' },
            { text: '隐私政策', link: '/zh/guide/privacy' }
          ]
        }
      ]
    },
    outline: { label: '页面导航' },
    lastUpdated: { text: '最后更新于' },
    docFooter: { prev: '上一页', next: '下一页' },
    editLink: {
      pattern: 'https://github.com/yiancode/code80-docs/edit/main/:path',
      text: '在 GitHub 上编辑此页'
    }
  }
}
