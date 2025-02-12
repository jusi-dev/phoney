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
    attribute :user_id, :uuid, public?: true
  end

  relationships do
    belongs_to :contact, Phoney.Contacts.Contact, allow_nil?: false
    belongs_to :user, Phoney.Accounts.User, primary_key?: true, allow_nil?: false
  end

  code_interface do
    define :get_favorite_from_user, action: :get_favorite_from_user, args: [:user_id, :contact_id]
    define :create
    define :destroy
    define :read
  end

  actions do
    defaults [:read, :destroy, create: :*]

    read :get_favorite_from_user do
      argument :user_id, :uuid, allow_nil?: false
      argument :contact_id, :uuid, allow_nil?: false

      filter expr(^arg(:user_id) == ^arg(:user_id) && ^arg(:contact_id) == ^arg(:contact_id))
    end
  end

  # TODO: Implement policies
  policies do
    policy action_type([:read, :create, :update, :destroy]) do
      authorize_if always()
    end
  end
end
