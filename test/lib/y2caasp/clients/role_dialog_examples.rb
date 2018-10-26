
shared_examples "displays the dialog" do
  it "creates wizard dialog in normal mode" do
    allow(Yast::Mode).to receive(:normal).and_return(true)

    expect(Yast::Wizard).to receive(:CreateDialog)

    subject.run
  end

  it "closed wizard dialog in normal mode" do
    allow(Yast::Mode).to receive(:normal).and_return(true)

    expect(Yast::Wizard).to receive(:CloseDialog)

    subject.run
  end

  it "shows CWM widgets" do
    allow(Yast::Mode).to receive(:normal).and_return(true)

    expect(Yast::CWM).to receive(:show).and_return(:next)

    subject.run
  end
end

shared_examples "NTP from DHCP" do
  context "when some NTP server is detected via DHCP" do
    let(:ntp_servers) { ["ntp.example.com"] }

    it "proposes to use it by default" do
      expect(Yast::LanItems).to receive(:dhcp_ntp_servers).and_return("eth0" => ntp_servers)
      expect(Y2Caasp::Widgets::NtpServer).to receive(:new)
        .with(ntp_servers).and_call_original
      subject.run
    end
  end
end
