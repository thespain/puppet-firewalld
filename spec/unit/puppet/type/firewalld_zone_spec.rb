require 'spec_helper'

describe Puppet::Type.type(:firewalld_zone) do

  describe "type" do
    context 'with no params' do
      describe 'when validating attributes' do
        [  
          :name, :purge_rich_rules, :purge_services, :purge_ports
        ].each do |param|
          it "should have a #{param} parameter" do
            expect(described_class.attrtype(param)).to eq(:param)
          end
        end
      
  
        [  
          :target, :icmp_blocks, :sources
        ].each do |param|
          it "should have a #{param} parameter" do
            expect(described_class.attrtype(param)).to eq(:property)
          end
        end
      end
    end
  end


  ## Provider tests for the firewalld_zone type
  #
  describe "provider" do
    let(:resource) {
      described_class.new(
        :name => 'restricted', 
        :target => '%%REJECT%%',
        :interfaces => ['eth0'])
    }
    let(:provider) {
      resource.provider
    }

    it "should check if it exists" do
      provider.expects(:execute_firewall_cmd).with(['--get-zones'], nil).returns('public restricted')
      expect(provider.exists?).to be_truthy
    end

    it "should check if it doesnt exist" do
      provider.expects(:execute_firewall_cmd).with(['--get-zones'], nil).returns('public private')
      expect(provider.exists?).to be_falsey
    end

    it "should create" do
      provider.expects(:execute_firewall_cmd).with(['--new-zone', 'restricted'], nil)
      provider.expects(:execute_firewall_cmd).with(['--set-target', '%%REJECT%%'])

      provider.expects(:interfaces).returns([])
      provider.expects(:execute_firewall_cmd).with(['--add-interface', 'eth0'])
      provider.create
    end

    it "should remove" do
      provider.expects(:execute_firewall_cmd).with(['--delete-zone', 'restricted'], nil)
      provider.destroy
    end

    it "should set target" do
      provider.expects(:execute_firewall_cmd).with(['--set-target', '%%REJECT%%'])
      provider.target=('%%REJECT%%')
    end

    it "should get interfaces" do
      provider.expects(:execute_firewall_cmd).with(['--list-interfaces']).returns("")
      provider.interfaces
    end

    it "should set interfaces" do
      provider.expects(:interfaces).returns(['eth1'])
      provider.expects(:execute_firewall_cmd).with(['--add-interface', 'eth0'])
      provider.expects(:execute_firewall_cmd).with(['--remove-interface', 'eth1'])
      provider.interfaces=(['eth0'])
    end

    it "should get sources" do
      provider.expects(:execute_firewall_cmd).with(['--list-sources']).returns("val val")
      expect(provider.sources).to eq(["val", "val"])
    end

    it "should set sources" do
      provider.expects(:sources).returns(["valx"])
      provider.expects(:execute_firewall_cmd).with(['--add-source', 'valy'])
      provider.expects(:execute_firewall_cmd).with(['--remove-source', 'valx'])
      provider.sources=(['valy'])
    end

    it "should get icmp_blocks" do
      provider.expects(:execute_firewall_cmd).with(['--list-icmp-blocks']).returns("val")
      expect(provider.icmp_blocks).to eq(['val'])
    end

  end
end