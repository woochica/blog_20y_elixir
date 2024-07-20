import Config

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../public/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :blog_20y,
  site_url: "file:///home/slink/slinkdrive/gabor/Documents-current/blog_20y/public",
  files_url: "https://20y.hu",
  title: "20Y",
  rss_post_limit: 20,
  output_dir: "./public"
