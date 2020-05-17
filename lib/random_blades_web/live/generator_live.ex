defmodule RandomBladesWeb.GeneratorLive do
  alias RandomBlades.{Generator, Template}
  use RandomBladesWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    generator = Module.concat([Generator, Map.fetch!(params, "generator")])

    {
      :noreply,
      assign(socket, generator: generator, data: Generator.generate(generator))
    }
  end

  @impl true
  def handle_event("reroll", %{"path" => path_string}, socket) do
    {path, access_path} = parse_paths(path_string)

    new_data =
      case get_in(socket.assigns.data, access_path) do
        %Template.Value{} ->
          update_in(socket.assigns.data, access_path, &Template.reroll/1)

        value when is_binary(value) ->
          update_in(
            socket.assigns.data,
            Enum.drop(access_path, -2),
            fn template -> Template.reroll(template, List.last(path)) end
          )
      end

    new_socket = assign(socket, data: new_data)
    {:noreply, new_socket}
  end

  @impl true
  def handle_event("add", %{"path" => path_string}, socket) do
    {path, access_path} = parse_paths(path_string)

    new_data =
      update_in(
        socket.assigns.data,
        access_path,
        &Template.add_value/1
      )

    new_socket = assign(socket, data: new_data)
    {:noreply, new_socket}
  end

  @impl true
  def handle_event("remove", %{"path" => path_string}, socket) do
    {path, access_path} = parse_paths(path_string)

    new_data =
      update_in(
        socket.assigns.data,
        Enum.drop(access_path, -2),
        fn template -> Template.remove_value(template, List.last(path)) end
      )

    new_socket = assign(socket, data: new_data)
    {:noreply, new_socket}
  end

  defp render_generated(
         socket,
         template_or_value,
         path,
         remove_action? \\ false
       )

  defp render_generated(
         socket,
         %Template.Value{} = template,
         path,
         _remove_action?
       ) do
    render_generated(socket, template.value, path)
  end

  defp render_generated(
         socket,
         %{display: :words} = template,
         path,
         _remove_action?
       ) do
    render_values(
      socket,
      template.values,
      path,
      " ",
      match?(%Template.List{}, template)
    )
  end

  defp render_generated(
         socket,
         %{display: :quoted_words} = template,
         path,
         _remove_action?
       ) do
    case render_generated(socket, %{template | display: :words}, path) do
      "" ->
        ""

      words ->
        ~s["#{words}"]
    end
  end

  defp render_generated(
         socket,
         %{display: :paragraph_of_words} = template,
         path,
         _remove_action?
       ) do
    case render_generated(socket, %{template | display: :words}, path) do
      "" ->
        ""

      words ->
        ["<p>", words, "</p>"]
    end
  end

  defp render_generated(
         socket,
         %{display: :hyphenated} = template,
         path,
         _remove_action?
       ) do
    render_values(
      socket,
      template.values,
      path,
      "-",
      match?(%Template.List{}, template)
    )
  end

  defp render_generated(
         socket,
         %{display: :sentence} = template,
         path,
         _remove_action?
       ) do
    render_values(
      socket,
      template.values,
      path,
      ", ",
      match?(%Template.List{}, template)
    )
    |> String.replace(~r{\A(.+),\s(.+)}, "\\1 and \\2")
  end

  defp render_generated(
         socket,
         %{display: :named_list} = template,
         path,
         _remove_action?
       ) do
    list =
      template.values
      |> Enum.with_index()
      |> Enum.map(fn {template, i} ->
        [
          content_tag(:dt, template.name) |> safe_to_string,
          "<dd>",
          render_generated(socket, template, path ++ [i]),
          "</dd>"
        ]
      end)
      |> Enum.join("")

    "<dl>#{list}</dl>"
  end

  defp render_generated(
         socket,
         %{display: :unordered_list} = template,
         path,
         _remove_action?
       ) do
    list =
      template.values
      |> Enum.with_index()
      |> Enum.map(fn {template, i} ->
        [
          "<li>",
          render_generated(socket, template, path ++ [i]),
          "</li>"
        ]
      end)
      |> Enum.join("")

    "<ul>#{list}</ul>"
  end

  defp render_generated(socket, raw_value, path, remove_action?) do
    value = [
      html_escape(raw_value),
      render_action(socket, "repeat-signs@1x.png", :reroll, path)
    ]

    value_with_remove =
      if remove_action? do
        value ++
          [render_action(socket, "remove-layer-editing@1x.png", :remove, path)]
      else
        value
      end
      |> Enum.map(&safe_to_string/1)
      |> Enum.join("")
  end

  defp render_values(
         socket,
         values,
         path,
         joiner,
         list?,
         remove_action? \\ false
       )

  defp render_values(socket, values, path, joiner, false, remove_action?) do
    values
    |> Enum.with_index()
    |> Enum.map(fn {template_or_value, i} ->
      render_generated(socket, template_or_value, path ++ [i], remove_action?)
    end)
    |> Enum.join(joiner)
  end

  defp render_values(socket, values, path, joiner, true, _remove_action?) do
    content = render_values(socket, values, path, joiner, false, true)

    add_action =
      socket
      |> render_action("add-layer-editing@1x.png", :add, path)
      |> safe_to_string()

    content <> add_action
  end

  defp render_action(socket, image, action, path) do
    path_string = Enum.join(path, ",")

    content_tag(
      :button,
      img_tag(
        Routes.static_path(socket, "/images/#{image}"),
        width: 24,
        height: 24,
        class: "actions"
      ),
      class: "image-only",
      phx_click: action,
      phx_value_path: path_string
    )
  end

  defp parse_paths(path_string) do
    path =
      path_string
      |> String.split(",")
      |> Enum.map(fn i -> String.to_integer(i) end)

    access_path = [
      Access.key(:values)
      | path
        |> Enum.map(&Access.at/1)
        |> Enum.intersperse(Access.key(:values))
    ]

    {path, access_path}
  end
end
