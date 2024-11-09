defmodule Poll.Polls.Option do
  use Ecto.Schema
  import Ecto.Changeset

  alias Poll.Polls.{Poll, Vote}

  schema "options" do
    field :text, :string

    belongs_to :poll, Poll
    has_many :votes, Vote, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:text, :poll_id])
    |> validate_required([:text, :poll_id])
    |> assoc_constraint(:poll)
  end
end
