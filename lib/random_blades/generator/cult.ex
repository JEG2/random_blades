defmodule RandomBlades.Generator.Cult do
  use RandomBlades.Generator

  data_source(:god)
  data_source(:practice)

  def build_template do
    combined_template(
      name: "Cult",
      generators: [
        build_god_template(),
        build_practice_template()
      ],
      display: :named_list
    )
  end

  def build_god_template do
    value_template(name: "Forgotten God", generator: :god)
  end

  def build_practice_template do
    combined_template(
      name: "Practices",
      generators: [
        list_template(
          generator: :practice,
          size: one_or_two(),
          display: :unordered_list
        )
      ],
      display: :words
    )
  end

  defp one_or_two do
    rand = :rand.uniform(100)

    cond do
      rand <= 85 ->
        1

      true ->
        2
    end
  end
end
