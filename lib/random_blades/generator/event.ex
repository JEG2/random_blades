defmodule RandomBlades.Generator.Event do
  use RandomBlades.Generator

  data_source(:rumor)
  data_source(:news)
  data_source(:occurance)

  def build_template do
    combined_template(
      name: "Event",
      generators: [
        build_rumor_template(),
        build_news_template(),
        build_occurance_template()
      ],
      display: :named_list
    )
  end

  def build_rumor_template do
    value_template(name: "Rumors on the Street", generator: :rumor)
  end

  def build_news_template do
    combined_template(
      name: "City Events in the Newspapers",
      generators: [
        list_template(
          generator: :news,
          size: one_or_two(),
          display: :sentence
        )
      ],
      display: :words
    )
  end

  def build_occurance_template do
    value_template(name: "Remarkable Occurances", generator: :occurance)
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
