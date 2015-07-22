module Calendar
   class V1 < Grape::API
      format :json

      helpers NCU::OAuth::Helpers
      helpers NCU::Event::Helpers
      helpers NCU::Category::Helpers
      helpers do
         @@gcap = nil
         def gcap
            return @@gcap unless @@gcap.nil?
            @@gcap = Gcap.new
         end
         def find_token scope
            this_token = token scope
            error! this_token[:error_message], this_token[:error_code] if this_token.has_key? :error_message
            this_token
         end
      end

      before do
         unless env['REQUEST_PATH'].start_with? '/calendar/v1/doc'
            case env['REQUEST_METHOD']
            when 'GET'
               scope = NCU::OAuth::CALENDAR_READ
            else
               scope = NCU::OAuth::CALENDAR_WRITE
            end
            @this_token = find_token scope
         end
      end

      desc 'Return categories.' do
         success Calendar::Entities::Categories
         headers Authorization: {
                     description: 'Bearer token.',
                     required: true,
                 }
      end
      get :categories do
         {:categories => categories}
      end

      desc 'Return events.' do
         success Calendar::Entities::Events
         headers Authorization: {
                     description: 'Bearer token.',
                     required: true,
                 }
      end
      params do
         requires :from, type: DateTime, desc: 'Lower bound (inclusive) to filter by.'
         requires :to, type: DateTime, desc: 'Upper bound (exclusive) to filter by.'
         optional :limit, type: Integer, default: 5, desc: 'Maximum number of events returned on one result page.'
         optional :page, type: Integer, default: 1, desc: 'Which result page to return.'
         optional :category, type: String, default: nil, desc: 'Category of events to filter by.'
         optional :orderBy, type: String, default: 'start', values: ['start', 'end', 'created', 'updated'], desc: 'The order of the events returned in the result and filter by.'
      end
      get :events do
         unless params[:category].nil?
            category = category_by_name params[:category]
            error! 'invalid_category', 400 if category.nil?
         end
         events = select_events params
         error! 'Not Found', 404 if events.empty?
         {:events => events, :count => events.length, :page => params[:page]}
      end

      resource :event do

         desc 'Creates an event.' do
            success Calendar::Entities::Event
            headers Authorization: {
                        description: 'Bearer token.',
                        required: true,
                    }
         end
         params do
            requires :summary, type: String, desc: 'Title of the event.'
            requires :description, type: String, desc: 'Description of the event.'
            optional :link, type: String, default: nil, desc: 'URL link of the event.'
            requires :location, type: String, desc: 'Geographic location of the event'
            requires :category, type: String, desc: 'Category of the event.'
            requires :start, type: DateTime, desc: 'The start time of the event.'
            requires :end, type: DateTime, desc: 'The end time of the event.'
         end
         post do
            category = category_by_name params[:category]
            error! 'invalid_category', 400 if category.nil?
            result = gcap.insert to_google(params), category['calendar_id']   
            error! result.error_message, result.status if result.error?
            params[:id] = result.data.id
            params[:creator] = @this_token['user']
            insert_event params
         end

         desc 'Updates an event.' do
            success Calendar::Entities::Event
            headers Authorization: {
                        description: 'Bearer token.',
                        required: true,
                    }
         end
         params do
            requires :id, type: String, desc: 'Event identifier.'
            optional :summary, type: String, desc: 'Title of the event.'
            optional :description, type: String, desc: 'Description of the event.'
            optional :link, type: String, desc: 'URL link of the event.'
            optional :location, type: String, desc: 'Geographic location of the event.'
            optional :start, type: DateTime, desc: 'The start time of the event.'
            optional :end, type: DateTime, desc: 'The end time of the event.'
         end
         put do
            event = select_event params[:id]
            error! 'Not Found', 404 if event.nil?
            category = category_by_name event['category']
            get_result = gcap.get params[:id], category['calendar_id']
            error! get_result.error_message, get_result.status if get_result.error?
            params[:description] = event['description'] if params[:description].nil? && !params[:link].nil?
            params[:link] = event['link'] if params[:link].nil? && !params[:description].nil?
            update_result = gcap.update update_google(get_result.data.to_hash, params), category['calendar_id']
            error! update_result.error_message, update_result.status if update_result.error?
            update_event params
         end

         desc 'Deletes an event.' do
            success Calendar::Entities::Event
            headers Authorization: {
                        description: 'Bearer token.',
                        required: true,
                    }
         end
         params do
            requires :id, type: String, desc: 'Event identifier.'
         end
         delete do
            event = select_event params[:id]
            error! 'Not Found', 404 if event.nil?
            category = category_by_name event['category']
            del_result = gcap.delete params[:id], category['calendar_id']
            error! del_result.error_message, del_result.status if del_result.error?
            delete_event params[:id]
         end

         desc 'Returns an event.' do
            success Calendar::Entities::Event
            headers Authorization: {
                        description: 'Bearer token.',
                        required: true,
                    }
         end
         params do
            requires :id, type: String, desc: 'Event identifier.'
         end
         get do
            event = select_event params[:id]
            error! 'Not Found', 404 if event.nil?
            event
         end
      end

      add_swagger_documentation api_version: 'v1',
                                hide_documentation_path: true,
                                hide_format: true,
                                mount_path: '/doc',
                                base_path: "#{Settings::API_URL}/calendar/v1",
                                authorizations: 'test'

   end
end
