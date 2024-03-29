defmodule KnitMakerWeb.QuestionLive.FormComponent do
  use KnitMakerWeb, :live_component

  alias KnitMaker.Events
  alias KnitMaker.Events.Question

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <%= if @action != :add_question do %>
        <.tab_bar>
          <:tab
            title="Properties"
            selected={@action == :edit_question}
            link_to={~p"/events/#{@event}/question/#{@question}/edit"}
          />
          <:tab
            title="Question"
            selected={@action == :config_question}
            link_to={~p"/events/#{@event}/question/#{@question}/config"}
          />
          <:tab
            :if={v_config_schema(@form[:v_type])}
            title="Visualization"
            selected={@action == :visualize_question}
            link_to={~p"/events/#{@event}/question/#{@question}/visualize"}
          />
        </.tab_bar>
      <% end %>

      <.simple_form
        for={@form}
        id="question-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= cond do %>
          <% @action == :config_question -> %>
            <.rjsf field={@form[:q_config]} schema={q_config_schema(@form[:q_type])} label="Config" />
          <% @action == :visualize_question -> %>
            <.rjsf
              :if={v_config_schema(@form[:v_type])}
              field={@form[:v_config]}
              schema={v_config_schema(@form[:v_type])}
              ui_schema={v_config_ui_schema(@form[:v_type])}
              label="Visualization config"
            />
          <% true -> %>
            <.input field={@form[:title]} type="text" label="Title" />
            <.input field={@form[:description]} type="text" label="Description" />
            <div class="grid grid-cols-2 gap-4">
              <div class="flex flex-col gap-2">
                <.input
                  field={@form[:q_type]}
                  type="select"
                  label="Type"
                  options={KnitMaker.Events.Question.q_types()}
                />
                <%= if @form[:q_type].value do %>
                  <img src={"/assets/img/events/q_type_" <> @form[:q_type].value <> ".png"} />
                <% end %>
              </div>
              <div class="flex flex-col gap-2">
                <.input
                  field={@form[:v_type]}
                  type="select"
                  label="Visualization"
                  options={KnitMaker.Events.Question.v_types()}
                />
                <%= if @form[:v_type].value do %>
                  <img
                    src={"/assets/img/events/v_type_" <> @form[:v_type].value <> ".png"}
                    style="image-rendering: pixelated;"
                  />
                <% end %>
              </div>
            </div>
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Save Question</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def q_config_schema(%{value: "pixel"}) do
    %{
      "properties" => %{
        "max_pixels" => %{
          "type" => "number",
          "title" => "Pixels per user"
        },
        "width" => %{
          "type" => "number",
          "title" => "Grid width"
        },
        "height" => %{
          "type" => "number",
          "title" => "Grid height"
        }
      },
      "required" => ["max_pixels", "width", "height"]
    }
  end

  def q_config_schema(_) do
    %{
      "properties" => %{
        "answers" => %{
          "title" => "",
          "type" => "array",
          "items" => %{
            "type" => "string"
          }
        }
      }
    }
  end

  def v_config_schema(%{value: f}) when f in ~w(gridfill gridfill-double) do
    %{"properties" => %{"height" => %{"type" => "number"}}}
  end

  def v_config_schema(%{value: "border-count"}) do
    %{
      "properties" => %{
        "top_pattern" => %{"type" => "string"},
        "bottom_pattern" => %{"type" => "string"}
      }
    }
  end

  def v_config_schema(_), do: nil

  def v_config_ui_schema(%{value: "border-count"}) do
    %{
      "top_pattern" => %{"ui:widget" => "textarea"},
      "bottom_pattern" => %{"ui:widget" => "textarea"}
    }
  end

  def v_config_ui_schema(_), do: nil

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:label, :string, required: true)
  attr(:schema, :map, required: true)
  attr(:ui_schema, :map)

  def rjsf(assigns) do
    assigns = assigns |> assign_new(:ui_schema, fn -> %{} end)

    ~H"""
    <div
      phx-feedback-for={@field.name}
      phx-update="ignore"
      phx-hook="RJSF"
      id={@field.name}
      data-schema={Jason.encode!(@schema || %{})}
      data-ui-schema={Jason.encode!(@ui_schema || %{})}
    >
      <input type="hidden" name={@field.name} value={Jason.encode!(@field.value)} />
      <.label for={@field.name}><%= @label %></.label>
      <div class="root"></div>
    </div>
    """
  end

  @impl true
  def update(%{question: question} = assigns, socket) do
    changeset = Events.change_question(question)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  def update(assigns, socket) do
    update(Map.put(assigns, :question, %Question{}), socket)
  end

  @impl true
  def handle_event("validate", %{"question" => question_params}, socket) do
    changeset =
      socket.assigns.question
      |> Events.change_question(question_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"question" => question_params}, socket) do
    save_question(socket, socket.assigns.action, question_params)
  end

  defp save_question(socket, :add_question, question_params) do
    case Events.create_question_for_event(socket.assigns.event, question_params) do
      {:ok, question} ->
        notify_parent({:saved, question})

        {:noreply,
         socket
         |> put_flash(:info, "Question created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_question(socket, _, question_params) do
    case Events.update_question(socket.assigns.question, question_params) do
      {:ok, question} ->
        notify_parent({:saved, question})

        {:noreply,
         socket
         |> put_flash(:info, "Question updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
