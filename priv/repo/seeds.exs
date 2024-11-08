
# mix run priv/repo/seeds.exs
alias Poll.Accounts
alias Poll.Accounts.User
require Logger

# creating users
user_count = Poll.Repo.aggregate(User, :count, :id)

if user_count >= 10 do
  Logger.info("There are already #{user_count} users in the database. No new users created.")
else
  # Create users if there are fewer than 10
  Logger.info("Creating 10 new users...")

  1..10
  |> Enum.each(fn _i ->
    email = Faker.Internet.email()
    password = email

    Accounts.register_user(%{
      email: email,
      password: password
    })
  end)

  Logger.info("10 new users have been created!")
end
