defmodule Poll.Polls.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Poll.Polls.Option
  alias Poll.Accounts.User

  schema "votes" do
    belongs_to :user, User
    belongs_to :option, Option

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:user_id, :option_id])
    |> validate_required([:user_id, :option_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:option)
    |> unique_constraint([:user_id, :option_id], name: :unique_user_vote_per_poll)
  end
end
