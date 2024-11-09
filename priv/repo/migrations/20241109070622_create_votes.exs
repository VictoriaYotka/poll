defmodule Poll.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :option_id, references(:options, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:votes, [:user_id])
    create index(:votes, [:option_id])

    create unique_index(:votes, [:user_id, :option_id], name: :unique_user_vote_per_poll)
  end
end
