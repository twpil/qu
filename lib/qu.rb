require "qu/bandicoot"

class Qu
  attr :db

  def initialize(db)
    @db = db
  end

  def push(item)
    db.post(:push, item.to_csv)
  end

  def finish(item)
    db.post(:delete, item.to_csv)
  end

  def fetch
    process = CSV.generate do |csv|
      csv << ["pid:int"]
      csv << [Process.pid]
    end

    Item.from_array(db.post(:fetch, process))
  end

  def list
    db.get(:list)
  end

  def in_process
    db.get(:in_process)
  end

  class Item < Bandicoot::Rel
    field :id, :int
    field :pid, :int
    field :ts, :long
  end
end

