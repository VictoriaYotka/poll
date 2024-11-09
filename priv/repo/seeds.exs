# mix run priv/repo/seeds.exs

alias Poll.{Accounts, Polls, Repo}
alias Poll.Accounts.User
alias Poll.Polls.Poll
require Logger

# Creating users
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
    description = Faker.Lorem.paragraph()

    {:ok, poll} =
      Polls.create_poll(%{
        title: title,
        description: description,
        user_id: Enum.random(users).id
      })

    1..4
    |> Enum.each(fn _j ->
      option_text = Faker.Lorem.word()
      Polls.create_option(%{text: option_text, poll_id: poll.id})
    end)
  end)

  Logger.info("10 new polls have been created!")
end
