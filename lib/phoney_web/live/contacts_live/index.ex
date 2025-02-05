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
      |> assign(:search_term, "")
      |> list_contacts()
    }
  end

  defp list_contacts(socket) do
    page = socket.assigns.page
    search_term = socket.assigns[:search_term] || ""

    base_query = Phoney.Contacts.Contact

    query = if search_term != "" do
      filter_contacts(base_query, search_term)
    else
      base_query
    end

    # Get total count from paginated results
    contacts_page = query
      |> Ash.Query.sort(last_name: :asc)
      |> Phoney.Contacts.read!()

    total_contacts = contacts_page |> length()
    total_pages = div(total_contacts, 20) + if(rem(total_contacts, 20) > 0, do: 1, else: 0)

    # Get paginated results
    paginated_contacts = query
      |> Ash.Query.page(limit: 20, offset: (page - 1) * 20)
      |> Ash.Query.sort(last_name: :asc)
      |> Phoney.Contacts.read!()
      |> Map.get(:results)

    socket
    |> assign(:total_pages, total_pages)
    |> stream(:contacts, paginated_contacts, reset: true)
  end

  defp filter_contacts(query, search_term) do
    query
    |> Ash.Query.filter(
      or: [
        {:first_name, contains: search_term},
        {:last_name, contains: search_term},
        {:phone_number, contains: search_term}
      ]
    )
  end

  def handle_event("search", %{"search" => search_term}, socket) do
    {:noreply,
      socket
      |> assign(:search_term, search_term)
      |> assign(:page, 1)
      |> list_contacts()
    }
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
