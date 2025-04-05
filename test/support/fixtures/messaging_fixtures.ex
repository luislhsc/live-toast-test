defmodule HelloPhoenix.MessagingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HelloPhoenix.Messaging` context.
  """

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "some body",
        contact_email: "some contact_email",
        contact_name: "some contact_name",
        contact_phone: "some contact_phone"
      })

    {:ok, conversation} = HelloPhoenix.Messaging.create_conversation(scope, attrs)
    conversation
  end
end
