#include "ns.h"

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	int r;
	int perm;
	envid_t sender_envid;
	while(1){
		r = ipc_recv(&sender_envid, (void*)&nsipcbuf, &perm);
		if (r < 0 || (uint32_t*)sender_envid == 0){
			cprintf("output: ipc_recv failed, %e", r);
			continue;
		}

		if (sender_envid != ns_envid) {
			cprintf("output: receive from %08x, expect to receive from %08x", sender_envid, ns_envid);
			continue;
		}
		
		if (!(perm & PTE_P)){
			cprintf("output: permission failed");
			continue;
		}

		if ((r = sys_e1000_transmit(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len)) < 0){
			cprintf("output: sys_e1000_transmit failed, %e", r);
		}
	}
}
