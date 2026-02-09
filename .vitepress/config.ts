import { defineConfig } from 'vitepress'
import { zhConfig } from './locales/zh'

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

  locales: {
    zh: {
      label: '简体中文',
      lang: 'zh-CN',
      link: '/zh/',
      ...zhConfig
    }
  },

  themeConfig: {
    logo: '/logo.png',
    socialLinks: [
      { icon: 'github', link: 'https://github.com/yiancode/code80-docs' }
    ],
    search: {
      provider: 'local'
    }
  }
})
