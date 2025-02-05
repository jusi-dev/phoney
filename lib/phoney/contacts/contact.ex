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

  identities do
    identity :email, [:email]
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    create :upsert_from_api do
      argument :firstname, :string
      argument :lastname, :string
      argument :email, :string
      argument :phone, :string

      argument :address, :map do
        argument :street, :string
        argument :city, :string
        argument :zipcode, :string
        argument :country, :string
      end

      upsert? true
      upsert_identity :email

      change fn changeset, _context ->
        address = Ash.Changeset.get_argument(changeset, :address)
        formatted_address = "#{address.street}, #{address.city}, #{address.zipcode}, #{address.country}"
        Ash.Changeset.change_attribute(changeset, :address, formatted_address)
      end

      change set_attribute(:first_name, arg(:firstname))
      change set_attribute(:last_name, arg(:lastname))
      change set_attribute(:phone_number, arg(:phone))
      change set_attribute(:email, arg(:email))

      accept [:first_name, :last_name, :email, :phone_number, :address]
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if always()
    end
  end
end
