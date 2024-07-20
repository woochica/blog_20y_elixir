defmodule Blog20y.Pages do
  alias Blog20y.Page

  use NimblePublisher,
    from: "./content/*.md",
    build: Page,
    parser: Page,
    html_converter: Page,
    as: :pages

  def all_pages, do: @pages
end
