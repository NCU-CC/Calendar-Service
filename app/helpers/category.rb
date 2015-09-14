module NCU
   module Category
      module Helpers
         @@categories = nil
         @@cats = nil

         def category_by_name name
            return cats[name] unless cats[name].nil?
            nil
         end

         def cats
            return @@cats unless @@cats.nil?
            cats = Hash.new
            categories.each do |cat|
               cats[cat['name']] = cat
            end
            @@cats = cats
         end

         def categories
            return @@categories unless @@categories.nil?
            cats = DB::Category.all
            cats.each_index do |i|
               cats[i] = cats[i].serializable_hash
            end
            @@categories = cats
         end
      end
   end
end
