defmodule Phoney.Contacts do
  use Ash.Domain

  resources do
    resource Phoney.Contacts.Contact
    resource Phoney.Contacts.Favorite
  end

  def read!(query \\ GistAsh.Gists.Gist, opts \\ []) do
    query
    |> Ash.Query.for_read(:read)
    |> Ash.read!(domain: __MODULE__, actor: Keyword.get(opts, :actor))
  end

  def create!(changeset, opts \\ []) do
    changeset
    |> Ash.create!(domain: __MODULE__, actor: Keyword.get(opts, :actor))
  end

  def destroy!(changeset, opts \\ []) do
    changeset
    |> Ash.destroy!(domain: __MODULE__, actor: Keyword.get(opts, :actor))
  end
end
