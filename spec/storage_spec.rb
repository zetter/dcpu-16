describe Storage do
  include DcpuTestHelper
  subject { Storage.new }

  describe '#next_instruction' do
    it 'returns the instruction pointed to from the PC' do
      subject[PC] = 5
      subject.memory[5] = 10
      subject.next_instruction.should == Instruction.new(10)
    end
  end

  it 'defaults memory to 0' do
    subject.memory[0].should == 0
    subject.memory[42].should == 0
  end

  describe "#load" do
    it 'loads the words at offset 0 by default' do
      subject.load([4, 7])
      subject.memory[0].should == 4
      subject.memory[1].should == 7
      subject.memory[2].should == 0
    end
  end

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
        subject.memory[5] = 10
        subject.memory[12] = 40
        subject[i + REGISTERS_MEM_NEXT_WORD.begin].should == 40
        subject[PC].should == 6
      end
    end

    %W{A B C X Y Z I J}.each.with_index do |register, i|
      it "writes [next_word + #{register}]" do
        subject[i] = 2
        subject[PC] = 5
        subject.memory[5] = 10
        subject[i + REGISTERS_MEM_NEXT_WORD.begin] = 40
        subject.memory[12].should == 40
      end
    end

    it "reads the next_word" do
      subject[PC] = 5
      subject.memory[5] = 11
      subject[NEXT_WORD_LITERAL].should == 11
      subject[PC].should == 6
    end

    it "writes the next_word" do
      subject[PC] = 5
      subject.memory[5] = 11
      subject[NEXT_WORD_LITERAL] = 22
      subject.memory[5].should == 22
    end

    it "reads the [next_word]" do
      subject[PC] = 5
      subject.memory[5] = 11
      subject.memory[11] = 100
      subject[0x1e].should == 100
      subject[PC].should == 6
    end

    it "writes the [next_word]" do
      subject[PC] = 5
      subject.memory[5] = 11
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
