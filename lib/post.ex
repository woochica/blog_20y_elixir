defmodule Blog20y.Post do
  alias Blog20y.Processor
  require Logger
  require YamlFrontMatter

  @enforce_keys [:slug, :title, :excerpt, :body, :publishdate, :path]
  defstruct [
    :body,
    :classname,
    :draft,
    :excerpt,
    :lang,
    :lastmod,
    :path,
    :publishdate,
    :section,
    :slug,
    :tags,
    :title,
    :toc,
    :toclevels
  ]

  @site_url Application.fetch_env!(:blog_20y, :site_url)
  @files_url Application.fetch_env!(:blog_20y, :files_url)
  @default_lang Application.fetch_env!(:blog_20y, :default_lang)

  def build(filename, attrs, body) do
    Logger.debug(filename <> ": building post")

    # Remove "content"
    path = filename |> Path.rootname() |> Path.split() |> Enum.drop(1) |> Path.join()

    # Add suffix
    [slug] = path |> Path.split() |> Enum.take(-1)
    path = path <> "/index.html"

    [excerpt | _tail] = String.split(body, "<!--more-->")

    struct!(
      __MODULE__,
      [body: body, slug: slug, path: path, excerpt: excerpt] ++ Map.to_list(attrs)
    )
  end

  def parse(path, contents) do
    Logger.debug(path <> ": parsing post")
    {raw_attrs, body} = YamlFrontMatter.parse!(contents)

    attrs =
      raw_attrs
      |> Enum.map(fn {key, value} -> {String.to_existing_atom(key), value} end)
      |> Map.new()

    publishdate =
      case DateTime.from_iso8601(attrs[:publishdate]) do
        {:ok, publishdate, _} ->
          DateTime.to_date(publishdate)

        {:error, _} ->
          Date.from_iso8601!(attrs[:publishdate])
      end

    lastmod =
      if Map.has_key?(attrs, :lastmod) do
        case DateTime.from_iso8601(attrs[:lastmod]) do
          {:ok, lastmod, _} ->
            DateTime.to_date(lastmod)

          {:error, _} ->
            Date.from_iso8601!(attrs[:lastmod])
        end
      else
        publishdate
      end

    draft =
      if Map.has_key?(attrs, :draft) do
        attrs[:draft]
      else
        false
      end

    # Parse first-level headings if toc is enabled
    toc =
      if attrs[:toc] do
        result = Earmark.Parser.as_ast(body)

        case result do
          {:ok, ast, _} ->
            for node <- ast, is_heading_node?(node), do: to_toc_heading(node)

          {:error, _, error_messages} ->
            Logger.warning(error_messages)
        end
      end

    lang =
      if attrs[:lang] do
        attrs[:lang]
      else
        @default_lang
      end

    {(Map.to_list(attrs) ++
        [publishdate: publishdate, lastmod: lastmod, draft: draft, toc: toc, lang: lang])
     |> Map.new(), body}
  end

  def convert(extname, body, _attrs, opts) do
    Logger.debug(extname <> ": converting raw body to HTML")

    earmark_opts =
      Keyword.get(opts, :earmark_options, %Earmark.Options{breaks: true, inner_html: false})

    result =
      body
      |> EEx.eval_string(
        mixtape_cover: &mixtape_cover/1,
        mixtape_disclaimer: &mixtape_disclaimer/1,
        site_url: @site_url
      )
      |> Earmark.as_html(earmark_opts)

    case result do
      {:ok, html_doc, _} ->
        html_doc

      {:error, html_doc, error_messages} ->
        Logger.warning(extname <> ": confusing markup encountered")
        Logger.warning(error_messages)
        html_doc
    end
  end

  defp is_heading_node?({"h2", [], [_text], %{}}), do: true
  defp is_heading_node?(_), do: nil

  defp to_toc_heading({"h2", [], [text], %{}}), do: {text, Processor.slugify(text)}
  defp to_toc_heading(_), do: nil

  def mixtape_cover(image) do
    image_src = @site_url <> "/" <> image

    ~s"""
    <figure><img src="#{image_src}" alt="Mixtape cover" /></figure>
    <style>
    :root {
      --mixtape-background-url: url(#{image_src});
    }
    </style>
    """
  end

  def mixtape_disclaimer(file) do
    """
    <hr>

    <p class="mixtape-disclaimer">
    I stopped using music streaming services and started to explore music on KEXP and <a href="#{@site_url}/journal/bandcamp/">purchase records on Bandcamp</a>.
    If you can also afford it, please support listener powered radios and the artists directly. If you wish to listen to this mixtape,
    <a href="#{@files_url}/#{file}">you can grab the files</a>.
    </p>
    """
  end
end
