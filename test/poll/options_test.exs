defmodule Poll.OptionsTest do
  use Poll.DataCase, async: true

  import Poll.PollsFixtures
  # import Poll.AccountsFixtures

  alias Poll.Polls

  describe "create_option/1" do
    test "successfully creates an option for a poll" do
      poll = poll_fixture()
      option = option_fixture(poll.id, %{text: "Option A"})

      assert option.text == "Option A"
      assert option.poll_id == poll.id
    end

    test "fails to create an option with missing text" do
      poll = poll_fixture()

      assert {:error, changeset} = Polls.create_option(%{poll_id: poll.id, text: nil})
      assert "can't be blank" in errors_on(changeset).text
    end

    test "returns error with invalid data" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_option(%{})
    end
  end

  describe "create_options/1" do
    test "creates multiple valid options" do
      %{id: poll_id} = poll_fixture()
      attrs = [%{text: "Option 1", poll_id: poll_id}, %{text: "Option 2", poll_id: poll_id}]
      assert {:ok, :all_inserted} = Polls.create_options(attrs)
    end

    test "returns error if no valid options" do
      attrs = [%{text: "", poll_id: nil}]
      assert {:error, "No valid options"} = Polls.create_options(attrs)
    end
  end

  describe "list_options_by_poll/1" do
    setup do
      poll = poll_fixture(%{title: "General Poll", description: "A poll about general topics"})

      option1 = option_fixture(poll.id, %{text: "Option 1"})
      option2 = option_fixture(poll.id, %{text: "Option 2"})

      unrelated_poll = poll_fixture(%{title: "Unrelated Poll"})
      unrelated_option = option_fixture(unrelated_poll.id, %{text: "Unrelated Option"})

      %{poll: poll, option1: option1, option2: option2, unrelated_option: unrelated_option}
    end

    test "retrieves options by poll ID", %{
      poll: poll,
      option1: option1,
      option2: option2,
      unrelated_option: unrelated_option
    } do
      result = Polls.list_options_by_poll(poll.id)

      assert length(result) == 2
      assert Enum.any?(result, fn opt -> opt.id == option1.id and opt.text == option1.text end)
      assert Enum.any?(result, fn opt -> opt.id == option2.id and opt.text == option2.text end)
      refute Enum.any?(result, fn opt -> opt.id == unrelated_option.id end)
    end

    test "returns an empty list if poll has no options" do
      empty_poll = poll_fixture(%{title: "Empty Poll"})

      result = Polls.list_options_by_poll(empty_poll.id)

      assert result == []
    end
  end
end
