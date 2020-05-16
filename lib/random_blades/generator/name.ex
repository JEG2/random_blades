defmodule RandomBlades.Generator.Name do
  use RandomBlades.Generator

  data_source(:first)
  data_source(:alias_prefix)
  data_source(:alias_suffix)
  data_source(:last)

  def full_alias do
    Enum.random(full_alias_data())
  end

  def full_alias_data do
    Stream.concat(alias_prefix_data(), alias_suffix_data())
  end

  def build_template do
    rand = :rand.uniform(100)

    name =
      cond do
        rand <= 5 ->
          build_first_only_template()

        rand <= 10 ->
          build_alias_only_template()

        rand <= 15 ->
          build_last_only_template()

        true ->
          build_full_template()
      end
      |> List.wrap()

    combined_template(
      name: "Name",
      generators: name,
      display: :paragraph_of_words
    )
  end

  def build_first_only_template do
    size = if :rand.uniform(100) <= 10, do: 2, else: 1
    list_template(generator: :first, size: size, display: :words)
  end

  def build_alias_only_template do
    if :rand.uniform(100) <= 10 do
      combined_template(
        generators: [
          list_template(generator: :alias_prefix, size: 1, display: :words),
          value_template(generator: :alias_suffix)
        ],
        display: :quoted_words
      )
    else
      combined_template(
        generators: [
          value_template(generator: :full_alias)
        ],
        display: :quoted_words
      )
    end
  end

  def build_last_only_template do
    size = if :rand.uniform(100) <= 10, do: 2, else: 1
    list_template(generator: :last, size: size, display: :hyphenated)
  end

  def build_full_template do
    [
      build_first_only_template(),
      build_alias_only_template(),
      build_last_only_template()
    ]
  end
end
