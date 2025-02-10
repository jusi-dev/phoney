defmodule PhoneyWeb.ContactsLive.Index do
  use PhoneyWeb, :live_view
  use PhoneyWeb, :verified_routes

  import PhoneyWeb.ContactComponent

  require Ash.Query

  alias Phoney.Contacts.Contact
  alias Phoney.Contacts.Favorite

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> stream(:contacts, [])
      |> stream(:favorites, [])
      |> assign(:page, 1)
      |> assign(:search_term, "")
      |> assign(:selected_contact, nil)
      |> list_contacts()
    }
  end

  defp list_contacts(socket) do
    page = socket.assigns.page
    search_term = socket.assigns[:search_term] || ""

    # Filter contacts by search term or just paginate all contacts
    paginated_contacts = if search_term != "" do
      Contact.search!(search_term, page, 20)
    else
      Contact.paginate_and_sort_by!(:last_name, :asc, page, 20)
    end |> Map.get(:results)

    # Get all contacts to calculate total pages
    total_contacts = if search_term != "" do
      Contact.search!(search_term, 1, 1000000)
      |> Map.get(:results)
    else
      Contact.read!()
    end

    total_contacts_length = total_contacts |> length()
    total_pages = div(total_contacts_length, 20) + if(rem(total_contacts_length, 20) > 0, do: 1, else: 0)

    # Get favorites for all contacts on current page
    favorites = Phoney.Contacts.Favorite
    |> Ash.Query.filter(contact_id: [in: paginated_contacts |> Enum.map(& &1.id)])
    |> Ash.read!(domain: Phoney.Contacts)

    # Convert to set for O(1) lookup
    favorite_contact_ids = favorites |> Enum.map(& &1.contact_id) |> MapSet.new()

    # Add is_favorite field to each contact
    contacts_with_favorites = paginated_contacts |> Enum.map(fn contact ->
      Map.put(contact, :is_favorite, MapSet.member?(favorite_contact_ids, contact.id))
    end)

    favorited_contacts = favorites |> Enum.map(fn favorite ->
      case Contact.get_by_id(favorite.contact_id) do
        {:ok, contact} -> contact
        _ -> nil
      end
    end) |> Enum.filter(& &1)

    socket
    |> assign(:total_pages, total_pages)
    |> stream(:favorites, favorited_contacts)
    |> stream(:contacts, contacts_with_favorites, reset: true)
  end

  def handle_event("search", %{"search" => search_term}, socket) do
    {:noreply,
      socket
      |> assign(:search_term, search_term)
      |> assign(:page, 1)
      |> list_contacts()
    }
  end

  def handle_event("select-contact", %{"contact_id" => "nil"}, socket) do
    {:noreply,
      socket
      |> assign(:selected_contact, nil)
      |> list_contacts()
    }
  end

  def handle_event("select-contact", %{"contact_id" => contact_id}, socket) do
    contact = Phoney.Contacts.Contact
              |> Ash.Query.filter(id: contact_id)
              |> Ash.read!(domain: Phoney.Contacts)
              |> then(fn [contact] -> contact end)

    {:noreply,
      socket
      |> assign(:selected_contact, contact)
      |> list_contacts()
    }
  end

  def handle_event("toggle-favorite", %{"contact_id" => contact_id}, socket) do
    favorites = Phoney.Contacts.Favorite
                        |> Ash.Query.filter(contact_id: contact_id)
                        |> Ash.Query.limit(1)
                        |> Ash.read!(domain: Phoney.Contacts)

    IO.inspect(favorites)

    case favorites do
      [] ->
        Favorite.create!(%{contact_id: contact_id})

      [favorite | _] ->
        Favorite.destroy!(favorite)
    end

    {:noreply,
      socket
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
