defmodule Blog20y do
  alias XmlBuilder
  require Logger
  use Phoenix.Component
  import Phoenix.HTML

  @site_title Application.fetch_env!(:blog_20y, :title)
  @site_url Application.fetch_env!(:blog_20y, :site_url)
  @rss_post_limit Application.fetch_env!(:blog_20y, :rss_post_limit)
  @output_dir Application.fetch_env!(:blog_20y, :output_dir)

  def site_title do
    @site_title
  end

  def site_url do
    @site_url
  end

  def tags(tags) do
    tags
    |> Enum.map(fn tag ->
      link =
        if tag == "Mixtape" do
          ~s(#{site_url()}/mixtapes/index.html)
        else
          ~s(#{site_url()}/#{Slug.slugify(tag)}/index.html)
        end

      ~s(<a href="#{link}">#{tag}</a>)
    end)
    |> Enum.join(" and ")
    |> raw
  end

  def post(assigns) do
    ~H"""
    <.layout
    title={~s(#{@post.title} — #{site_title()})}
    >
      <article>
      <div>
      <h1><%= raw @post.title %></h1>
      <%= raw @post.body %>
      <hr />
      <footer>
        This entry was published on <%= format_post_date(@post.publishdate) %> in <a href={site_url()}>20Y</a>.
        <%= if @post.lastmod != @post.publishdate do %>
        It was last updated on <%= format_post_date(@post.lastmod) %>.
        <% end %>
        It's filed in the <%= tags(@post.tags) %> folder<%= if length(@post.tags) > 1 do "s" else "" end  %>.
      </footer>
      </div>
      </article>
    </.layout>
    """
  end

  def page(assigns) do
    ~H"""
    <.layout
    title={"#{@page.title} — #{site_title()}"}
    >
      <article>
      <h1><%= raw @page.title %></h1>
      <%= raw @page.body %>
      </article>
    </.layout>
    """
  end

  def index(assigns) do
    ~H"""
    <.layout
    title={site_title()}
    >
      <h1 id="title"><%= site_title() %></h1>
      <p>Hey! Here are some of the things I wished to share with you:</p>
      <ul>
        <li :for={post <- @posts}>
          <a href={post.path}><%= post.title %></a>
          <span class="post-meta">
          <%= post.tags |> (Enum.map (fn tag -> ~s(##{tag}) end)) |> Enum.join(", ") %>
          — <%= format_post_date(post.publishdate) %>
          </span>
        </li>
      </ul>
      <p>Explore more:</p>
      <ul>
        <li :for={page <- @pages}>
          <a href={page.path}><%= page.title %></a>
        </li>
        <li>
          <a href={site_url() <> "/bits.html"}>Interesting bits</a>
        </li>
        <li>
          <a href={site_url() <> "/mixtapes/"}>Mixtapes</a>
        </li>
      </ul>
    </.layout>
    """
  end

  def tag_index(assigns) do
    ~H"""
    <.layout
    title={"#{@tag} — #{site_title()}"}
    >
      <h1 id="title"><%= @tag %></h1>
      <ul>
        <li :for={post <- @posts}>
          <a href={site_url() <> "/" <> post.path}><%= post.title %></a>
        </li>
      </ul>
    </.layout>
    """
  end

  def layout(assigns) do
    ~H"""
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8" />
        <title><%= @title %></title>
        <link rel="stylesheet" href={site_url() <> "/assets/app.css"} />
        <link href={site_url() <> "/index.xml" } rel="alternate" type="application/rss+xml" title={site_title()} />
        <link rel="icon" type="image/png" sizes="32x32" href={site_url() <> "/favicon-32x32.png"}>
        <link rel="icon" type="image/png" sizes="16x16" href={site_url() <> "/favicon-16x16.png"}>
      </head>
      <body>
        <%= render_slot(@inner_block) %>
      </body>
    </html>
    """
  end

  def format_iso_date(date = %DateTime{}) do
    DateTime.to_iso8601(date)
  end

  def format_iso_date(date = %Date{}) do
    date
    |> DateTime.new!(~T[06:00:00])
    |> format_iso_date()
  end

  def format_rss_date(date = %DateTime{}) do
    Calendar.strftime(date, "%a, %d %b %Y %H:%M:%S %z")
  end

  def format_rss_date(date = %Date{}) do
    date
    |> DateTime.new!(~T[06:00:00])
    |> format_rss_date()
  end

  def format_post_date(date) do
    Calendar.strftime(date, "%B %d, %Y")
  end

  def rss(posts) do
    XmlBuilder.element(:rss, %{version: "2.0", "xmlns:atom": "http://www.w3.org/2005/Atom"}, [
      {:channel,
       [
         {:title, site_title()},
         {:link, @site_url},
         {:description, "Recent content on #{site_title()}"},
         {:language, "en-us"},
         {:lastBuildDate, format_rss_date(DateTime.utc_now())},
         {:"atom:link",
          %{href: "#{@site_url}/index.xml", rel: "self", type: "application/rss+xml"}}
       ] ++
         for post <- Enum.take(posts, @rss_post_limit) do
           Logger.debug(post.path <> ": adding RSS entry")

           {:item,
            [
              {:title, post.title},
              {:link, @site_url <> "/" <> post.path},
              {:pubDate, format_rss_date(post.publishdate)},
              {:guid, @site_url <> "/" <> post.path},
              # add excerpt
              {:description, HtmlEntities.encode(post.excerpt)}
            ]}
         end}
    ])
    |> XmlBuilder.generate()
  end

  def sitemap(pages) do
    {:urlset,
     %{
       xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
       "xmlns:xhtml": "http://www.w3.org/1999/xhtml"
     },
     [
       {:url, [{:loc, @site_url}, {:lastmod, format_iso_date(DateTime.utc_now())}]}
       | for page <- pages do
           {:url,
            [{:loc, @site_url <> "/" <> page.path}, {:lastmod, format_iso_date(page.lastmod)}]}
         end
     ]}
    |> XmlBuilder.document()
    |> XmlBuilder.generate()
  end

  def build_tags() do
    Logger.info("Building tag indexes")

    posts = Blog20y.Journal.published_posts()
    all_tags = Blog20y.Journal.all_tags()

    Enum.map(all_tags, fn tag ->
      posts = Enum.filter(posts, fn post -> tag in post.tags end)

      render_file(
        Slug.slugify(tag) <> "/index.html",
        tag_index(%{
          tag: tag,
          posts: posts
        })
      )
    end)
  end

  def build() do
    posts = Blog20y.Journal.published_posts()
    pages = Blog20y.Pages.all_pages()

    Logger.info("Copying static files")
    File.cp_r!("static/content", @output_dir <> "/content")
    File.cp_r!("static/mixtapes", @output_dir <> "/mixtapes")
    File.cp_r!("static/favicon.ico", @output_dir <> "/favicon.ico")
    File.cp_r!("static/favicon-16x16.png", @output_dir <> "/favicon-16x16.png")
    File.cp_r!("static/favicon-32x32.png", @output_dir <> "/favicon-32x32.png")

    Logger.info("Building sitemap")
    write_file("sitemap.xml", sitemap(pages ++ posts))

    Logger.info("Building RSS feed")
    write_file("index.xml", rss(posts))

    Logger.info("Building posts")
    render_file("index.html", index(%{posts: posts, pages: pages}))

    for post <- posts do
      dir = Path.dirname(post.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      Logger.debug(post.path <> ": rendering post")
      render_file(post.path, post(%{post: post}))
    end

    build_tags()

    Logger.info("Building pages")

    for page <- pages do
      dir = Path.dirname(page.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      render_file(page.path, page(%{page: page}))
    end

    :ok
  end

  def write_file(path, data) do
    output = Path.join([@output_dir, path])
    File.write!(output, data)
  end

  def render_file(path, rendered) do
    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    dir = Path.dirname(output)
    File.mkdir_p!(dir)
    File.write!(output, safe)
  end
end
