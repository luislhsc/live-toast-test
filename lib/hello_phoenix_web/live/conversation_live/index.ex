defmodule HelloPhoenixWeb.ConversationLive.Index do
  use HelloPhoenixWeb, :live_view

  alias HelloPhoenix.Messaging

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div>
        <div class="flex justify-between mb-10">
          <.button variant="primary" phx-click="send_toast">
            Send Toast
          </.button>
          <.button variant="primary" phx-click="toast_and_patch">
            Toast + Patch
          </.button>
          <.button variant="primary" phx-click="toast_and_navigate">
            Toast + Navigate
          </.button>
        </div>
        <.header>
          Listing Messaging conversations {@count}
          <:actions>
            <.button variant="primary" navigate={~p"/messaging_conversations/new"}>
              <.icon name="hero-plus" /> New Conversation
            </.button>
          </:actions>
        </.header>
      </div>

      <.table
        id="messaging_conversations"
        rows={@streams.messaging_conversations}
        row_click={
          fn {_id, conversation} -> JS.navigate(~p"/messaging_conversations/#{conversation}") end
        }
      >
        <:col :let={{_id, conversation}} label="Body">{conversation.body}</:col>
        <:col :let={{_id, conversation}} label="Contact name">{conversation.contact_name}</:col>
        <:col :let={{_id, conversation}} label="Contact email">{conversation.contact_email}</:col>
        <:col :let={{_id, conversation}} label="Contact phone">{conversation.contact_phone}</:col>
        <:action :let={{_id, conversation}}>
          <div class="sr-only">
            <.link navigate={~p"/messaging_conversations/#{conversation}"}>Show</.link>
          </div>
          <.link navigate={~p"/messaging_conversations/#{conversation}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, conversation}}>
          <.link
            phx-click={JS.push("delete", value: %{id: conversation.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    Messaging.subscribe_messaging_conversations(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Messaging conversations")
     |> assign(:count, 0)
     |> stream(
       :messaging_conversations,
       Messaging.list_messaging_conversations(socket.assigns.current_scope)
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    conversation = Messaging.get_conversation!(socket.assigns.current_scope, id)
    {:ok, _} = Messaging.delete_conversation(socket.assigns.current_scope, conversation)

    # Dot not work
    # LiveToast.send_toast(:info, "Conversation DELETED")

    # Always using Flash, it is right?
    socket = LiveToast.put_toast(socket, :info, "Conversation DELETED", title: "Deleted")
    # socket = put_flash(socket, :info, "Conversation DELETED")

    {:noreply, stream_delete(socket, :messaging_conversations, conversation)}
  end

  @impl true
  def handle_event("toast_and_patch", _params, socket) do
    socket =
      socket
      |> LiveToast.put_toast(:info, "Conversation PATCHED #{socket.assigns.count}",
        title: "Patched"
      )
      |> assign(:count, socket.assigns.count + 1)
      |> push_patch(to: "/messaging_conversations?counter=#{socket.assigns.count}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("toast_and_navigate", _params, socket) do
    socket =
      socket
      |> assign(:count, socket.assigns.count + 1)
      |> LiveToast.put_toast(:info, "Conversation NAVIGATE #{socket.assigns.count}",
        title: "Navigated"
      )
      |> push_navigate(to: "/messaging_conversations")

    {:noreply, socket}
  end

  @impl true
  def handle_event("send_toast", _params, socket) do
    LiveToast.send_toast(:info, "Conversation TOAST #{socket.assigns.count}", title: "Send Toast")

    {:noreply, assign(socket, :count, socket.assigns.count + 1)}
  end

  @impl true
  def handle_info({type, %HelloPhoenix.Messaging.Conversation{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(
       socket,
       :messaging_conversations,
       Messaging.list_messaging_conversations(socket.assigns.current_scope),
       reset: true
     )}
  end
end
