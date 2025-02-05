defmodule Phoney.Contacts do
  use Ash.Domain

  resources do
    resource Phoney.Contacts.Contact
  end

  def read!(query \\ GistAsh.Gists.Gist, opts \\ []) do
    query
    |> Ash.Query.for_read(:read)
    |> Ash.read!(domain: __MODULE__, actor: Keyword.get(opts, :actor))
  end
end
