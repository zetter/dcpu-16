require './dcpu'

describe '#execute' do
  subject { Dcpu.new }
  
  it 'sets A register' do
    subject.execute(0x7c010030)
    subject.a.should == 16
  end
end

describe Dcpu::Instruction do
  describe '#opcode' do
    it 'returns the opcode' do
      i = Dcpu::Instruction.new(0x7c010030)
      i.opcode.should == 0x01
    end
  end
end