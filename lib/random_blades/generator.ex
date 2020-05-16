defmodule RandomBlades.Generator do
  defmacro __using__(_options) do
    quote do
      import RandomBlades.Generator, only: [data_source: 1]

      def combined_template(fields) do
        fields
        |> Keyword.put(:source, __MODULE__)
        |> RandomBlades.Template.Combined.new
      end

      def list_template(fields) do
        fields
        |> Keyword.put(:source, __MODULE__)
        |> RandomBlades.Template.List.new
      end

      def value_template(fields) do
        fields
        |> Keyword.put(:source, __MODULE__)
        |> RandomBlades.Template.Value.new
      end
    end
  end

  defmacro data_source(name) do
    data_name = String.to_atom("#{name}_data")
    quote do
      def unquote(name)() do
        Enum.random(unquote(data_name)())
      end

      def unquote(data_name)() do
        dir =
          __MODULE__
          |> Module.split
          |> List.last
          |> Macro.underscore
        "data/#{dir}/#{unquote(name)}.txt"
        |> Path.expand(:code.priv_dir(:random_blades))
        |> File.stream!
        |> Stream.map(&String.trim/1)
      end
    end
  end

  def generate(generator) do
    generator.build_template
    |> RandomBlades.Template.evaluate
  end
end
