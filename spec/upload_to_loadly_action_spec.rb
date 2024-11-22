describe Fastlane::Actions::UploadToLoadlyAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The loadlyio plugin is working!")

      Fastlane::Actions::UploadToLoadlyAction.run(nil)
    end
  end
end
