import shopify from "vite-plugin-shopify";

export default {
  plugins: [
    shopify({
      themeRoot: "./", // default true but testing purposes
      sourceCodeDir: "ui",
      entrypointsDir: "ui/entrypoints" // non exist and ui name not fit well but it's easier to type looks cleaner
    })
  ]
}
