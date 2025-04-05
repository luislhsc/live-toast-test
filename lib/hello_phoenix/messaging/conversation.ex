defmodule HelloPhoenix.Messaging.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messaging_conversations" do
    field :body, :string
    field :contact_name, :string
    field :contact_email, :string
    field :contact_phone, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:body, :contact_name, :contact_email, :contact_phone])
    |> validate_required([:body, :contact_name, :contact_email, :contact_phone])
  end
end
