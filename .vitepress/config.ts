import { defineConfig } from 'vitepress'
import { zhConfig } from './locales/zh'
import { enConfig } from './locales/en'

export default defineConfig({
  title: 'Code80',
  description: 'Code80 Documentation',
  cleanUrls: true,
  lastUpdated: true,

  head: [
    ['link', { rel: 'icon', href: '/logo.png', type: 'image/png' }]
  ],

  locales: {
    zh: {
      label: '简体中文',
      lang: 'zh-CN',
      link: '/zh/',
      ...zhConfig
    },
    en: {
      label: 'English',
      lang: 'en-US',
      link: '/en/',
      ...enConfig
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
