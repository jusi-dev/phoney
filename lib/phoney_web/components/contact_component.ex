defmodule PhoneyWeb.ContactComponent do
  use Phoenix.Component

  attr :contact, :map, required: true
  attr :is_favorite, :boolean, required: true

  def contact_list_item(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-center gap-x-2 bg-gray-100 px-4 py-6 rounded-lg cursor-pointer hover:bg-gray-300" phx-click="select-contact" phx-value-contact_id={@contact.id}>
        <div><%= @contact.first_name%></div>
        <div class="font-bold"><%= @contact.last_name%></div>
        <div phx-click="toggle-favorite" phx-value-contact_id={@contact.id}>
          <%= if @is_favorite do %>
            <p class="hover:text-yellow-700 text-yellow-400">★</p>
          <% else %>
            <p class="hover:text-yellow-400">☆</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
