defmodule Phoney.Repo.Migrations.CreateFavorites do
  use Ecto.Migration

  def change do
    create table(:favorites, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :contact_id, :uuid

      timestamps()
    end
  end
end
