import { defineConfig } from "vite";
import Erb from "vite-plugin-erb";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue";
import legacy from "@vitejs/plugin-legacy";

export default defineConfig({
  plugins: [
    Erb(),
    RubyPlugin(),
    vue(),
    legacy(),
  ],
})
