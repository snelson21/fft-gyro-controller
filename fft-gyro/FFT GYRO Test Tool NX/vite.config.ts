// vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    // Remove this input override entirely
    // Vite will default to using `index.html` in the root
    outDir: 'dist',
    emptyOutDir: true,
  }
});
