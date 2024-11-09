defmodule Poll.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  alias Poll.Polls.{Option, Vote}
  alias Poll.Accounts.User

  schema "polls" do
    field :title, :string
    field :description, :string

    belongs_to :user, User
    has_many :options, Option, on_delete: :delete_all
    has_many :votes, through: [:options, :votes]

    timestamps()
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:title, :description, :user_id])
    |> validate_required([:title, :user_id])
    |> assoc_constraint(:user)
    |> unique_constraint(:title)
  end
end