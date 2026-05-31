import { defineConfig } from 'vitepress'

const site = 'https://docs.ai80.vip'
const ogImage = `${site}/logo.png`

export default defineConfig({
  title: 'Code80',
  titleTemplate: ':title - Code80 AI编程巴士',
  description: 'Code80 AI编程巴士 - Claude Code、Codex CLI、Gemini CLI 配置教程、使用技巧与插件玩法',
  cleanUrls: true,
  lastUpdated: true,
  lang: 'zh-CN',

  sitemap: {
    hostname: site
  },

  head: [
    ['link', { rel: 'icon', href: '/logo.png', type: 'image/png' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'Code80 AI编程巴士' }],
    ['meta', { property: 'og:image', content: ogImage }],
    ['meta', { property: 'og:locale', content: 'zh_CN' }],
    ['meta', { name: 'twitter:card', content: 'summary' }],
    ['meta', { name: 'twitter:image', content: ogImage }],
    ['meta', { name: 'keywords', content: 'Code80,AI编程巴士,Claude Code,Codex CLI,Gemini CLI,AI编程助手,API网关,AI编程工具配置' }]
  ],

  themeConfig: {
    logo: '/logo.png',
    nav: [
      { text: 'Claude Code', link: '/claudecode/' },
      { text: 'Codex CLI', link: '/codex/' },
      { text: 'Gemini CLI', link: '/gemini/' },
      {
        text: '使用指南',
        items: [
          { text: 'API Key 管理', link: '/guide/api-keys' },
          { text: '计费与订阅', link: '/guide/billing' },
          { text: 'OpenClaw 接入', link: '/guide/openclaw' },
          { text: 'GPT Image 生图接入', link: '/guide/gpt-image' },
          { text: 'OpenAI 接口对齐', link: '/guide/openai-compat' },
          { text: 'CLI 快捷键总览', link: '/guide/cli-shortcuts' },
          { text: '工具功能对比', link: '/guide/comparison' },
          { text: '企业接入说明', link: '/guide/enterprise' },
          { text: '常见问题', link: '/guide/faq' }
        ]
      },
      {
        text: '关于',
        items: [
          { text: '服务条款', link: '/guide/terms' },
          { text: '隐私政策', link: '/guide/privacy' }
        ]
      }
    ],
    sidebar: {
      '/claudecode/': [
        {
          text: 'Claude Code',
          items: [
            { text: '概述与快速开始', link: '/claudecode/' },
            { text: '安装详解', link: '/claudecode/install' },
            { text: '配置详解', link: '/claudecode/config' },
            { text: '快捷键速查', link: '/claudecode/shortcuts' },
            { text: '使用技巧', link: '/claudecode/tips' },
            { text: '常见问题', link: '/claudecode/faq' }
          ]
        },
        {
          text: '其他工具',
          items: [
            { text: 'Codex CLI', link: '/codex/' },
            { text: 'Gemini CLI', link: '/gemini/' }
          ]
        }
      ],
      '/codex/': [
        {
          text: 'Codex CLI',
          items: [
            { text: '概述与快速开始', link: '/codex/' },
            { text: '安装详解', link: '/codex/install' },
            { text: '配置详解', link: '/codex/config' },
            { text: '快捷键速查', link: '/codex/shortcuts' },
            { text: '使用技巧', link: '/codex/tips' },
            { text: '常见问题', link: '/codex/faq' }
          ]
        },
        {
          text: '其他工具',
          items: [
            { text: 'Claude Code', link: '/claudecode/' },
            { text: 'Gemini CLI', link: '/gemini/' }
          ]
        }
      ],
      '/gemini/': [
        {
          text: 'Gemini CLI',
          items: [
            { text: '概述与快速开始', link: '/gemini/' },
            { text: '安装详解', link: '/gemini/install' },
            { text: '配置详解', link: '/gemini/config' },
            { text: '快捷键速查', link: '/gemini/shortcuts' },
            { text: '使用技巧', link: '/gemini/tips' },
            { text: '常见问题', link: '/gemini/faq' }
          ]
        },
        {
          text: '其他工具',
          items: [
            { text: 'Claude Code', link: '/claudecode/' },
            { text: 'Codex CLI', link: '/codex/' }
          ]
        }
      ],
      '/guide/': [
        {
          text: '使用指南',
          items: [
            { text: 'API Key 管理', link: '/guide/api-keys' },
            { text: '计费与订阅', link: '/guide/billing' },
            { text: 'OpenClaw 接入', link: '/guide/openclaw' },
            { text: 'GPT Image 生图接入', link: '/guide/gpt-image' },
            { text: 'OpenAI 接口对齐', link: '/guide/openai-compat' },
            { text: 'CLI 快捷键总览', link: '/guide/cli-shortcuts' },
            { text: '工具功能对比', link: '/guide/comparison' },
            { text: '企业接入说明', link: '/guide/enterprise' },
            { text: '常见问题', link: '/guide/faq' }
          ]
        },
        {
          text: '关于',
          items: [
            { text: '服务条款', link: '/guide/terms' },
            { text: '隐私政策', link: '/guide/privacy' }
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
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/yiancode/code80-docs' }
    ],
    search: {
      provider: 'local'
    }
  }
})
