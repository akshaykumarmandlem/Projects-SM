import scapy.all as scapy

def process_packet(packet):
    # Define your packet processing logic here
    # For simplicity, this example just prints packet summary
    print(packet.summary())

def start_sniffing(interface):
    scapy.sniff(iface=interface, store=False, prn=process_packet)

# Replace 'eth0' with your network interface
start_sniffing('en0')


#Code should run as root