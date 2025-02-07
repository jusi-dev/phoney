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

    attribute :first_name, :string, public?: true
    attribute :last_name, :string, public?: true
    attribute :email, :string, public?: true
    attribute :phone_number, :string, public?: true
    attribute :address, :string, public?: true

    timestamps()
  end

  code_interface do
    define :upsert, action: :upsert
  end

  identities do
    identity :email, [:email]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    create :upsert do
      argument :firstname, :string
      argument :lastname, :string
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
        street  = Map.get(address, "street")  || Map.get(address, :street)
        city    = Map.get(address, "city")    || Map.get(address, :city)
        zipcode = Map.get(address, "zipcode") || Map.get(address, :zipcode)
        country = Map.get(address, "country") || Map.get(address, :country)
        formatted_address = "#{street}, #{city}, #{zipcode}, #{country}"
        Ash.Changeset.change_attribute(changeset, :address, formatted_address)
      end

      change set_attribute(:first_name, arg(:firstname))
      change set_attribute(:last_name, arg(:lastname))
      change set_attribute(:phone_number, arg(:phone))

      accept [:email]
    end
  end

  # TODO: Implement authorization logic but for now allow everything
  policies do
    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end
end
