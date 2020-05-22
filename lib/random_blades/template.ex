defmodule RandomBlades.Template do
  defmodule Combined do
    defstruct name: nil,
              source: nil,
              generators: [],
              display: :words,
              values: nil

    alias RandomBlades.Template

    def new(fields) do
      struct!(__MODULE__, Template.support_generator(fields))
      |> Template.validate(~w[name source generators display]a)
    end
  end

  defmodule List do
    defstruct name: nil,
              source: nil,
              generators: [],
              min: nil,
              max: nil,
              display: :words,
              values: nil

    alias RandomBlades.Template

    def new(fields) do
      struct!(
        __MODULE__,
        fields
        |> Template.support_generator()
        |> support_size
      )
      |> Template.validate(~w[name source generators min_and_max display]a)
    end

    defp support_size(fields) do
      if Keyword.has_key?(fields, :size) do
        fields
        |> Keyword.delete(:size)
        |> Keyword.put(:min, Keyword.fetch!(fields, :size))
        |> Keyword.put(:max, Keyword.fetch!(fields, :size))
      else
        fields
      end
    end
  end

  defmodule Value do
    defstruct name: nil,
              source: nil,
              generator: nil,
              value: nil

    alias RandomBlades.Template

    def new(fields) do
      struct!(__MODULE__, fields)
      |> Template.validate(~w[name source generator]a)
    end
  end

  @display_types ~w[
    words hyphenated quoted_words paragraph_of_words sentence
    named_list unordered_list
  ]a

  def support_generator(fields) do
    if Keyword.has_key?(fields, :generator) do
      fields
      |> Keyword.delete(:generator)
      |> Keyword.put(:generators, [Keyword.fetch!(fields, :generator)])
    else
      fields
    end
  end

  def validate(template, field_names) do
    %{
      name: {
        fn t -> is_nil(t.name) or is_binary(t.name) end,
        "`:name` must be nil or a String"
      },
      source: {
        fn t -> is_atom(t.source) end,
        "`:source` must be a module"
      },
      generator: {
        fn t -> is_atom(t.generator) end,
        "`:generator` must be a function name"
      },
      generators: {
        fn t ->
          is_list(t.generators) and
            Enum.all?(t.generators, fn generator ->
              is_atom(generator) or
                match?(%RandomBlades.Template.Combined{}, generator) or
                match?(%RandomBlades.Template.List{}, generator) or
                match?(%RandomBlades.Template.Value{}, generator)
            end)
        end,
        "`:generators` must be a list of atoms and templates"
      },
      min_and_max: {
        fn t -> is_integer(t.min) and is_integer(t.max) and t.max >= t.min end,
        "`:min` and `:max` must be integers and `:max` must be >= `:min`"
      },
      display: {
        fn t -> t.display in @display_types end,
        "`:display` must be one of #{inspect(@display_types)}"
      }
    }
    |> Enum.reduce(template, fn {field_name, {f, message}}, t ->
      if field_name in field_names and not f.(t) do
        raise message
      else
        t
      end
    end)
  end

  def evaluate(%RandomBlades.Template.Value{} = template) do
    %RandomBlades.Template.Value{
      template
      | value: evaluate_generator(template.source, template.generator)
    }
  end

  def evaluate(%RandomBlades.Template.List{} = template) do
    count =
      if template.max == template.min do
        template.max
      else
        :rand.uniform(template.max - (template.min - 1)) +
          (template.min - 1)
      end

    values =
      Stream.cycle(template.generators)
      |> Enum.take(count)
      |> Enum.map(fn generator ->
        evaluate_generator(template.source, generator)
      end)

    %{template | values: values}
  end

  def evaluate(%RandomBlades.Template.Combined{} = template) do
    values =
      Enum.map(template.generators, fn generator ->
        evaluate_generator(template.source, generator)
      end)

    %{template | values: values}
  end

  defp evaluate_generator(source, generator) when is_atom(generator) do
    apply(source, generator, [])
  end

  defp evaluate_generator(_source, generator) do
    evaluate(generator)
  end

  def reroll(%RandomBlades.Template.Value{} = template) do
    evaluate(template)
  end

  def reroll(%RandomBlades.Template.List{} = template, index) do
    generator =
      Stream.cycle(template.generators)
      |> Stream.drop(index)
      |> Enum.take(1)
      |> hd

    %{
      template
      | values:
          Elixir.List.replace_at(
            template.values,
            index,
            evaluate_generator(template.source, generator)
          )
    }
  end

  def reroll(%RandomBlades.Template.Combined{} = template, index) do
    generator = Enum.at(template.generators, index)

    %{
      template
      | values:
          Elixir.List.replace_at(
            template.values,
            index,
            evaluate_generator(template.source, generator)
          )
    }
  end

  def add_value(%RandomBlades.Template.List{} = template) do
    generator =
      Stream.cycle(template.generators)
      |> Stream.drop(length(template.values))
      |> Enum.take(1)
      |> hd

    %{
      template
      | values:
          template.values ++
            [
              evaluate_generator(template.source, generator)
            ]
    }
  end

  def remove_value(%RandomBlades.Template.List{} = template, index) do
    %{template | values: Elixir.List.delete_at(template.values, index)}
  end
end
