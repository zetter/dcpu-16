require './dcpu'

describe '#execute' do
  subject { Dcpu.new }
  
  it 'sets A register' do
    pending
    subject.load(0x7c01, 0x0030)
    subject.excecute

    subject.storage[0].should == 16
  end
  
  it 'sets B register' do
    pending
    subject.load(0x7c01, 0x0030)
    subject.execute

    subject.storage[1].shoul == 16
  end
  
end

describe Dcpu::Storage do
  subject { Dcpu::Storage.new }

  describe '#[] and #[]=' do
    %W{A B C X Y Z I J}.each.with_index do |register, i|
      it "reads and write to #{register}" do
        subject[i] = 17
        subject[i].should == 17
      end
    end

    %W{A B C X Y Z I J}.each.with_index do |register, i|
      it "reads and write to [#{register}]" do
        subject[i] = 18
        location = i + 0x08
        subject[location] = 22
        subject[location].should == 22
      end
    end

    it "reads the next_word" do
      subject[0x1c] = 5
      subject.memory[6] = 11
      subject[0x1f].should == 11
    end

    it "writes the next_word" do
      subject[0x1c] = 5
      subject.memory[6] = 11
      subject[0x1f] = 22
      subject.memory[6].should == 22
    end



    it "reads and writes to PC" do
      subject[0x1c] = 17
      subject[0x1c].should == 17
    end

    it "loads literals" do
      subject[0x20].should == 0
      subject[0x21].should == 1
      subject[0x3f].should == 0x1f
    end

    it "does nothing when writing literals" do
      subject[0x20] = 12
      subject[0x20].should == 0
    end

    it "reads and writes to SP" do
      subject[0x1b] = 17
      subject[0x1b].should == 17
    end

    it "reads and writes to O" do
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