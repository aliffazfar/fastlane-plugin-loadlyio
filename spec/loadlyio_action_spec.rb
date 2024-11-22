describe Fastlane::Actions::LoadlyioAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The loadlyio plugin is working!")

      Fastlane::Actions::LoadlyioAction.run(nil)
    end
  end
end
