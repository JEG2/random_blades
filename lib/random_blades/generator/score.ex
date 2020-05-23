defmodule RandomBlades.Generator.Score do
  use RandomBlades.Generator

  data_source(:client)
  data_source(:work)
  data_source(:twist)
  data_source(:person)
  data_source(:faction)

  def client_with_reroll do
    [client, reroll] =
      client_data
      |> Enum.shuffle()
      |> Enum.slice(0..1)

    String.replace(
      client,
      "(roll again)",
      String.replace(reroll, ~r{\A\S+\s+}, "")
    )
  end

  def build_template do
    combined_template(
      name: "Score",
      generators: [
        build_client_template(),
        build_target_template(),
        build_work_template(),
        build_twist_template(),
        build_person_template(),
        build_faction_template()
      ],
      display: :named_list
    )
  end

  def build_client_template do
    value_template(name: "Client", generator: :client_with_reroll)
  end

  def build_target_template do
    value_template(name: "Target", generator: :client_with_reroll)
  end

  def build_work_template do
    value_template(name: "Work", generator: :work)
  end

  def build_twist_template do
    value_template(name: "Twist or Complication", generator: :twist)
  end

  def build_person_template do
    value_template(name: "Connected to person…", generator: :person)
  end

  def build_faction_template do
    list_template(
      name: "…and Factions",
      generator: :faction,
      min: 1,
      max: 2,
      display: :sentence
    )
  end
end
