class ContactsController < MbuilderApplicationController
  add_breadcrumb 'Address book'
  set_application_tab :address_book

  def index
    from = application.logs.pluck 'distinct message_from'
    to = application.logs.pluck 'distinct message_to'
    @contacts = Set.new.merge(from).merge(to).reject(&:nil?).map(&:without_protocol)
  end

  def show
  end
end
