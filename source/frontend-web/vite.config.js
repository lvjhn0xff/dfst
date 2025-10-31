import { defineConfig } from 'vite'

export default defineConfig({
  server: {
    allowedHosts: [ ".lan", ".com", ".internal" ]
  }
})
