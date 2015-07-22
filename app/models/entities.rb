module Calendar
   module Entities
      class Event < Grape::Entity
         expose :id, documentation: {type: 'string', desc: 'Event identifier.', required: true}
         expose :created, documentation: {type: 'string', format: 'date-time', desc: 'Creation time of the event.', required: true}
         expose :updated, documentation: {type: 'string', format: 'date-time', desc: 'Last modification time of the event.', required: true}
         expose :summary, documentation: {type: 'string', desc: 'Title of the event.', required: true}
         expose :description, documentation: {type: 'string', desc: 'Description of the event.', required: true}
         expose :location, documentation: {type: 'string', desc: 'Geographic location of the event.', required: true}
         expose :category, documentation: {type: 'string', desc: 'Category of the event', required: true}
         expose :start, documentation: {type: 'string', format: 'date-time', desc: 'The start time of the event.', required: true}
         expose :end, documentation: {type: 'string', format: 'date-time', desc: 'The end time of the event.', required: true}
         expose :link, documentation: {type: 'string', desc: 'URL link of the event.'}
      end

      class Events < Grape::Entity
         expose :events, using: Event, documentation: {is_array: true, required: true}
         expose :count, documentation: {type: 'integer', desc: 'Number of events', required: true}
         expose :page, documentation: {type: 'integer', desc: 'Page number of events.', required: true}
      end

      class Category < Grape::Entity
         expose :id, documentation: {type: 'integer', desc: 'Category identifier.', required: true}
         expose :name, documentation: {type: 'string', desc: 'Name of ategory.', required: true}
         expose :calendar_id, documentation: {type: 'string', desc: 'Calendar identifier of Google Calendar.', required: true}
      end

      class Categories < Grape::Entity
         expose :categories, using: Category, documentation: {is_array: true, required: true}
      end
   end
end
