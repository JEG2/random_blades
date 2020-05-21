defmodule RandomBlades.Generator.Street do
  use RandomBlades.Generator

  data_source(:mood)
  data_source(:sight)
  data_source(:sound)
  data_source(:smell)
  data_source(:detail)
  data_source(:prop)

  def use do
    rand = :rand.uniform(6)

    row =
      cond do
        rand <= 3 ->
          [
            "Residential",
            "Crafts",
            "Labor",
            "Shops",
            "Trade",
            "Hospitality"
          ]

        rand <= 5 ->
          [
            "Law, Government",
            "Public Space",
            "Power",
            "Manufacture",
            "Transportation",
            "Leisure"
          ]

        rand == 6 ->
          [
            "Vice",
            "Entertainment",
            "Storage",
            "Cultivation",
            "Academic",
            "Artists"
          ]
      end

    Enum.random(row)
  end

  def type do
    rand = :rand.uniform(6)

    row =
      cond do
      rand <= 3 ->
        [
          "Narrow Lane",
          "Tight Alley",
          "Twisting Street",
          "Rough Road",
          "Bridge",
          "Waterway"
        ]

      rand <= 5 ->
        [
          "Closed Court",
          "Open Plaza",
          "Paved Avenue",
          "Tunnel",
          "Wide Boulevard",
          "Roundabout"
        ]

      rand == 6 ->
        [
          "Elevated",
          "Flooded",
          "Suspended",
          "Subterranean",
          "Floating",
          "Private, Gated"
        ]
    end

    Enum.random(row)
  end

  def build_template do
    combined_template(
      name: "Event",
      generators: [
        build_mood_template(),
        build_impression_template(),
        build_use_template(),
        build_type_template(),
        build_detail_template(),
        build_prop_template()
      ],
      display: :named_list
    )
  end

  def build_mood_template do
    value_template(name: "Mood", generator: :mood)
  end

  def build_impression_template do
    combined_template(
      name: "Impressions",
      generators: [
        build_sight_template(),
        build_sound_template(),
        build_smell_template()
      ],
      display: :named_list
    )
  end

  def build_sight_template do
    value_template(name: "Sights", generator: :sight)
  end

  def build_sound_template do
    value_template(name: "Sounds", generator: :sound)
  end

  def build_smell_template do
    value_template(name: "Smells", generator: :smell)
  end

  def build_use_template do
    value_template(name: "Use", generator: :use)
  end

  def build_type_template do
    value_template(name: "Type", generator: :type)
  end

  def build_detail_template do
    list_template(
      name: "Details",
      generator: :detail,
      min: 1,
      max: 3,
      display: :sentence
    )
  end

  def build_prop_template do
    list_template(
      name: "Props",
      generator: :prop,
      min: 2,
      max: 4,
      display: :sentence
    )
  end
end
