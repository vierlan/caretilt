# app/services/stripe_event_fetcher.rb
class StripeEventFetcher
  def self.fetch_events(event_types = nil, limit = 10)
    raise
    begin
      # Define parameters for the request
      params = { limit: limit }
      params[:type] = event_types if event_types.present?

      # Fetch events from Stripe's Events API
      events = Stripe::Event.list(params)

      # Collect the events and return them
      fetched_events = []
      raise
      events.auto_paging_each do |event|
        fetched_events << {
          id: event.id,
          type: event.type,
          created: Time.at(event.created),
          data: event.data.object
        }
      end
      fetched_events
    rescue Stripe::StripeError => e
      puts "Error fetching events: #{e.message}"
      []
    end
  end
end
