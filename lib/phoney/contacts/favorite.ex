defmodule Phoney.Contacts.Favorite do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Phoney.Contacts,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "favorites"
    repo Phoney.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :contact_id, :uuid
    timestamps()
  end

  relationships do
    belongs_to :contact, Phoney.Contacts.Contact
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      argument :contact_id, :uuid

      change set_attribute(:contact_id, arg(:contact_id))

      accept [:contact_id]
    end
  end

  # TODO: Implement policies
  policies do
    policy action_type([:read, :create, :update, :destroy]) do
      authorize_if always()
    end
  end
end
