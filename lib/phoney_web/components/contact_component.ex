defmodule PhoneyWeb.ContactComponent do
  use Phoenix.Component

  attr :contact, :map, required: true

  def contact_list_item(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-center gap-x-2 bg-gray-100 px-4 py-6 rounded-lg">
        <div><%= @contact.first_name%></div>
        <div class="font-bold"><%= @contact.last_name%></div>
      </div>
    </div>
    """
  end
end
