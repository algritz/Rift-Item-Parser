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
start = Time.now

i = 0
d = 0
u = 0

source_items_table.each do |item|
  if destination_items_table.filter(:itemKey => item[:ItemKey]).count == 0 then
    destination_items_table.insert(:description => item[:Name],
    :vendor_buying_price => item[:Value],
    :item_level => item[:RequiredLevel],
    :itemKey => item[:ItemKey],
    :rarity => item[:Rarity],
    :icon => item[:Icon],
    :soulboundtrigger => item[:SoulboundTrigger],
    :riftgem => item[:RiftGem],
    :salvageskill => item[:SalvageSkill],
    :salvageskilllevel => item[:SalvageSkillLevel],
    :runebreakskilllevel => item[:RunebreakSkillLevel],
    :isAugmented => item[:isAugmented])
    p "#{i} - #{item[:Name]} added"
  i += 1
  else
    if destination_items_table.filter(:itemKey => item[:ItemKey]).count > 1 then
      p "#{d} - #{item[:Name]} present more than 1 time, cleanup needed"
    d+=1
    else
      destination_items_table.filter(:itemKey => item[:ItemKey]).update(:description => item[:Name],
      :vendor_buying_price => item[:Value],
      :item_level => item[:RequiredLevel],
      :itemKey => item[:ItemKey],
      :rarity => item[:Rarity],
      :icon => item[:Icon],
      :soulboundtrigger => item[:SoulboundTrigger],
      :riftgem => item[:RiftGem],
      :salvageskill => item[:SalvageSkill],
      :salvageskilllevel => item[:SalvageSkillLevel],
      :runebreakskilllevel => item[:RunebreakSkillLevel],
      :isAugmented => item[:isAugmented])
      p "#{u} - #{item[:Name]} updated"
    u +=1
    end
  end

end


puts 'I added ' + i.to_s + ' <items/>s in there!'
puts 'I removed ' + d.to_s + ' duplicated <items/>s in there!'
puts 'I updated ' + u.to_s + ' <items/>s in there!'

endtime = Time.now - start;
puts 'Completed in ' + endtime.to_s + 's';
