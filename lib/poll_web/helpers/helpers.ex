defmodule PollWeb.Helpers do
  def make_usernames_list(votes) do
    votes
    |> Enum.map(fn vote -> extract_username_from_email(vote.user.email) end)
    |> Enum.join(", ")
  end

  def extract_username_from_email(email) when is_binary(email) do
    case String.split(email, "@") do
      [username | _rest] -> username
      _ -> email
    end
  end

  def format_datetime(datetime) do
    Timex.Format.DateTime.Formatter.format!(datetime, "{D} {Mfull} {YYYY}")
  end
end
