defmodule Blog20y.Journal do
  alias Blog20y.Post

  use NimblePublisher,
    from: "./content/journal/*.md",
    build: Post,
    parser: Post,
    html_converter: Post,
    as: :posts

  @posts Enum.sort_by(@posts, & &1.publishdate, {:desc, Date})
  @tags List.foldl(@posts, [], fn post, acc -> acc ++ post.tags end) |> List.flatten()

  def all_posts, do: @posts
  def all_tags, do: @tags
end
