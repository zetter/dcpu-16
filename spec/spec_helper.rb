require './lib/dcpu'

module DcpuTestHelper
  include StorageConstants
  include InstructionConstants  

  def build_instruction(b, a, o)
    Instruction.new(b << 10 | a << 4 | o)
  end

  def literal(x)
    x + LITERALS.begin
  end
end