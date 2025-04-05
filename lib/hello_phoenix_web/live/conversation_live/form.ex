defmodule HelloPhoenixWeb.ConversationLive.Form do
  use HelloPhoenixWeb, :live_view

  alias HelloPhoenix.Messaging
  alias HelloPhoenix.Messaging.Conversation

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage conversation records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="conversation-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:body]} type="text" label="Body" />
        <.input field={@form[:contact_name]} type="text" label="Contact name" />
        <.input field={@form[:contact_email]} type="text" label="Contact email" />
        <.input field={@form[:contact_phone]} type="text" label="Contact phone" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Conversation</.button>
          <.button navigate={return_path(@current_scope, @return_to, @conversation)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    conversation = Messaging.get_conversation!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Conversation")
    |> assign(:conversation, conversation)
    |> assign(
      :form,
      to_form(Messaging.change_conversation(nil, conversation))
    )
  end

  defp apply_action(socket, :new, _params) do
    conversation = %Conversation{}

    socket
    |> assign(:page_title, "New Conversation")
    |> assign(:conversation, conversation)
    |> assign(
      :form,
      to_form(Messaging.change_conversation(nil, conversation))
    )
  end

  @impl true
  def handle_event("validate", %{"conversation" => conversation_params}, socket) do
    changeset =
      Messaging.change_conversation(
        socket.assigns.current_scope,
        socket.assigns.conversation,
        conversation_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"conversation" => conversation_params}, socket) do
    save_conversation(socket, socket.assigns.live_action, conversation_params)
  end

  defp save_conversation(socket, :edit, conversation_params) do
    case Messaging.update_conversation(
           socket.assigns.current_scope,
           socket.assigns.conversation,
           conversation_params
         ) do
      {:ok, conversation} ->
        {:noreply,
         socket
         |> LiveToast.put_toast(:info, "Conversation updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, conversation)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_conversation(socket, :new, conversation_params) do
    case Messaging.create_conversation(socket.assigns.current_scope, conversation_params) do
      {:ok, conversation} ->
        {:noreply,
         socket
         |> LiveToast.put_toast(:info, "Conversation created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, conversation)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _conversation), do: ~p"/messaging_conversations"
  defp return_path(_scope, "show", conversation), do: ~p"/messaging_conversations/#{conversation}"
end
