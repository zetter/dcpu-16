require './dcpu'

def build_word(b, a, o)
  Dcpu::Word.new(b << 10 | a << 4 | o)
end

def literal(x)
  x + LITERALS.begin
end

describe '#execute' do
  subject { Dcpu.new }
  include StorageConstants
  include InstructionConstants  
  describe 'SET' do
    it 'sets A register' do
      subject.execute(build_word(literal(4), A, SET))
      subject.storage[A].should == 4
    end
  
    it 'sets B register' do
      subject.execute(build_word(literal(4), A + 1, SET))
      subject.storage[A + 1].should == 4
    end
  end
  describe 'ADD' do
    it 'adds small numbers' do
      subject.storage[A] = 2
      subject.execute(build_word(literal(4), A, ADD))
      subject.storage[A].should == 6
    end
  end
  describe 'MUL' do
    it 'multiplies small numbers' do
      subject.storage[A] = 2
      subject.execute(build_word(literal(4), A, MUL))
      subject.storage[A].should == 8
    end
  end
  describe 'DIV' do
    it 'divides small numbers' do
      subject.storage[A] = 6
      subject.execute(build_word(literal(3), A, DIV))
      subject.storage[A].should == 2
    end
  end
  describe 'SHL' do
    it 'shift left small numbers' do
      subject.storage[A] = 2
      subject.execute(build_word(literal(3), A, SHL))
      subject.storage[A].should == 16
    end
  end
  describe 'SHR' do
    it 'shift right small numbers' do
      subject.storage[A] = 16
      subject.execute(build_word(literal(3), A, SHR))
      subject.storage[A].should == 2
    end
  end
  describe 'AND' do
    it 'bitwise AND small numbers' do
      subject.storage[A] = 0b0110
      subject.execute(build_word(literal(0b0101), A, AND))
      subject.storage[A].should == 0b0100
    end
  end
  describe 'BOR' do
    it 'bitwise OR small numbers' do
      subject.storage[A] = 0b0100
      subject.execute(build_word(literal(0b0001), A, BOR))
      subject.storage[A].should == 0b0101
    end
  end
  describe 'XOR' do
    it 'bitwise XOR small numbers' do
      subject.storage[A] = 0b0110
      subject.execute(build_word(literal(0b0101), A, XOR))
      subject.storage[A].should == 0b0011
    end
  end
  
  
end

describe Storage do
  include StorageConstants
  subject { Storage.new }

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

    %W{A B C X Y Z I J}.each.with_index do |register, i|
      it "reads [next_word + #{register}]" do
        subject[i] = 2
        subject[PC] = 5
        subject.memory[5 + 1] = 10
        subject.memory[12] = 40
        subject[i + REGISTERS_MEM_NEXT_WORD.begin].should == 40
        subject[PC].should == 6
      end
    end

    %W{A B C X Y Z I J}.each.with_index do |register, i|
      it "writes [next_word + #{register}]" do
        subject[i] = 2
        subject[PC] = 5
        subject.memory[5 + 1] = 10
        subject[i + REGISTERS_MEM_NEXT_WORD.begin] = 40
        subject.memory[12].should == 40
      end
    end

    it "reads the next_word" do
      subject[PC] = 5
      subject.memory[6] = 11
      subject[NEXT_WORD_LITERAL].should == 11
      subject[PC].should == 6
    end

    it "writes the next_word" do
      subject[PC] = 5
      subject.memory[6] = 11
      subject[NEXT_WORD_LITERAL] = 22
      subject.memory[6].should == 22
    end

    it "reads the [next_word]" do
      subject[PC] = 5
      subject.memory[6] = 11
      subject.memory[11] = 100
      subject[0x1e].should == 100
      subject[PC].should == 6
    end

    it "writes the [next_word]" do
      subject[PC] = 5
      subject.memory[6] = 11
      subject[0x1e] = 100
      subject.memory[11].should == 100
    end

    it "reads and writes to PC" do
      subject[PC] = 17
      subject[PC].should == 17
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

    describe 'the stack' do
      it "reads PEEK" do
        subject[SP] = 10
        subject.memory[10] = 40
        subject[PEEK].should == 40
        subject[SP].should == 10
      end

      it "writes PEEK" do
        subject[SP] = 10
        subject[PEEK] = 40
        subject.memory[10].should == 40
        subject[SP].should == 10
      end

      it "reads POP" do
        subject[SP] = 10
        subject.memory[10] = 40
        subject[POP].should == 40
        subject[SP].should == 11
      end

      it "writes POP" do
        subject[SP] = 10
        subject[POP] = 40
        subject.memory[10].should == 40
        subject[SP].should == 11
      end
      
      it "reads PUSH" do
        subject[SP] = 10
        subject.memory[9] = 40
        subject[PUSH].should == 40
        subject[SP].should == 9
      end

      it "writes PUSH" do
        subject[SP] = 10
        subject[PUSH] = 40
        subject.memory[9].should == 40
        subject[SP].should == 9
      end
      
    end

    it "starts the SP to 0xffff" do
      subject[SP].should == 0xffff
    end

    it "reads and writes to SP" do
      subject[SP] = 17
      subject[SP].should == 17
    end

    it "reads and writes to O" do
      subject[O] = 17
      subject[O].should == 17
    end
  end
end

describe Dcpu::Word do
  subject {
    build_word(@b = 5, @a = 4, @opcode = 3)
  }
  
  describe '#opcode' do
    it 'returns the opcode' do
      subject.opcode.should == @opcode
    end
  end

  describe '#to_s' do
    it 'return hex representation of the word' do
      subject.to_s.should == '1443'
    end
  end

  describe '#a' do
    it 'returns part a' do
      subject.a.should == @a
    end
  end

  describe '#b' do
    it 'returns part b' do
      subject.b.should == @b
    end
  end
  
end