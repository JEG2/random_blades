defmodule RandomBlades.Generator.Person do
  use RandomBlades.Generator
  alias RandomBlades.Generator.Name

  data_source(:look)
  data_source(:style)
  data_source(:goal)
  data_source(:method)
  data_source(:common_profession)
  data_source(:rare_profession)
  data_source(:trait)
  data_source(:interest)
  data_source(:quirk)

  def heritage do
    if :rand.uniform(6) <= 3 do
      "Akorosi"
    else
      rand = :rand.uniform(6)

      cond do
        rand <= 2 ->
          "Skovlander"

        rand == 3 ->
          "Iruvian"

        rand == 4 ->
          "Dagger Islander"

        rand == 5 ->
          "Severosi"

        rand == 6 ->
          "Tycherosi (FIXME: demon trait)"
      end
    end
  end

  def gender do
    rand = :rand.uniform(6)

    cond do
      rand <= 2 ->
        "Man"

      rand <= 4 ->
        "Woman"

      rand == 5 ->
        "Ambiguous, concealed"

      rand == 6 ->
        gender()
    end
  end

  def build_template do
    combined_template(
      name: "Person",
      generators: [
        Name.build_template(),
        build_heritage_template(),
        build_look_template(),
        build_goal_template(),
        build_method_template(),
        build_profession_template(),
        build_trait_template(),
        build_interest_template(),
        build_quirk_template()
      ],
      display: :named_list
    )
  end

  def build_heritage_template do
    value_template(name: "Heritage", generator: :heritage)
  end

  def build_look_template do
    combined_template(
      name: "Looks",
      generators: [
        :gender,
        list_template(
          generator: :look,
          size: one_to_three(),
          display: :sentence
        ),
        list_template(generator: :style, size: one_or_two(), display: :sentence)
      ],
      display: :unordered_list
    )
  end

  def build_goal_template do
    combined_template(
      name: "Goals",
      generators: [
        list_template(generator: :goal, size: one_or_two(), display: :sentence)
      ],
      display: :words
    )
  end

  def build_method_template do
    combined_template(
      name: "Preferred Methods",
      generators: [
        list_template(
          generator: :method,
          size: one_or_two(),
          display: :sentence
        )
      ],
      display: :words
    )
  end

  def build_profession_template do
    generator =
      if one_or_two() == 1 do
        list_template(
          generator: :common_profession,
          size: one_or_two(),
          display: :sentence
        )
      else
        value_template(generator: :rare_profession)
      end

    combined_template(
      name: "Profession",
      generators: [generator],
      display: :words
    )
  end

  def build_trait_template do
    combined_template(
      name: "Traits",
      generators: [
        list_template(
          generator: :trait,
          size: one_to_three(),
          display: :sentence
        )
      ],
      display: :words
    )
  end

  def build_interest_template do
    value_template(name: "Interests", generator: :interest)
  end

  def build_quirk_template do
    value_template(name: "Quirks", generator: :quirk)
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

  defp one_to_three do
    rand = :rand.uniform(100)

    cond do
      rand <= 15 ->
        1

      rand <= 75 ->
        2

      true ->
        3
    end
  end
end
