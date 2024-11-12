defmodule Poll.VotesTest do
  use Poll.DataCase, async: true

  import Poll.PollsFixtures
  import Poll.AccountsFixtures

  alias Poll.Polls

  describe "Polls.create_vote/1" do
    test "successfully creates a vote for a user, poll, and option" do
      %{id: user_id} = user_fixture()
      %{id: poll_id} = poll_fixture(%{user_id: user_id})
      %{id: option_id} = option_fixture(poll_id)

      {:ok, option} = vote_fixture(user_id, poll_id, option_id)
      assert option.poll_id == poll_id
      assert Enum.any?(option.votes, fn option -> option.user_id == user_id end)
      assert option.id == option_id
    end

    test "fails to create a vote without a valid user" do
      poll = poll_fixture()
      option = option_fixture(poll.id)

      assert {:error, changeset} =
               Polls.create_vote(%{user_id: nil, poll_id: poll.id, option_id: option.id})

      assert "can't be blank" in errors_on(changeset).user_id
    end

    test "returns error if user has already voted on a poll" do
      %{id: user_id} = user_fixture()
      %{id: poll_id} = poll_fixture(%{user_id: user_id})
      %{id: option_id} = option_fixture(poll_id)

      vote_fixture(user_id, poll_id, option_id)

      assert {:error, :already_voted} =
               Poll.Polls.create_vote(%{user_id: user_id, poll_id: poll_id, option_id: option_id})
    end

    test "returns error if option does not exist" do
      %{id: user_id} = user_fixture()
      %{id: poll_id} = poll_fixture(%{user_id: user_id})

      assert {:error, :option_not_found} =
               Poll.Polls.create_vote(%{user_id: user_id, poll_id: poll_id, option_id: -1})
    end
  end

  describe "voting on a poll" do
  end
end
