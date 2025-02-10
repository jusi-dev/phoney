defmodule Phoney.Contacts do
  use Ash.Domain

  resources do
    resource Phoney.Contacts.Contact
    resource Phoney.Contacts.Favorite
  end
end
