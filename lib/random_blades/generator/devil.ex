defmodule RandomBlades.Generator.Devil do
  use RandomBlades.Generator

  data_source(:name)
  data_source(:feature)
  data_source(:trait)
  data_source(:affinity)
  data_source(:desire)
  data_source(:horror)

  def effect do
    rand = :rand.uniform(6)

    row =
      cond do
        rand <= 3 ->
          [
            "Frost, Chill",
            "Cold wind",
            "Faint visions of the local past",
            "Electrical discharge",
            "Weird shadows",
            "Faint echoes"
          ]

        rand <= 5 ->
          [
            "Mist, Fog",
            "Rushing wind",
            "Intense visual echoes",
            "Intense magnetism",
            "Disturbing shadows",
            "Thunderous sounds"
          ]

        rand == 6 ->
          [
            "Freezing fog",
            "Storm winds",
            "Pitch darkness",
            "Lightning",
            "Clutching shadows",
            "Voices in your head"
          ]
      end

    Enum.random(row)
  end

  def aspect do
    rand = :rand.uniform(6)

    cond do
      rand <= 3 ->
        "Humanoid w/ Bestial or Elemental Features"

      rand == 4 ->
        "Animal"

      rand == 5 ->
        "Monstrous"

      rand == 6 ->
        "Amorphous"
    end
  end

  def build_template do
    combined_template(
      name: "Devil",
      generators: [
        build_name_template(),
        build_feature_template(),
        build_trait_template(),
        build_effect_template(),
        build_type_template(),
        build_desire_template(),
        build_horror_template()
      ],
      display: :named_list
    )
  end

  def build_name_template do
    value_template(name: "Name", generator: :name)
  end

  def build_feature_template do
    combined_template(
      name: "Features",
      generators: [
        list_template(
          generator: :feature,
          size: one_or_two(),
          display: :sentence
        )
      ],
      display: :words
    )
  end

  def build_trait_template do
    combined_template(
      name: "Ghostly Traits",
      generators: [
        list_template(
          generator: :trait,
          size: one_or_two(),
          display: :sentence
        )
      ],
      display: :words
    )
  end

  def build_type_template do
    combined_template(
      name: "Demon Types",
      generators: [
        value_template(generator: :aspect),
        value_template(generator: :affinity)
      ],
      display: :unordered_list
    )
  end

  def build_effect_template do
    value_template(name: "Ghostly Secondary Effects", generator: :effect)
  end

  def build_desire_template do
    combined_template(
      name: "Demon Desires",
      generators: [
        list_template(
          generator: :desire,
          size: one_or_two(),
          display: :sentence
        )
      ],
      display: :words
    )
  end

  def build_horror_template do
    value_template(name: "Summoned Horrors", generator: :horror)
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
