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
            title="Configuration"
            selected={@action == :config_question}
            link_to={~p"/events/#{@event}/question/#{@question}/config"}
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
        <%= if @action == :config_question do %>
          <.rjsf field={@form[:config]} schema={config_schema(@form[:type])} label="Config" />
        <% else %>
          <.input field={@form[:title]} type="text" label="Title" />
          <div class="grid grid-cols-2 gap-4">
            <.input
              field={@form[:type]}
              type="select"
              label="Type"
              options={KnitMaker.Events.Question.types()}
            />
            <.input field={@form[:rank]} type="number" label="Rank" />
          </div>
          <.input field={@form[:description]} type="text" label="Description" />
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Save Question</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def config_schema(_type) do
    %{
      "properties" => %{
        "emails" => %{
          "type" => "array",
          "items" => %{
            "title" => "",
            "properties" => %{
              "email" => %{"type" => "string", "format" => "email"}
            }
          }
        }
      }
    }
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, required: true
  attr :schema, :map, required: true
  attr :ui_schema, :map

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
