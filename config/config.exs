import Config

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=#{System.get_env("BLOG20Y_TARGET") <> "/assets/app.css"}
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :blog_20y,
  site_url:
    (case Mix.env() do
       :prod -> "https://20y.hu/~slink"
       :dev -> System.get_env("BLOG20Y_TARGET")
     end),
  files_url: "https://20y.hu",
  title: "20Y",
  rss_post_limit: 20,
  output_dir: System.get_env("BLOG20Y_TARGET")
