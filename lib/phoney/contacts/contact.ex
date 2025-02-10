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
    define :read
    define :create
    define :get_all_and_sort_by, action: :sort_by, args: [:sort_by, :direction]
    define :paginate_and_sort_by, action: :paginate_and_sort_by, args: [:sort_by, :direction, :page, :page_size]
    define :get_all_by, action: :get_all_by, args: [:filter_by, :filter_value]
    define :get_by_id, action: :read, get_by: [:id]
    define :search, action: :search_contacts, args: [:search_term, :page, :page_size]
  end

  identities do
    identity :email, [:email]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    read :sort_by do
      argument :sort_by, :atom, allow_nil?: true, default: :last_name
      argument :direction, :atom, allow_nil?: true, default: :asc

      prepare fn query, _context ->
        Ash.Query.sort(query, last_name: :asc)
      end
    end

    read :paginate_and_sort_by do
      argument :sort_by, :atom, allow_nil?: true, default: :last_name
      argument :direction, :atom, allow_nil?: true, default: :asc
      argument :page, :integer, allow_nil?: false, default: 1
      argument :page_size, :integer, allow_nil?: false, default: 20
      pagination offset?: true, keyset?: true, required?: false

      prepare fn query, context ->
        # Get actual values from arguments
        page = Ash.Query.get_argument(query, :page)
        page_size = Ash.Query.get_argument(query, :page_size)
        sort_by = Ash.Query.get_argument(query, :sort_by)

        query
        |> Ash.Query.page(limit: page_size, offset: (page - 1) * page_size)
        |> Ash.Query.sort([{sort_by, :asc}])
      end
    end

    read :get_all_by do
      argument :filter_by, :atom, allow_nil?: false
      argument :filter_value, :string, allow_nil?: false

      filter expr(^arg(:filter_by) == ^arg(:filter_value))
    end

    read :search_contacts do
      argument :search_term, :string, allow_nil?: false
      argument :page, :integer, allow_nil?: false, default: 1
      argument :page_size, :integer, allow_nil?: true, default: 20

      pagination offset?: true,
            keyset?: false,
            required?: true,
            default_limit: 20

      filter expr(
        or: [
              {:first_name, contains: ^arg(:search_term)},
              {:last_name, contains: ^arg(:search_term)},
              {:phone_number, contains: ^arg(:search_term)}
            ]
      )
    end

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
