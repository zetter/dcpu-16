require './dcpu'

describe '#execute' do
  subject { Dcpu.new }
  
  it 'sets A register' do
    subject.execute(0x7c010030)
    subject.a.should == 0x0030
  end
end