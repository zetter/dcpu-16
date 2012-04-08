require 'storage_constants'
require 'instruction_constants'
require 'word'
require 'storage'
require 'executor'

class Dcpu
  def initalize
    @storage = Storage.new
    @executor = Executor.new(storage)
  end

  def load(*args)
    storage.load(*args)
  end
end

