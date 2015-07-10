module Calendar
   class V1 < Grape::API
      version 'v1', using: :path
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
         case env['REQUEST_METHOD']
         when 'GET'
            scope = NCU::OAuth::CALENDAR_READ
         else
            scope = NCU::OAuth::CALENDAR_WRITE
         end
         @this_token = find_token scope
      end

      get :categories do
         categories
      end

      params do
         requires :from, type: DateTime
         requires :to, type: DateTime
         optional :limit, type: Integer, default: 5
         optional :next, type: Integer, default: nil
      end
      get :events do
         events = select_events params
         error! 'Not Found', 404 if events.empty?
         next_id = nil
         next_id = event.pop.id if events.length > params[:limit]
         {:events => events, :count => events.length, :next => next_id}
      end

      resource :event do

         params do
            requires :summary, type: String
            requires :description, type: String
            optional :link, type: String, default: nil
            requires :location, type: String
            requires :category, type: String
            requires :start, type: DateTime
            requires :end, type: DateTime
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

         params do
            requires :id, type: String
            optional :summary, type: String
            optional :description, type: String
            optional :link, type: String
            optional :location, type: String
            optional :start, type: DateTime
            optional :end, type: DateTime
         end
         put do
            event = select_event params[:id]
            error! 'Not Found', 404 if event.nil?
            category = category_by_name event['category']
            get_result = gcap.get params[:id], category['calendar_id']
            error! get_result.error_message, get_result.status if get_result.error?
            update_result = gcap.update update_google(get_result.data.to_hash, params), category['calendar_id']
            error! update_result.error_message, update_result.status if update_result.error?
            update_event params
         end

         params do
            requires :id, type: String
         end
         delete do
            event = select_event params[:id]
            error! 'Not Found', 404 if event.nil?
            category = category_by_name event['category']
            del_result = gcap.delete params[:id], category['calendar_id']
            error! del_result.error_message, del_result.status if del_result.error?
            delete_event params[:id]
         end

         params do
            requires :id, type: String
         end
         get do
            event = select_event params[:id]
            error! 'Not Found', 404 if event.nil?
            event
         end
      end
   end
end
