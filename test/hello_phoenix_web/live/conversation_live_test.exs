defmodule HelloPhoenixWeb.ConversationLiveTest do
  use HelloPhoenixWeb.ConnCase

  import Phoenix.LiveViewTest
  import HelloPhoenix.MessagingFixtures

  @create_attrs %{
    body: "some body",
    contact_name: "some contact_name",
    contact_email: "some contact_email",
    contact_phone: "some contact_phone"
  }
  @update_attrs %{
    body: "some updated body",
    contact_name: "some updated contact_name",
    contact_email: "some updated contact_email",
    contact_phone: "some updated contact_phone"
  }
  @invalid_attrs %{body: nil, contact_name: nil, contact_email: nil, contact_phone: nil}

  setup :register_and_log_in_user

  defp create_conversation(%{scope: scope}) do
    conversation = conversation_fixture(scope)

    %{conversation: conversation}
  end

  describe "Index" do
    setup [:create_conversation]

    test "lists all messaging_conversations", %{conn: conn, conversation: conversation} do
      {:ok, _index_live, html} = live(conn, ~p"/messaging_conversations")

      assert html =~ "Listing Messaging conversations"
      assert html =~ conversation.body
    end

    test "saves new conversation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/messaging_conversations")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Conversation")
               |> render_click()
               |> follow_redirect(conn, ~p"/messaging_conversations/new")

      assert render(form_live) =~ "New Conversation"

      assert form_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#conversation-form", conversation: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/messaging_conversations")

      html = render(index_live)
      assert html =~ "Conversation created successfully"
      assert html =~ "some body"
    end

    test "updates conversation in listing", %{conn: conn, conversation: conversation} do
      {:ok, index_live, _html} = live(conn, ~p"/messaging_conversations")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#messaging_conversations-#{conversation.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/messaging_conversations/#{conversation}/edit")

      assert render(form_live) =~ "Edit Conversation"

      assert form_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#conversation-form", conversation: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/messaging_conversations")

      html = render(index_live)
      assert html =~ "Conversation updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes conversation in listing", %{conn: conn, conversation: conversation} do
      {:ok, index_live, _html} = live(conn, ~p"/messaging_conversations")

      assert index_live
             |> element("#messaging_conversations-#{conversation.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#messaging_conversations-#{conversation.id}")
    end
  end

  describe "Show" do
    setup [:create_conversation]

    test "displays conversation", %{conn: conn, conversation: conversation} do
      {:ok, _show_live, html} = live(conn, ~p"/messaging_conversations/#{conversation}")

      assert html =~ "Show Conversation"
      assert html =~ conversation.body
    end

    test "updates conversation and returns to show", %{conn: conn, conversation: conversation} do
      {:ok, show_live, _html} = live(conn, ~p"/messaging_conversations/#{conversation}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/messaging_conversations/#{conversation}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Conversation"

      assert form_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#conversation-form", conversation: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/messaging_conversations/#{conversation}")

      html = render(show_live)
      assert html =~ "Conversation updated successfully"
      assert html =~ "some updated body"
    end
  end
end
