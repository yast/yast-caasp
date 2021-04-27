
shared_examples "NTP from DHCP" do
  context "when some NTP server is detected via DHCP" do
    let(:ntp_servers) { ["ntp.example.com"] }

    it "proposes to use it by default" do
      expect(Yast::Lan).to receive(:dhcp_ntp_servers).and_return(ntp_servers)
      expect(Y2Caasp::Widgets::NtpServer).to receive(:new)
        .with(ntp_servers).and_call_original
      subject.run
    end
  end
end
