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
  Retrieves all polls from the database, with optional filtering and sorting.

  The function joins the necessary associations (`user`, `options`, `votes`), allows filtering by title/description, and supports sorting by creation date or popularity (number of votes).

  ## Parameters

  - `filters` (optional, default: `%{}`): A map of filters:
    - `:query` (string): A search query to filter polls by `title` or `description`.
    - `:sort` (optional, default: `:date`): The field to sort by. Possible values are:
      - `:date`: Sort by creation date.
      - `:popularity`: Sort by the number of votes.
    - `:direction` (optional, default: `:desc`): The direction to sort. Possible values are:
      - `:asc`: Ascending order.
      - `:desc`: Descending order.

  ## Returns
  - A list of polls with the following structure:
    - `poll`: The poll data (`%Poll{}`).
    - `user`: The associated user (`%User{}`).
    - `vote_count`: The number of votes for the poll (integer).

  ## Examples

  ### Example 1: Retrieve all polls with no filters
        iex> list_all_polls()
        [
          %{poll: %Poll{title: "Poll 1", description: "Description 1", inserted_at: ~N[2024-01-01]}, user: %User{email: "user1@example.com"}, vote_count: 5},
          %{poll: %Poll{title: "Poll 2", description: "Description 2", inserted_at: ~N[2024-01-02]}, user: %User{email: "user2@example.com"}, vote_count: 2}
        ]

  ### Example 2: Retrieve all polls filtered by a search query
        iex> list_all_polls(query: "poll")
        [
          %{poll: %Poll{title: "Poll 1", description: "Description 1", inserted_at: ~N[2024-01-01]}, user: %User{email: "user1@example.com"}, vote_count: 5}
        ]

  ### Example 3: Retrieve all polls sorted by popularity (number of votes) in descending order
        iex> list_all_polls(sort: :popularity, direction: :desc)
        [
          %{poll: %Poll{title: "Poll 1", description: "Description 1", inserted_at: ~N[2024-01-01]}, user: %User{email: "user1@example.com"}, vote_count: 10},
          %{poll: %Poll{title: "Poll 2", description: "Description 2", inserted_at: ~N[2024-01-02]}, user: %User{email: "user2@example.com"}, vote_count: 5}
        ]

  ### Example 4: Retrieve all polls sorted by creation date in ascending order
        iex> list_all_polls(sort: :date, direction: :asc)
        [
          %{poll: %Poll{title: "Poll 2", description: "Description 2", inserted_at: ~N[2024-01-02]}, user: %User{email: "user2@example.com"}, vote_count: 2},
          %{poll: %Poll{title: "Poll 1", description: "Description 1", inserted_at: ~N[2024-01-01]}, user: %User{email: "user1@example.com"}, vote_count: 5}
        ]
  """

  def list_all_polls(filters \\ %{}) do
    query =
      from p in Poll,
        left_join: u in assoc(p, :user),
        left_join: o in assoc(p, :options),
        left_join: v in assoc(o, :votes),
        group_by: [p.id, u.id],
        select: %{poll: p, user: u, vote_count: count(v.id)}

    query
    |> apply_user_query(filters[:query])
    |> apply_sort(filters[:sort] || :date, filters[:direction] || :desc)
    |> Repo.all()
  end

  defp apply_user_query(query, nil), do: query

  defp apply_user_query(query, user_query) when user_query != "" do
    from p in query,
      where: ilike(p.title, ^"%#{user_query}%") or ilike(p.description, ^"%#{user_query}%")
  end

  defp apply_sort(query, :date, direction) do
    case direction do
      :asc -> from p in query, order_by: [asc: p.inserted_at]
      :desc -> from p in query, order_by: [desc: p.inserted_at]
      _ -> from p in query, order_by: [desc: p.inserted_at]
    end
  end

  defp apply_sort(query, :popularity, direction) do
    case direction do
      :asc ->
        from p in query,
          left_join: v in assoc(p, :votes),
          group_by: p.id,
          order_by: [asc: count(v.id)]

      :desc ->
        from p in query,
          left_join: v in assoc(p, :votes),
          group_by: p.id,
          order_by: [desc: count(v.id)]

      _ ->
        from p in query,
          left_join: v in assoc(p, :votes),
          group_by: p.id,
          order_by: [desc: count(v.id)]
    end
  end

  @doc """
  Lists all polls created by a specific user.

  ## Parameters

    - `user_id` (integer): The ID of the user whose polls are to be fetched.

  ## Returns

    - A list of maps with the following structure:
      - `:poll` - The poll data as a `%Poll{}` struct.
      - `:user` - The user data associated with the poll as a `%User{}` struct.
      - `:vote_count` - The total count of votes associated with each poll.

  ## Examples

      iex> list_polls_by_user(1)
      [
        %{
          poll: %Poll{
            id: 1,
            title: "Poll title",
            description: "Poll description",
            user_id: 1,
            inserted_at: ~N[2024-11-11 12:29:37],
            updated_at: ~N[2024-11-11 12:29:37]
          },
          user: %User{
            id: 1,
            email: "user@example.com",
            inserted_at: ~N[2024-11-11 07:39:29],
            updated_at: ~N[2024-11-11 07:39:29]
          },
          vote_count: 5
        },
        %{
          poll: %Poll{...},
          user: %User{...},
          vote_count: 3
        }
      ]

      iex> list_polls_by_user(999)
      []

  """
  def list_polls_by_user(user_id) when is_integer(user_id) do
    query =
      from p in Poll,
        left_join: u in assoc(p, :user),
        left_join: o in assoc(p, :options),
        left_join: v in assoc(o, :votes),
        where: p.user_id == ^user_id,
        group_by: [p.id, u.id],
        order_by: [desc: p.inserted_at],
        select: %{poll: p, user: u, vote_count: count(v.id)}

    Repo.all(query)
  end

  @doc """
  Retrieves a poll by its unique ID.

  ## Parameters
    - id: The ID of the poll to retrieve. It must be an integer.

  ## Examples

      iex> Polls.get_poll_by_id(1)
      %Poll.Polls.Poll{id: 1, title: "Favorite Color", description: "What is your favorite color?"}

      iex> Polls.get_poll_by_id(999)
      nil

  ## Notes
    - Returns `nil` if no poll with the given ID is found.
    - The `id` should be a valid integer (e.g., `1`, `2`, etc.).
  """
  def get_poll_by_id(id) do
    Poll
    |> Repo.get(id)
    |> Repo.preload([:user, votes: :user])
  end

  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
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

  @doc """
  Creates multiple options based on the provided list of option attributes.

  Each option's attributes are validated using the `Option.changeset/2` function.
  Only valid options are attempted to be inserted into the database.
  If all options are successfully inserted, returns `{:ok, :all_inserted}`.
  If there are no valid options or any option insertion fails, returns an error tuple.

  ## Parameters
    - options_attrs: A list of maps, where each map contains the attributes for an option (e.g., `%{"text" => "Option text", "poll_id" => 1}`).

  ## Examples

      iex> options_attrs = [
      ...>   %{"text" => "Option 1", "poll_id" => 1},
      ...>   %{"text" => "Option 2", "poll_id" => 1}
      ...> ]
      iex> Polls.create_options(options_attrs)
      {:ok, :all_inserted}

      iex> options_attrs = [
      ...>   %{"text" => "Option 1", "poll_id" => 1},
      ...>   %{"text" => "", "poll_id" => 1}  # Invalid option (empty text)
      ...> ]
      iex> Polls.create_options(options_attrs)
      {:error, "No valid options"}  # Returns error if no valid options exist

      iex> options_attrs = [
      ...>   %{"text" => "Valid Option", "poll_id" => 1},
      ...>   %{"text" => "Another Valid Option", "poll_id" => 1}
      ...> ]
      iex> Polls.create_options(options_attrs)
      {:ok, :all_inserted}
  """
  def create_options(options_attrs) do
    options_attrs
    |> Enum.map(&Option.changeset(%Option{}, &1))
    |> Enum.filter(& &1.valid?)
    |> case do
      [] ->
        {:error, "No valid options"}

      valid_changesets ->
        results = Enum.map(valid_changesets, &Repo.insert(&1))

        case Enum.find(results, fn res -> match?({:error, _}, res) end) do
          nil -> {:ok, :all_inserted}
          error -> error
        end
    end
  end

  ## Vote Functions

  @doc """
  Casts a vote by a user on a specific option, if they haven't already voted in the poll.

  ## Parameters

    - user_id: The ID of the user casting the vote.
    - poll_id: The ID of the poll the user is voting for.
    - option_id: The ID of the option the user is voting for.

  ## Examples

      iex> create_vote(1, 2)
      {:ok, %Vote{}}

      iex> create_vote(1, 2) # User tries to vote again
      {:error, :already_voted}

  """
  def create_vote(%{user_id: user_id, poll_id: poll_id, option_id: option_id}) do
    case Repo.get(Option, option_id) do
      nil ->
        {:error, :option_not_found}

      _option ->
        if has_user_voted?(user_id, poll_id) do
          {:error, :already_voted}
        else
          case Repo.insert(
                 Vote.changeset(%Vote{}, %{
                   user_id: user_id,
                   option_id: option_id,
                   poll_id: poll_id
                 })
               ) do
            {:ok, _vote} ->
              updated_option = Repo.get!(Option, option_id) |> Repo.preload(:votes)
              {:ok, updated_option}

            {:error, changeset} ->
              {:error, changeset}
          end
        end
    end
  end

  @doc """
  Checks if a user has already voted in the given poll.

  ## Examples

      iex> has_user_voted?(123, 1)
      true

      iex> has_user_voted?(123, 99)
      false
  """
  def has_user_voted?(user_id, poll_id) do
    Repo.exists?(from v in Vote, where: v.user_id == ^user_id and v.poll_id == ^poll_id)
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

  @doc """
  Returns a random option for the given poll.

  ## Examples

      iex> get_random_option_for_poll(1)
      %Option{...}
  """
  def get_random_option_for_poll(poll_id) do
    Repo.one(
      from o in Option, where: o.poll_id == ^poll_id, order_by: fragment("RANDOM()"), limit: 1
    )
  end
end
