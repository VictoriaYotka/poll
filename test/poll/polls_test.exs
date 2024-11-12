defmodule Poll.PollsTest do
  use Poll.DataCase, async: true

  import Poll.PollsFixtures
  import Poll.AccountsFixtures

  alias Poll.Polls

  describe "create_poll/1" do
    test "successfully creates a poll with valid data" do
      poll = poll_fixture(%{title: "Favorite color?", description: "Choose your favorite color"})

      assert poll.title == "Favorite color?"
      assert poll.description == "Choose your favorite color"
    end

    test "fails to create a poll with missing title" do
      assert {:error, changeset} = Polls.create_poll(%{description: "No title provided"})
      assert "can't be blank" in errors_on(changeset).title
    end
  end

  describe "get_poll_by_id/1" do
    setup do
      user = user_fixture()

      poll =
        poll_fixture(%{
          title: "General Poll",
          description: "A poll about general topics",
          user_id: user.id
        })

      %{user: user, poll: poll}
    end

    test "retrieves poll by id with associated user and votes", %{poll: poll, user: user} do
      result = Polls.get_poll_by_id(poll.id)

      assert result.id == poll.id
      assert result.title == poll.title
      assert result.description == poll.description
      assert result.user.id == user.id
      assert result.user.email == user.email
    end

    test "returns nil when poll not found" do
      result = Polls.get_poll_by_id(-1)
      assert result == nil
    end
  end

  describe "list_all_polls/5" do
    setup do
      user = user_fixture()
      poll1 = poll_fixture(%{title: "Elixir Poll", user_id: user.id})
      Process.sleep(1000)
      poll2 = poll_fixture(%{title: "Phoenix Poll", user_id: user.id})
      Process.sleep(1000)

      poll3 =
        poll_fixture(%{
          title: "General Poll",
          description: "A poll about general topics",
          user_id: user.id
        })

      option1 = option_fixture(poll1.id)
      option2 = option_fixture(poll2.id)
      _vote1 = vote_fixture(user.id, poll1.id, option1.id)
      _vote2 = vote_fixture(user.id, poll2.id, option2.id)
      _vote3 = vote_fixture(user.id, poll2.id, option2.id)

      %{user: user, poll1: poll1, poll2: poll2, poll3: poll3}
    end

    test "retrieves polls sorted by date in ascending order", %{
      poll1: poll1,
      poll2: poll2,
      poll3: poll3
    } do
      result = Polls.list_all_polls(:date, :asc, "", 0, 3)
      sorted_polls = Enum.sort_by([poll1, poll2, poll3], & &1.inserted_at, :asc)

      assert Enum.map(result, fn %{poll: %{id: id}} -> id end) ==
               Enum.map(sorted_polls, fn %{id: id} -> id end)
    end

    test "retrieves polls sorted by date in descending order", %{
      poll1: poll1,
      poll2: poll2,
      poll3: poll3
    } do
      result = Polls.list_all_polls(:date, :desc, "", 0, 3)
      sorted_polls = Enum.sort_by([poll1, poll2, poll3], & &1.inserted_at, :desc)

      assert Enum.map(result, fn %{poll: %{id: id}} -> id end) ==
               Enum.map(sorted_polls, fn %{id: id} -> id end)
    end

    test "retrieves polls sorted by popularity in ascending order", %{
      poll1: poll1,
      poll2: poll2,
      poll3: poll3
    } do
      poll1_data = Polls.get_poll_with_format(poll1.id)
      poll2_data = Polls.get_poll_with_format(poll2.id)
      poll3_data = Polls.get_poll_with_format(poll3.id)

      expected_order =
        [poll1_data, poll2_data, poll3_data]
        |> Enum.sort_by(& &1.vote_count)
        |> Enum.map(& &1.poll.id)

      result = Polls.list_all_polls(:popularity, :asc, "", 0, 3)
      assert Enum.map(result, & &1.poll.id) == expected_order
    end

    test "retrieves polls sorted by popularity in descending order", %{
      poll1: poll1,
      poll2: poll2,
      poll3: poll3
    } do
      poll1_data = Polls.get_poll_with_format(poll1.id)
      poll2_data = Polls.get_poll_with_format(poll2.id)
      poll3_data = Polls.get_poll_with_format(poll3.id)

      expected_order =
        [poll1_data, poll2_data, poll3_data]
        |> Enum.sort_by(& &1.vote_count, :desc)
        |> Enum.map(& &1.poll.id)

      result = Polls.list_all_polls(:popularity, :desc, "", 0, 3)
      assert Enum.map(result, & &1.poll.id) == expected_order
    end

    test "filters polls by query matching title or description", %{poll1: poll1, poll3: poll3} do
      result = Polls.list_all_polls(:date, :desc, "Elixir", 0, 3)
      assert Enum.map(result, & &1.poll.id) == [poll1.id]

      result = Polls.list_all_polls(:date, :desc, "general", 0, 3)
      assert Enum.map(result, & &1.poll.id) == [poll3.id]
    end

    test "applies pagination with offset and limit" do
      limit = 2
      result = Polls.list_all_polls(:date, :desc, "", 0, limit)
      assert length(result) == limit
    end

    test "returns empty list when no polls match the query" do
      result = Polls.list_all_polls(:date, :desc, "nonexistent", 0, 3)
      assert result == []
    end

    test "lists polls for a user, ordered by date (descending)", %{
      user: user,
      poll1: poll1,
      poll2: poll2,
      poll3: poll3
    } do
      result = Polls.list_polls_by_user(user.id, 0, 3)
      sorted_polls = Enum.sort_by([poll1, poll2, poll3], & &1.inserted_at, :desc)

      assert Enum.map(result, fn %{poll: %{id: id}} -> id end) ==
               Enum.map(sorted_polls, fn %{id: id} -> id end)
    end
  end
end
