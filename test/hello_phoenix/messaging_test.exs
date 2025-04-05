defmodule HelloPhoenix.MessagingTest do
  use HelloPhoenix.DataCase

  alias HelloPhoenix.Messaging

  describe "messaging_conversations" do
    alias HelloPhoenix.Messaging.Conversation

    import HelloPhoenix.AccountsFixtures, only: [user_scope_fixture: 0]
    import HelloPhoenix.MessagingFixtures

    @invalid_attrs %{body: nil, contact_name: nil, contact_email: nil, contact_phone: nil}

    test "list_messaging_conversations/1 returns all scoped messaging_conversations" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversation = conversation_fixture(scope)
      other_conversation = conversation_fixture(other_scope)
      assert Messaging.list_messaging_conversations(scope) == [conversation]
      assert Messaging.list_messaging_conversations(other_scope) == [other_conversation]
    end

    test "get_conversation!/2 returns the conversation with given id" do
      scope = user_scope_fixture()
      conversation = conversation_fixture(scope)
      other_scope = user_scope_fixture()
      assert Messaging.get_conversation!(scope, conversation.id) == conversation

      assert_raise Ecto.NoResultsError, fn ->
        Messaging.get_conversation!(other_scope, conversation.id)
      end
    end

    test "create_conversation/2 with valid data creates a conversation" do
      valid_attrs = %{
        body: "some body",
        contact_name: "some contact_name",
        contact_email: "some contact_email",
        contact_phone: "some contact_phone"
      }

      scope = user_scope_fixture()

      assert {:ok, %Conversation{} = conversation} =
               Messaging.create_conversation(scope, valid_attrs)

      assert conversation.body == "some body"
      assert conversation.contact_name == "some contact_name"
      assert conversation.contact_email == "some contact_email"
      assert conversation.contact_phone == "some contact_phone"
      assert conversation.user_id == scope.user.id
    end

    test "create_conversation/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.create_conversation(scope, @invalid_attrs)
    end

    test "update_conversation/3 with valid data updates the conversation" do
      scope = user_scope_fixture()
      conversation = conversation_fixture(scope)

      update_attrs = %{
        body: "some updated body",
        contact_name: "some updated contact_name",
        contact_email: "some updated contact_email",
        contact_phone: "some updated contact_phone"
      }

      assert {:ok, %Conversation{} = conversation} =
               Messaging.update_conversation(scope, conversation, update_attrs)

      assert conversation.body == "some updated body"
      assert conversation.contact_name == "some updated contact_name"
      assert conversation.contact_email == "some updated contact_email"
      assert conversation.contact_phone == "some updated contact_phone"
    end

    test "update_conversation/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversation = conversation_fixture(scope)

      assert_raise MatchError, fn ->
        Messaging.update_conversation(other_scope, conversation, %{})
      end
    end

    test "update_conversation/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      conversation = conversation_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Messaging.update_conversation(scope, conversation, @invalid_attrs)

      assert conversation == Messaging.get_conversation!(scope, conversation.id)
    end

    test "delete_conversation/2 deletes the conversation" do
      scope = user_scope_fixture()
      conversation = conversation_fixture(scope)
      assert {:ok, %Conversation{}} = Messaging.delete_conversation(scope, conversation)

      assert_raise Ecto.NoResultsError, fn ->
        Messaging.get_conversation!(scope, conversation.id)
      end
    end

    test "delete_conversation/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversation = conversation_fixture(scope)
      assert_raise MatchError, fn -> Messaging.delete_conversation(other_scope, conversation) end
    end

    test "change_conversation/2 returns a conversation changeset" do
      scope = user_scope_fixture()
      conversation = conversation_fixture(scope)
      assert %Ecto.Changeset{} = Messaging.change_conversation(scope, conversation)
    end
  end
end
