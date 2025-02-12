defmodule Contacts.AddFavoriteTest do
  use Phoney.DataCase

  alias Phoney.Contacts.Contact
  alias Phoney.Contacts.Favorite
  alias Phoney.Accounts.User

  test "add favorite for user" do
    {:ok, user} = User.register_with_password("user@mail.com", "password", "password", actor: nil)

    IO.inspect(user)

    contact_params = %{
      "firstname" => "John",
      "lastname" => "Doe",
      "email" => "K5H3O@example.com",
      "phone" => "1234567890",
      "address" => %{
        "street" => "123 Main St",
        "city" => "Lausanne",
        "zipcode" => "12345",
        "country" => "Switzerland"
      }
    }

    assert {:ok, contact} = Contact.upsert(contact_params)

    IO.inspect(contact.id)

    assert {:ok, favorite} = Favorite.create(%{contact_id: contact.id, user_id: user.id})
                              |> Ash.load(:contact)

    IO.inspect(favorite)

    assert favorite.contact.first_name == "John"
end
end
