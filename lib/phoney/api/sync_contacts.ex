defmodule Phoney.Api.SyncContacts do
  def sync_contacts do
    {:ok, response} = Finch.build(:get, "https://fakerapi.it/api/v2/persons\?_quantity\=100")
                      |> Finch.request(Phoney.Finch)

    decoded_response = Jason.decode!(response.body)

    contacts = decoded_response["data"]

    Enum.map(contacts, &upsert_contact/1)
  end

  defp upsert_contact(contact_data) do
    params = %{
      firstname: contact_data["firstname"],
      lastname: contact_data["lastname"],
      email: contact_data["email"],
      phone: contact_data["phone"],
      address: %{
        street: contact_data["address"]["street"],
        city: contact_data["address"]["city"],
        zipcode: contact_data["address"]["zipcode"],
        country: contact_data["address"]["country"]
      }
    }

    Phoney.Contacts.Contact
    |> Ash.Changeset.for_create(:upsert_from_api, params)
    |> Phoney.Contacts.create!()
  end
end
