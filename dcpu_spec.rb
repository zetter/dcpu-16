require './dcpu'

describe '#execute' do
  subject { Dcpu.new }
  
  it 'sets A register' do
    subject.load(0x7c01, 0x0030)
    subject.excecute
    subject.storage[0].should == 16
  end
  
  it 'sets B register' do
    subject.load(0x7c01, 0x0030)
    subject.execute
    subject.storage[1] == 16
  end
  
end

describe Dcpu::Storage do
  subject { Dcpu::Storage.new }

  describe '#[] and #[]=' do
    %W{A B C X Y Z I J}.each.with_index do |register, i|
      it "should read and write to #{register}" do
        subject[i] = 17
        subject[i].should == 17
      end
    end

    %W{A B C X Y Z I J}.each.with_index do |register, i|
      it "should read and write to [#{register}]" do
        subject[i] = 18
        location = i + 0x08
        subject[location] = 22
        subject[location].should == 22
      end
    end

    it "should read and write to PC" do
      subject[0x1c] = 17
      subject[0x1c].should == 17
    end

    it "should read and write to SP" do
      subject[0x1b] = 17
      subject[0x1b].should == 17
    end

    it "should read and write to O" do
      subject[0x1d] = 17
      subject[0x1d].should == 17
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