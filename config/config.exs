import Config

target = System.get_env("BLOG20Y_TARGET", Path.expand("public"))

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=assets/css/app.css
      --output=#{target <> "/assets/app.css"}
    )
  ]

config :blog_20y,
  site_url:
    (case Mix.env() do
       :prod -> "https://20y.hu/~slink"
       :dev -> target
     end),
  files_url: "https://20y.hu",
  title: "20Y",
  rss_post_limit: 20,
  output_dir: target
