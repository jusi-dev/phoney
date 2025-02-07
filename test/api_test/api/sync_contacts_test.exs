defmodule Phoney.Api.SyncContactsTest do
  use Phoney.DataCase

  alias Phoney.Contacts.Contact

  # test "upsert contacts from api" do
  #   upserted_contacts = Phoney.Api.SyncContacts.sync_contacts()

  #   read_contacts = Phoney.Contacts.Contact |> Phoney.Contacts.read!()

  #   # assert length of upserted contacts and read contacts
  #   assert length(upserted_contacts) == length(read_contacts)
  # end

  test "creation of a contact" do
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
    assert contact.id != nil
    assert contact.first_name == "John"
    assert contact.last_name == "Doe"
    assert contact.email == "K5H3O@example.com"
    assert contact.phone_number == "1234567890"
    assert contact.address == "123 Main St, Lausanne, 12345, Switzerland"
  end
end
