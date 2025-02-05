defmodule Phoney.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :phone_number, :string
      add :address, :string

      timestamps()
    end

    create unique_index(:contacts, [:email])
  end
end
