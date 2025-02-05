defmodule PhoneyWeb.ContactsLive.Index do
  use PhoneyWeb, :live_view
  use PhoneyWeb, :verified_routes

  import PhoneyWeb.ContactComponent

  require Ash.Query

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> stream(:contacts, [])
      |> assign(:page, 1)
      |> list_contacts()
    }
  end

  defp list_contacts(socket) do
    page = socket.assigns.page

    total_contacts_query = Phoney.Contacts.Contact
                    |> Phoney.Contacts.read!()

    total_contacts = length(total_contacts_query)

    total_pages = div(total_contacts, 20) + rem(total_contacts, 20)

    query = Phoney.Contacts.Contact
                |> Ash.Query.page(limit: 20, offset: (page - 1) * 20)

    contacts = Ash.Query.sort(query, [last_name: :asc])
                |> Phoney.Contacts.read!()

    socket
    |> assign(:total_pages, total_pages)
    |> stream(:contacts, contacts.results)
  end

  def handle_event("previous-page", _params, socket) do
    new_page = socket.assigns.page - 1
    {:noreply,
      socket
      |> assign(:page, new_page)
      |> list_contacts()
    }
  end

  def handle_event("next-page", _params, socket) do
    new_page = socket.assigns.page + 1
    {:noreply,
      socket
      |> assign(:page, new_page)
      |> list_contacts()
    }
  end
end
