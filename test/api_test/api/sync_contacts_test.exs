defmodule Phoney.Api.SyncContactsTest do
  use Phoney.DataCase

  test "upsert contacts from api" do
    upserted_contacts = Phoney.Api.SyncContacts.sync_contacts()

    read_contacts = Phoney.Contacts.Contact |> Phoney.Contacts.read!()

    # assert length of upserted contacts and read contacts
    assert length(upserted_contacts) == length(read_contacts)
  end
end
