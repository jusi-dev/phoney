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
    attribute :contact_id, :uuid, public?: true
    timestamps()
  end

  relationships do
    belongs_to :contact, Phoney.Contacts.Contact
  end

  code_interface do
    define :get_all_by, action: :get_all_by, args: [:filter_by, :filter_value]
    define :create
    define :destroy
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    # create :create do
    #   primary? true

    #   change set_attribute(:contact_id, arg(:contact_id))

    #   accept [:contact_id]
    # end

    read :get_all_by do
      argument :filter_by, :atom, allow_nil?: false
      argument :filter_value, :string, allow_nil?: false

      filter expr(^arg(:filter_by) == ^arg(:filter_value))
    end
  end

  # TODO: Implement policies
  policies do
    policy action_type([:read, :create, :update, :destroy]) do
      authorize_if always()
    end
  end
end
