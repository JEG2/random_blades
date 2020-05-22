defmodule RandomBlades.Generator.Building do
  use RandomBlades.Generator

  data_source(:material)
  data_source(:exterior)
  data_source(:common_use)
  data_source(:rare_use)
  data_source(:detail)
  data_source(:item)

  def build_template do
    combined_template(
      name: "Building",
      generators: [
        build_exterior_template(),
        build_use_template(),
        build_detail_template(),
        build_item_template()
      ],
      display: :named_list
    )
  end

  def build_exterior_template do
    combined_template(
      name: "Exterior",
      generators: [
        build_material_template(),
        build_exterior_detail_template()
      ],
      display: :named_list
    )
  end

  def build_material_template do
    value_template(name: "Material", generator: :material)
  end

  def build_exterior_detail_template do
    value_template(name: "Details", generator: :exterior)
  end

  def build_use_template do
    if :rand.uniform(100) <= 85 do
      value_template(name: "Use", generator: :common_use)
    else
      value_template(name: "Use", generator: :rare_use)
    end
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

  def build_item_template do
    list_template(
      name: "Items",
      generator: :item,
      min: 1,
      max: 2,
      display: :sentence
    )
  end
end
