defmodule Blog20y.Journal do
  alias Blog20y.Post
  alias Blog20y.Processor

  use NimblePublisher,
    from: "./content/journal/*.md",
    build: Post,
    parser: Post,
    html_converter: Post,
    as: :posts,
    earmark_options: [postprocessor: &Processor.process/1]

  @posts Enum.sort_by(@posts, & &1.lastmod, {:desc, Date})
  @published_posts Enum.filter(@posts, fn post -> not post.draft end)
  @tags List.foldl(@posts, [], fn post, acc -> acc ++ post.tags end) |> List.flatten()

  def all_posts, do: @posts
  def published_posts, do: @published_posts
  def all_tags, do: @tags
end
