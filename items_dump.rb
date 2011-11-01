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

file = Chunk.new('Items.xml', { 'element' => 'Item' })

i = 0
z = 0
u = 0
start = Time.now

while xml = file.read

  data = XmlSimple.xml_in(xml)
  #p data
  itemKey = data["ItemKey"]
  name = data["Name"]
  name = name[0]["English"]
  value = data["Value"]
  isAugmented = data["IsAugmented"]
  rarity = data["Rarity"]
  isSoulboundTrigger = data["SoulboundTrigger"]
  itemRequiredLevel = data["RequiredLevel"]
  runebreakSkillLevel = data["RunebreakSkillLevel"]
  icon = data["Icon"]
  requiredLevel = data["RequiredLevel"]
  isAugmented = data["IsAugmented"]
  riftGem = data["RiftGem"]
  salvageSkill = data["SalvageSkill"]
  salvageSkillLevel = data["SalvageSkillLevel"]

  # p "item_id_rift => #{itemKey}, name => #{name}, value => #{value}, rarity => #{rarity}, RunebreakSkillLevel=> #{runebreakSkillLevel}, icon => #{icon}, requiredLevel => #{requiredLevel}, isSoulboundTrigger => #{isSoulboundTrigger}, isAugmented => #{isAugmented}, riftGem => #{riftGem}, salvageSkill => #{salvageSkill}, salvageSkillLevel => #{salvageSkillLevel}"
  #halt
  if items_table.filter(:ItemKey => "#{itemKey}").count == 0 then
    items_table.insert(:ItemKey => "#{itemKey}", :Name => "#{name}", :Value => "#{value}", :Rarity => "#{rarity}", :Icon => "#{icon}", :RequiredLevel => "#{requiredLevel}", :SoulboundTrigger => "#{isSoulboundTrigger}", :isAugmented => "#{isAugmented}", :RiftGem => "#{riftGem}", :salvageSkill => "#{salvageSkill}", :salvageSkillLevel => "#{salvageSkillLevel}", :RunebreakSkillLevel=> "#{runebreakSkillLevel}")
    i += 1
    p "#{i} - #{name}: was inserted"
  else
    if items_table.filter(:ItemKey => "#{itemKey}").count > 1 then
      p "#{z} - There were some duplicates of #{name}: cleanup was needed"
      items_table.filter(:ItemKey => "#{itemKey}").delete
      items_table.insert(:ItemKey => "#{itemKey}", :Name => "#{name}", :Value => "#{value}", :Rarity => "#{rarity}", :Icon => "#{icon}", :RequiredLevel => "#{requiredLevel}", :SoulboundTrigger => "#{isSoulboundTrigger}", :isAugmented => "#{isAugmented}", :RiftGem => "#{riftGem}", :salvageSkill => "#{salvageSkill}", :salvageSkillLevel => "#{salvageSkillLevel}", :RunebreakSkillLevel=> "#{runebreakSkillLevel}")
    z += 1
    else
      p "#{u} - #{name}: was updated"
      items_table.filter(:ItemKey => "#{itemKey}").update(:ItemKey => "#{itemKey}", :Name => "#{name}", :Value => "#{value}", :Rarity => "#{rarity}", :Icon => "#{icon}", :RequiredLevel => "#{requiredLevel}", :SoulboundTrigger => "#{isSoulboundTrigger}", :isAugmented => "#{isAugmented}", :RiftGem => "#{riftGem}", :salvageSkill => "#{salvageSkill}", :salvageSkillLevel => "#{salvageSkillLevel}", :RunebreakSkillLevel=> "#{runebreakSkillLevel}")
    u += 1
    end
  end
end

puts 'I added ' + i.to_s + ' <items/>s in there!'
puts 'I removed ' + z.to_s + ' duplicated <items/>s in there!'
puts 'I updated ' + u.to_s + ' <items/>s in there!'
endtime = Time.now - start;

puts 'Completed in ' + endtime.to_s + 's';
