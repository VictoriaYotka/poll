defmodule Poll.Polls do
  @moduledoc """
  The Polls context handles creating, fetching, and managing polls, options, and votes.

  This module provides functions to allow users to create polls with multiple options, cast votes on options,
  and ensures that users can only vote once per poll.
  """

  import Ecto.Query, warn: false
  alias Poll.Repo

  alias Poll.Polls.{Poll, Option, Vote}

  ## Poll Functions

  @doc """
  Creates a new poll with the given attributes.

  ## Parameters

    - attrs: A map with the poll's attributes, including `title`, `description`, and `user_id`.

  ## Examples

      iex> create_poll(%{title: "Favorite Language?", description: "Choose one", user_id: 1})
      {:ok, %Poll{}}

      iex> create_poll(%{})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(attrs \\ %{}) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves all polls from the database.

  ## Examples

      iex> list_all_polls()
      [%Poll{}, %Poll{}, ...]

      iex> list_all_polls()
      []

  """
  def list_all_polls do
    Repo.all(Poll)
  end

  @doc """
  Lists all polls created by a specific user.

  ## Parameters

    - user_id: The ID of the user whose polls you want to fetch.

  ## Examples

      iex> list_polls_by_user(1)
      [%Poll{}, %Poll{}]

      iex> list_polls_by_user(999)
      []

  """
  def list_polls_by_user(user_id) when is_integer(user_id) do
    Repo.all(from p in Poll, where: p.user_id == ^user_id)
  end

  ## Option Functions

  @doc """
  Creates a new option for a given poll.

  ## Parameters

    - attrs: A map with the option's attributes, including `text` and `poll_id`.

  ## Examples

      iex> create_option(%{text: "Elixir", poll_id: 1})
      {:ok, %Option{}}

      iex> create_option(%{})
      {:error, %Ecto.Changeset{}}

  """
  def create_option(attrs \\ %{}) do
    %Option{}
    |> Option.changeset(attrs)
    |> Repo.insert()
  end

  ## Vote Functions

  @doc """
  Casts a vote by a user on a specific option, if they haven't already voted in the poll.

  ## Parameters

    - user_id: The ID of the user casting the vote.
    - option_id: The ID of the option the user is voting for.

  ## Examples

      iex> create_vote(1, 2)
      {:ok, %Vote{}}

      iex> create_vote(1, 2) # User tries to vote again
      {:error, :already_voted}

  """
  def create_vote(user_id, option_id) do
    option = Repo.get!(Option, option_id)

    # Check if user has already voted in this poll
    existing_vote =
      Repo.one(
        from v in Vote,
        join: o in Option, on: v.option_id == o.id,
        where: v.user_id == ^user_id and o.poll_id == ^option.poll_id
      )

    if existing_vote do
      {:error, :already_voted}
    else
      %Vote{}
      |> Vote.changeset(%{user_id: user_id, option_id: option_id})
      |> Repo.insert()
    end
  end

  @doc """
  Lists all options for a specific poll.

  ## Parameters

    - poll_id: The ID of the poll whose options you want to retrieve.

  ## Examples

      iex> list_options_by_poll(1)
      [%Option{}, %Option{}]

      iex> list_options_by_poll(999)
      []

  """
  def list_options_by_poll(poll_id) when is_integer(poll_id) do
    Repo.all(from o in Option, where: o.poll_id == ^poll_id)
  end
end
