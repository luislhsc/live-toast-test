defmodule HelloPhoenixWeb.ConversationLive.Show do
  use HelloPhoenixWeb, :live_view

  alias HelloPhoenix.Messaging

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Conversation {@conversation.id}
        <:subtitle>This is a conversation record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/messaging_conversations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/messaging_conversations/#{@conversation}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit conversation
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Body">{@conversation.body}</:item>
        <:item title="Contact name">{@conversation.contact_name}</:item>
        <:item title="Contact email">{@conversation.contact_email}</:item>
        <:item title="Contact phone">{@conversation.contact_phone}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Messaging.subscribe_messaging_conversations(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Show Conversation")
     |> assign(:conversation, Messaging.get_conversation!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %HelloPhoenix.Messaging.Conversation{id: id} = conversation},
        %{assigns: %{conversation: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :conversation, conversation)}
  end

  def handle_info(
        {:deleted, %HelloPhoenix.Messaging.Conversation{id: id}},
        %{assigns: %{conversation: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current conversation was deleted.")
     |> push_navigate(to: ~p"/messaging_conversations")}
  end
end
