defmodule Blog20y.Processor do
  # Add auto-generated id to h2 nodes
  def process({"h2", [], [text], %{}}) do
    anchor_id = slugify(text)
    {"h2", [{"id", anchor_id}], [text], %{}}
  end

  def process(value), do: value

  def slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z]+/, "-")
    |> String.trim("-")
  end
end
