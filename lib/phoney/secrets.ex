defmodule Phoney.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Phoney.Accounts.User, _opts) do
    Application.fetch_env(:phoney, :token_signing_secret)
  end
end
