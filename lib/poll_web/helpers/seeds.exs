defmodule Poll.Helpers.Seeds do
  alias Poll.{Accounts, Polls, Repo}
alias Poll.Accounts.User
alias Poll.Polls.Poll
require Logger

  def run do
    user_count = Repo.aggregate(User, :count, :id)

if user_count >= 10 do
  Logger.info("There are already #{user_count} users in the database. No new users created.")
else
  Logger.info("Creating 10 new users...")

  1..10
  |> Enum.each(fn _i ->
    email = Faker.Internet.email()

    Accounts.register_user(%{
      email: email,
      password: email
    })
  end)

  Logger.info("10 new users have been created!")
end

# Creating polls
poll_count = Repo.aggregate(Poll, :count, :id)

if poll_count >= 10 do
  Logger.info("There are already #{poll_count} polls in the database. No new polls created.")
else
  Logger.info("Creating 10 new polls...")

  1..10
  |> Enum.each(fn _i ->
    users = Accounts.list_users()

    title = Faker.Lorem.sentence()
    description = Faker.Lorem.paragraph() |> String.slice(0, 255)
    inserted_at = Faker.DateTime.backward(7)

    {:ok, poll} =
      Polls.create_poll(%{
        title: title,
        description: description,
        user_id: Enum.random(users).id,
        inserted_at: inserted_at,
        updated_at: inserted_at
      })

    1..Enum.random(2..5)
    |> Enum.each(fn _j ->
      option_text = Faker.Lorem.word()
      Polls.create_option(%{text: option_text, poll_id: poll.id})
    end)
  end)

  Logger.info("10 new polls have been created!")
end

# Assigning random votes
Logger.info("Assigning random votes...")

polls = Repo.all(Poll)
users = Accounts.list_users()

Enum.each(polls, fn poll ->
  users_for_poll = Enum.take_random(users, Enum.random(1..10))

  Enum.each(users_for_poll, fn user ->
    unless Polls.has_user_voted?(user.id, poll.id) do
      option = Polls.get_random_option_for_poll(poll.id)

      Polls.create_vote(%{
        user_id: user.id,
        poll_id: poll.id,
        option_id: option.id
      })
    end
  end)
end)

Logger.info("Random votes have been assigned!")

  end
end
