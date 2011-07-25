$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require "qu"

head = [["id:int", "pid:int", "ts:long"]]

single_item_csv = CSV.generate do |csv|
  csv << head.first
  csv << [1, 0, 1310084883]
end

test "convert item to CSV" do |item|
  item = Qu::Item.new
  item.id = 1
  item.pid = 0
  item.ts = 1310084883
  assert_equal item.to_csv, single_item_csv
end

test "item from csv" do
  item = Qu::Item.from_csv(single_item_csv)

  assert_equal item.to_csv, single_item_csv
end

test "item from array" do
  item = Qu::Item.from_array(CSV.parse(single_item_csv))

  assert_equal item.to_csv, single_item_csv
end
