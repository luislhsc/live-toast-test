defmodule HelloPhoenix.Repo.Migrations.CreateMessagingConversations do
  use Ecto.Migration

  def change do
    create table(:messaging_conversations) do
      add :body, :string
      add :contact_name, :string
      add :contact_email, :string
      add :contact_phone, :string
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
