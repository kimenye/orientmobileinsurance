require 'smpp'
class SmppClient

  def initialize
    config = {
      host: '41.223.58.157',
      port: 55000,
      system_id: 'mi3ens',
      password: 'mi3ens',
      system_type: '', # default given according to SMPP 3.4 Spec
      interface_version: 52,
      source_ton: 0,
      source_npi: 1,
      destination_ton: 1,
      destination_npi: 1,
      source_address_range: '',
      destination_address_range: '',
      enquire_link_delay_secs: 10
    }

    @tx = EventMachine::run do
      $tx = EventMachine::connect(
        config[:host],
        config[:port],
        Smpp::Transceiver,
        config,
        self)
    end    
  end

  def send
    resp = tx.send_mt(1, nil, '254705866564', 'Hello world')
    puts resp
  end
end

client = SmppClient.new
client.send