import Config

output_dir = System.get_env("BLOG20Y_OUTPUT_DIR", Path.expand("public"))
site_url = System.get_env("BLOG20Y_SITE_URL")

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=assets/css/app.css
      --output=#{output_dir <> "/assets/app.css"}
    )
  ]

config :blog_20y,
  site_url:
    (case Mix.env() do
       :prod -> "https://20y.hu/~slink"
       :dev -> site_url
     end),
  files_url: "https://20y.hu",
  title: "20Y",
  default_lang: "en",
  rss_post_limit: 20,
  output_dir: output_dir

