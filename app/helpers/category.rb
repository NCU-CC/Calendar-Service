module NCU
   module Category
      module Helpers
         def category_by_name name
            cat = DB::Category.find_by(name: name)
            return nil if cat.nil?
            cat.serializable_hash
         end
         def categories
            cats = DB::Category.all
            cats.each_index do |i|
               cats[i] = cats[i].serializable_hash
               cats[i].delete 'calendar_id'
            end
            cats
         end
      end
   end
end
