defmodule Phoney.Accounts do
  use Ash.Domain, otp_app: :phoney, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Phoney.Accounts.Token
    resource Phoney.Accounts.User
  end
end
