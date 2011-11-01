require 'chunk.rb'
require "rubygems"
require 'xmlsimple'
require 'sequel'
require 'sqlite3'

#home
db = Sequel.sqlite('C:\Users\David Cloutier\workspace\Rift-Item-Parser\dump.sqlite3')
#Work
#db = Sequel.sqlite('D:\Users\dcloutier\workspace\Rift_item_parser\dump.sqlite3')

items_table = db[:items]
recipes_table = db[:recipes]

file = Chunk.new('Recipes.xml', { 'element' => 'Recipe' })

i = 0
d = 0
u = 0

start = Time.now

while xml = file.read

  data = XmlSimple.xml_in(xml)

  ## Created Item block ##
  item_generated = data["Creates"]
  item_generated = item_generated[0]["Item"][0]
  quantity = item_generated["Quantity"][0]
  name = item_generated["Name"][0]["English"]
  recipe_itemKey = item_generated["ItemKey"][0]
  requiredSkillPoints = data["RequiredSkillPoints"]
  requiredSkill = data["RequiredSkill"]
  crafted_itemKey = item_generated["ItemKey"]
  rift_id = data["Id"]
  ingredients = data["Ingredients"]
  item_list = ingredients[0]

  items = item_list["Item"]
  items.each do |component|
    item_detail = component
    component_itemkey = item_detail["ItemKey"]
    component_quantity = item_detail["Quantity"]
    component_name = item_detail["Name"][0]["English"]
    if recipes_table.filter(:component_itemkey => component_itemkey, :crafted_itemkey => crafted_itemKey).count == 0 then
      recipes_table.insert(:component_quantity => component_quantity,
      :component_itemkey => component_itemkey,
      :quantity => quantity,
      :requiredskillpoints => requiredSkillPoints,
      :requiredskill => requiredSkill,
      :rift_id => rift_id,
      :name => name,
      :crafted_itemkey => crafted_itemKey)
      p "added component: [#{component_name}] (#{component_itemkey}) x #{component_quantity} for [#{name}] (#{crafted_itemKey}) (recipe : #{rift_id})"
      i += 1
    else
      if recipes_table.filter(:component_itemkey => component_itemkey, :crafted_itemkey => crafted_itemKey).count > 1 then
        recipes_table.filter(:component_itemkey => component_itemkey, :crafted_itemkey => crafted_itemKey).delete
        p "Had duplicated results for [#{component_name}] (#{component_itemkey}) x #{component_quantity} for [#{name}] (#{crafted_itemKey}) (recipe : #{rift_id}) "
        recipes_table.insert(:component_quantity => component_quantity,
        :component_itemkey => component_itemkey,
        :quantity => quantity,
        :requiredskillpoints => requiredSkillPoints,
        :requiredskill => requiredSkill,
        :rift_id => rift_id,
        :name => name,
        :crafted_itemkey => crafted_itemKey)
        p "added component: [#{component_name}] (#{component_itemkey}) x #{component_quantity} for [#{name}] (#{crafted_itemKey}) (recipe : #{rift_id})"
        d += 1
      else
        recipes_table.filter(:component_itemkey => component_itemkey, :crafted_itemkey => crafted_itemKey).update(:component_quantity => component_quantity,
        :component_itemkey => component_itemkey,
        :quantity => quantity,
        :requiredskillpoints => requiredSkillPoints,
        :requiredskill => requiredSkill,
        :rift_id => rift_id,
        :name => name,
        :crafted_itemkey => crafted_itemKey)
        p "Updated recipe : [#{component_name}] (#{component_itemkey}) x #{component_quantity} for [#{name}] (#{crafted_itemKey}) (recipe : #{rift_id})"
        u += 1
      end
    end
  end
end

puts 'I added ' + i.to_s + ' <recipes/>s in there!'
puts 'I cleaned up '+  d.to_s + '<recipes/>s in there!'
puts 'I updated ' + u.to_s + ' <recipes/>s in there!'


endtime = Time.now - start;
puts 'Completed in ' + endtime.to_s + 's';
