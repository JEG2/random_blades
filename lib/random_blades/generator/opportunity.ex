defmodule RandomBlades.Generator.Opportunity do
  use RandomBlades.Generator
  alias RandomBlades.Generator.Score

  data_source(:job)
  data_source(:cargo)

  def build_template do
    combined_template(
      name: "Smuggler's Opportunity",
      generators: [
        build_job_template(),
        build_cargo_template(),
        Score.build_twist_template()
      ],
      display: :named_list
    )
  end

  def build_job_template do
    value_template(name: "Job", generator: :job)
  end

  def build_cargo_template do
    value_template(name: "Contraband / Cargo", generator: :cargo)
  end
end
