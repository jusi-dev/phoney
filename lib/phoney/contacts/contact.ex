defmodule Phoney.Contacts.Contact do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Phoney.Contacts,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "contacts"
    repo Phoney.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :email, :string
    attribute :phone_number, :string
    attribute :address, :string
    timestamps()
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end
end
