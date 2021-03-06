module NCU
   module Event
      module Helpers
         def to_google event
            link = event[:link].nil? ? '' : event[:link] + "\n"
            g_event = {
               'summary' => event[:summary],
               'description' => @this_token['unit'] + '-' + @this_token['name'] + "\n" + link + event[:description],
               'location' => event[:location],
               'start' => { 'dateTime' => event[:start].to_s },
               'end' => { 'dateTime' => event[:end].to_s }
            }
            g_event['source'] = { 'url' => event[:link] } unless event[:link].nil?
            g_event
         end

         def update_google g_event, event
            link = event[:link].nil? ? '' : event[:link] + "\n"
            event.each do |key, value|
               case key
               when 'summary', 'location'
                  g_event[key] = value
               when 'start', 'end'
                  g_event[key] = { 'dateTime' => value.to_s }
               when 'link'
                  g_event['source'] = { 'url' => value }
               when 'description'
                  g_event[key] = @this_token['unit'] + '-' + @this_token['name'] + "\n" + link + value
               end
            end
            g_event
         end

         def db_to_hash db_event
            unless db_event.nil?
               event = db_event.serializable_hash
               event.delete 'creator'
               event['id'] = event['event_id']
               event.delete 'event_id'
               event
            end
         end

         def update_event event
            db_event = DB::Event.find_by(event_id: event[:id])
            unless db_event.nil?
               db_event.summary = event[:summary] unless event[:summary].nil?
               db_event.description = event[:description] unless event[:description].nil?
               db_event.location = event[:location] unless event[:location].nil?
               db_event.start = event[:start].to_s unless event[:start].nil?
               db_event.end = event[:end].to_s unless event[:end].nil?
               db_event.link = event[:link] unless event[:link].nil?
               db_event.save
            end
            db_to_hash db_event
         end

         def insert_event event
            db_event = DB::Event.new
            db_event.event_id = event[:id]
            db_event.summary = event[:summary]
            db_event.description = event[:description]
            db_event.location = event[:location]
            db_event.creator = event[:creator]
            db_event.category = event[:category]
            db_event.start = event[:start].to_s
            db_event.end = event[:end].to_s
            db_event.link = event[:link] unless event[:link].nil?
            db_event.save
            db_to_hash db_event
         end

         def select_event id
            db_event = DB::Event.find_by({event_id: id, creator: @this_token['user']})
            return nil if db_event.nil?
            db_to_hash db_event
         end

         def delete_event id
            db_event = DB::Event.find_by({event_id: id, creator: @this_token['user']})
            event = db_to_hash db_event
            db_event.destroy unless db_event.nil?
            event
         end

         def select_events cond
            if cond[:category].nil?
               db_events = DB::Event.where(creator: @this_token['user']).order(params[:orderBy]).where(params[:orderBy] => params[:from]...params[:to]).page(cond[:page]).per(cond[:limit]) 
            else
               db_events = DB::Event.where(creator: @this_token['user']).where(category: cond[:category]).order(params[:orderBy]).where(params[:orderBy] => params[:from]...params[:to]).page(cond[:page]).per(cond[:limit]) 
            end
            db_events.each_index do |i|
               db_events[i] = db_to_hash db_events[i]
            end
         end
      end
   end
end
