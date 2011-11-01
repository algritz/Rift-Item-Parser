require "rubygems"
require 'sequel'
require 'sqlite3'

#home
dbsource = Sequel.sqlite('C:\Users\David Cloutier\workspace\Rift-Item-Parser\dump.sqlite3')
dbdestination = Sequel.sqlite('C:\Users\David Cloutier\workspace\RIFT-Auction-Management\db\development.sqlite3')
#Work
#dbsource = Sequel.sqlite('D:\Users\dcloutier\workspace\Rift_item_parser\dump.sqlite3')
#dbdestination = Sequel.sqlite('D:\Users\dcloutier\workspace\RIFT-Auction-Management\db\development.sqlite3')

source_items_table = dbsource[:items]
destination_items_table = dbdestination[:items]

source_recipe_table = dbsource[:recipes]
destination_recipe_table = dbdestination[:crafted_items]
start = Time.now

i = 0
d = 0
u = 0

source_recipe_table.each do |recipe|
  if destination_recipe_table.filter(:crafted_item_generated_id => recipe[:crafted_itemkey], :component_item_id => recipe[:component_itemkey]).count == 0 then
    destination_recipe_table.insert(:name => recipe[:name],
    :crafted_item_generated_id => recipe[:crafted_itemkey],
    :crafted_item_stacksize => recipe[:Quantity],
    :component_item_id => recipe[:component_itemkey],
    :component_item_quantity => recipe[:component_quantity],
    :required_skill => recipe[:requiredSkill],
    :required_skill_point => recipe[:requiredSkillPoints],
    :rift_id => recipe[:rift_id]
    )
    p "#{i} - Component for: #{recipe[:name]} added"
    i += 1
  else
    if destination_recipe_table.filter(:crafted_item_generated_id => recipe[:crafted_itemkey], :component_item_id => recipe[:component_itemkey]).count > 1 then
      p "#{d} - Component for: #{recipe[:name]} present more than 1 time, cleanup needed"
    d+=1
    else
      destination_recipe_table.filter(:crafted_item_generated_id => recipe[:crafted_itemkey], :component_item_id => recipe[:component_itemkey]).update(:name => recipe[:name],
      :crafted_item_generated_id => recipe[:crafted_itemkey],
      :crafted_item_stacksize => recipe[:Quantity],
      :component_item_id => recipe[:component_itemkey],
      :component_item_quantity => recipe[:component_quantity],
      :required_skill => recipe[:requiredSkill],
      :required_skill_point => recipe[:requiredSkillPoints],
      :rift_id => recipe[:rift_id])
      p "#{u}- Component for: #{recipe[:name]} updated"
    u +=1
    end
  end
end


puts 'I added ' + i.to_s + ' <recipes/>s in there!'
puts 'I removed ' + d.to_s + ' duplicated <recipes/>s in there!'
puts 'I updated ' + u.to_s + ' <recipes/>s in there!'

endtime = Time.now - start;
puts 'Completed in ' + endtime.to_s + 's';
