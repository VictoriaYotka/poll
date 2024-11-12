defmodule Poll.PollsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poll.Polls` context.
  """
  import Poll.AccountsFixtures

  def poll_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, poll} =
      attrs
      |> Enum.into(%{
        title: Faker.Lorem.sentence(),
        description: Faker.Lorem.paragraph() |> String.slice(0, 255),
        user_id: user.id
      })
      |> Poll.Polls.create_poll()

    poll
  end

  def option_fixture(poll_id, attrs \\ %{}) do
    {:ok, option} =
      attrs
      |> Enum.into(%{
        text: Faker.Lorem.word(),
        poll_id: poll_id
      })
      |> Poll.Polls.create_option()

    option
  end

  def vote_fixture(user_id, poll_id, option_id) do
    Poll.Polls.create_vote(%{user_id: user_id, poll_id: poll_id, option_id: option_id})
  end
end
