defmodule HelloPhoenix.Messaging do
  @moduledoc """
  The Messaging context.
  """

  import Ecto.Query, warn: false
  alias HelloPhoenix.Repo

  alias HelloPhoenix.Messaging.Conversation

  @doc """
  Subscribes to scoped notifications about any conversation changes.

  The broadcasted messages match the pattern:

    * {:created, %Conversation{}}
    * {:updated, %Conversation{}}
    * {:deleted, %Conversation{}}

  """
  def subscribe_messaging_conversations(_scope) do
    Phoenix.PubSub.subscribe(HelloPhoenix.PubSub, "user:1:messaging_conversations")
  end

  defp broadcast(_scope, message) do
    Phoenix.PubSub.broadcast(HelloPhoenix.PubSub, "user:1:messaging_conversations", message)
  end

  @doc """
  Returns the list of messaging_conversations.

  ## Examples

      iex> list_messaging_conversations(scope)
      [%Conversation{}, ...]

  """
  def list_messaging_conversations(_scope) do
    Repo.all(from(conversation in Conversation))
  end

  @doc """
  Gets a single conversation.

  Raises `Ecto.NoResultsError` if the Conversation does not exist.

  ## Examples

      iex> get_conversation!(123)
      %Conversation{}

      iex> get_conversation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_conversation!(_scope, id) do
    Repo.get_by!(Conversation, id: id)
  end

  @doc """
  Creates a conversation.

  ## Examples

      iex> create_conversation(%{field: value})
      {:ok, %Conversation{}}

      iex> create_conversation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation(_scope, attrs \\ %{}) do
    with {:ok, conversation = %Conversation{}} <-
           %Conversation{}
           |> Conversation.changeset(attrs)
           |> Repo.insert() do
      broadcast(nil, {:created, conversation})
      {:ok, conversation}
    end
  end

  @doc """
  Updates a conversation.

  ## Examples

      iex> update_conversation(conversation, %{field: new_value})
      {:ok, %Conversation{}}

      iex> update_conversation(conversation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation(_scope, %Conversation{} = conversation, attrs) do
    with {:ok, conversation = %Conversation{}} <-
           conversation
           |> Conversation.changeset(attrs)
           |> Repo.update() do
      broadcast(nil, {:updated, conversation})
      {:ok, conversation}
    end
  end

  @doc """
  Deletes a conversation.

  ## Examples

      iex> delete_conversation(conversation)
      {:ok, %Conversation{}}

      iex> delete_conversation(conversation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation(_scope, %Conversation{} = conversation) do
    with {:ok, conversation = %Conversation{}} <-
           Repo.delete(conversation) do
      broadcast(nil, {:deleted, conversation})
      {:ok, conversation}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation changes.

  ## Examples

      iex> change_conversation(conversation)
      %Ecto.Changeset{data: %Conversation{}}

  """
  def change_conversation(_scope, %Conversation{} = conversation, attrs \\ %{}) do
    Conversation.changeset(conversation, attrs)
  end
end
