class Gcap
   APPLICATION_NAME = 'Calendar'
   SCOPE = 'https://www.googleapis.com/auth/calendar'

   # Initialize the API
   def initialize
      @client = Google::APIClient.new(:application_name => APPLICATION_NAME)
      @calendar_api = @client.discovered_api('calendar', 'v3')
      @client.authorization = authorize
      @client.authorization.fetch_access_token!
   end

   def authorize
      key = Google::APIClient::KeyUtils.load_from_pkcs12('config/client.p12', 'notasecret')
      Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => SCOPE,
        :issuer => Settings::EMAIL,
        :signing_key => key)
   end

   def insert event, calendar_id
      @client.execute(
         :api_method => @calendar_api.events.insert,
         :parameters => {:calendarId => calendar_id},
         :body_object => event,
         :headers => {'Content-Type' => 'application/json'})
   end

   def update event, calendar_id
      @client.execute(
         :api_method => @calendar_api.events.update,
         :parameters => {'calendarId' => calendar_id, 'eventId' => event['id']},
         :body_object => event,
         :headers => {'Content-Type' => 'application/json'})
   end

   def delete eventId, calendar_id
      @client.execute(
         :api_method => @calendar_api.events.delete,
         :parameters => {'calendarId' => calendar_id, 'eventId' => eventId})
   end

   def get eventId, calendar_id
      @client.execute(
         :api_method => @calendar_api.events.get,
         :parameters => {'calendarId' => calendar_id, 'eventId' => eventId})
   end

   # fetch the next 10 events for testing
   def test calendar_id
      results = @client.execute!(
        :api_method => @calendar_api.events.list,
        :parameters => {
          :calendarId => calendar_id,
          :maxResults => 10,
          :singleEvents => true,
          :orderBy => 'startTime',
          :timeMin => Time.now.iso8601 })

      puts "Upcoming events:"
      puts "No upcoming events found" if results.data.items.empty?
      results.data.items.each do |event|
         puts event.to_json
      end
   end
end

