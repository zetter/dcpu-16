require './dcpu'

describe '#execute' do
  subject { Dcpu.new }
  
  it 'sets A register' do
    subject.execute(0x7c01, 0x0030)
    subject.a.should == 16
  end
  
  it 'sets B register' do
    subject.execute(0x7c01, 0x0030)
    subject.b.should == 16
  end
  
end

describe Dcpu::Storage do
  subject { Dcpu::Storage.new }
  
  describe '#read and #write' do
    it 'should handle registers'
      subject['0x00'] = 17
      subject['0x00'].should == 17
    end
  end
end

describe Dcpu::Instruction do
  describe '#opcode' do
    it 'returns the opcode' do
      i = Dcpu::Instruction.new(0x7c01)
      i.opcode.should == 0x01
    end
  end
  describe '#a' do
    it 'returns part a' do
      i = Dcpu::Instruction.new(0x7c01)
      i.a.should == 0x00
    end
  end
  
end