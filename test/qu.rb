$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require "qu"

db = Bandicoot.new

head = [["id:int", "pid:int", "ts:long"]]

list_csv = CSV.generate do |csv|
  csv << head.first
  csv << [1, 0, 1310084883]
  csv << [2, 0, 1310084888]
end

list = CSV.parse(list_csv)

single_item_csv = CSV.generate do |csv|
  csv << head.first
  csv << [1, 0, 1310084883]
end

prepare do
  db.get(:clear)
end

setup do
  Qu.new(db)
end

test "fetch an item from the queue" do |qu|
  db.post(:push, list_csv)

  item = qu.fetch

  assert_equal item.id,   1
  assert_equal item.pid,  Process.pid
  assert_equal item.ts,   1310084883

  assert_equal qu.list.size, 3

  qu.finish(item)

  assert_equal qu.list.size, 2
end

test "return in process items" do |qu|
  db.post(:push, list_csv)

  assert_equal qu.in_process.size, 1

  item1 = qu.fetch

  assert_equal qu.in_process.size, 2

  item2 = qu.fetch

  assert_equal qu.in_process.size, 3

  qu.finish(item1)
  qu.finish(item2)

  assert_equal qu.in_process.size, 1
end

test "don't push the same item twice with push" do |qu|
  db.post(:push, single_item_csv)

  assert_equal db.get(:list), CSV.parse(single_item_csv)

  item = qu.fetch

  assert_equal db.get(:list), CSV.parse(item.to_csv)

  db.post(:push, single_item_csv)

  assert_equal db.get(:list), CSV.parse(item.to_csv)
end
