defmodule Blog20y.Page do
  require Logger
  require YamlFrontMatter

  @enforce_keys [:slug, :title, :body, :path, :lastmod]
  defstruct [:slug, :title, :body, :path, :lastmod, :toc]

  @site_url Application.fetch_env!(:blog_20y, :site_url)

  def build(filename, attrs, body) do
    Logger.debug("Building page: " <> attrs[:title])

    # Remove "content"
    path = filename |> Path.rootname() |> Path.split() |> Enum.drop(1) |> Path.join()

    # Add suffix
    [slug] = path |> Path.split() |> Enum.take(-1)
    path = path <> "/index.html"

    # Parse code
    # TODO eventually fix links in hte posts to contain the leading slash
    new_body = String.replace(body, "{{< siteurl >}}", @site_url <> "/")

    struct!(__MODULE__, [body: new_body, slug: slug, path: path] ++ Map.to_list(attrs))
  end

  def parse(path, contents) do
    Logger.debug("Parsing page: " <> path)
    {raw_attrs, body} = YamlFrontMatter.parse!(contents)

    attrs =
      raw_attrs
      |> Enum.map(fn {key, value} -> {String.to_existing_atom(key), value} end)
      |> Map.new()

    lastmod =
      case DateTime.from_iso8601(attrs[:lastmod]) do
        {:ok, lastmod, _} ->
          DateTime.to_date(lastmod)

        {:error, _} ->
          Date.from_iso8601!(attrs[:lastmod])
      end

    {%{attrs | lastmod: lastmod}, body}
  end

  def convert(_extname, body, _attrs, opts) do
    Logger.debug("Converting raw body to HTML")

    earmark_opts =
      Keyword.get(opts, :earmark_options, %Earmark.Options{breaks: true, inner_html: false})

    body |> Earmark.as_html!(earmark_opts)
  end
end
