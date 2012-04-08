require './lib/dcpu'

module DcpuTestHelper
  include StorageConstants
  include InstructionConstants  

  def build_word(b, a, o)
    Word.new(b << 10 | a << 4 | o)
  end

  def literal(x)
    x + LITERALS.begin
  end
end