#include <kern/e1000.h>
#include <kern/pmap.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/env.h>
#include <inc/string.h>
#include <inc/error.h>
#include <inc/env.h>

// LAB 6: Your driver code here

// register address
volatile uint32_t* e1000_regs;

struct e1000_tx_desc txq[NTXQ] __attribute__ ((aligned(16))); 
struct packet tx_paks[NTXQ];

struct e1000_rx_desc rxq[NRXQ] __attribute__ ((aligned(16))); 
struct packet rx_paks[NRXQ];

uint16_t mac[E1000_NUM_MAC_WORDS];

// Forward declaration
void read_mac_from_eeprom(void);

int e1000_init(struct pci_func *f){

	e1000_regs = mmio_map_region((physaddr_t)(f->reg_base[0]), f->reg_size[0]);

	/*-------------------
	  transmission init
	  ----------------------*/

	//txq base address
	e1000_regs[E1000_TDBAL] = PADDR(txq); 
	e1000_regs[E1000_TDBAH] = ZERO;
	e1000_regs[E1000_TDLEN] = NTXQ * sizeof(struct e1000_tx_desc);

	// transmit descriptor header and tail
	e1000_regs[E1000_TDH] = ZERO;
	e1000_regs[E1000_TDT] = ZERO;

	// transmit control register 
	e1000_regs[E1000_TCTL] |= E1000_TCTL_EN; 
	e1000_regs[E1000_TCTL] |= E1000_TCTL_PSP;
	e1000_regs[E1000_TCTL] |= E1000_TCTL_CT;
	e1000_regs[E1000_TCTL] |= E1000_TCTL_COLD;

	// transmit IPG register 
	e1000_regs[E1000_TIPG] = 0xA<<E1000_IPGT;
	e1000_regs[E1000_TIPG] = 0x8<<E1000_IPGT1;
	e1000_regs[E1000_TIPG] = 0xC<<E1000_IPGT2;

	// set each tx descriptor
	memset(txq, 0, NTXQ * sizeof(struct e1000_tx_desc));
	int i;
	for (i = 0;i < NTXQ; i++){
		txq[i].buffer_addr = PADDR(&tx_paks[i]);
		txq[i].cmd |= E1000_TXD_CMD_RS; 
		txq[i].cmd &= ~E1000_TXD_CMD_DEXT;
		txq[i].status |= E1000_TXD_STAT_DD;
	}

	/*-------------------
	  receive init
	  ----------------------*/

	// MAC address
	
	read_mac_from_eeprom();

	e1000_regs[E1000_RAL] = 0x0;
	e1000_regs[E1000_RAL] = mac[0];
	e1000_regs[E1000_RAL] |= (mac[1] << E1000_EERD_DATA);

	e1000_regs[E1000_RAH] = 0x0;
	e1000_regs[E1000_RAH] |= mac[2];
	e1000_regs[E1000_RAH] |= E1000_RAH_AV;

	for (i = 0; i < NMTA; i++){
		e1000_regs[E1000_MTA+i] = ZERO;	
	}

	// Interrupt
	//e1000_regs[E1000_IMS] |= E1000_ICR_LSC; 
	//e1000_regs[E1000_IMS] |= E1000_ICR_RXO; 
	//e1000_regs[E1000_IMS] |= E1000_ICR_RXSEQ; 
	e1000_regs[E1000_IMS] |= E1000_ICR_RXT0; 
	//e1000_regs[E1000_IMS] |= E1000_ICR_RXDMT0; 

	// Receive Descriptor Base Address
	e1000_regs[E1000_RDBAL] = PADDR(&rxq);
	e1000_regs[E1000_RDBAH] = ZERO;
	e1000_regs[E1000_RDLEN] = NRXQ * sizeof(struct e1000_rx_desc);

	// transmit descriptor header and tail
	e1000_regs[E1000_RDH] = 0;
	e1000_regs[E1000_RDT] = NRXQ - 1;
	memset(rxq, 0, NRXQ*sizeof(struct e1000_rx_desc));

	for (i = 0; i < NRXQ; i++) {
		rxq[i].buffer_addr = PADDR(&rx_paks[i]);	
	} 	

	// Receive Control Register
	e1000_regs[E1000_RCTL] |= E1000_RCTL_EN;
	e1000_regs[E1000_RCTL] &= ~E1000_RCTL_LPE; 
	e1000_regs[E1000_RCTL] &= E1000_RCTL_LBM_NO; 
	e1000_regs[E1000_RCTL] |= E1000_RCTL_SECRC; 
	e1000_regs[E1000_RCTL] &= E1000_RCTL_SZ_2048; 

	return 1;
}

int e1000_transmit(char *pck, size_t length){

	if (length > PKT_SIZE) {
		cprintf("e1000_transmit: invalid packet length");
		return -1;
	}

	uint32_t idx = e1000_regs[E1000_TDT]; 
	if (! (txq[idx].status&(E1000_TXD_STAT_DD>>E1000_TXD_STAT)))
	  return -1;

	memmove((void*)&tx_paks[idx], (void*)pck, length);

	txq[idx].status &= ~E1000_TXD_STAT_DD; 
	txq[idx].cmd |= E1000_TXD_CMD_EOP;
	txq[idx].length = length;
	e1000_regs[E1000_TDT] = (idx+1)%NTXQ;

	return 0;
}

int
e1000_receive(char *pck, size_t* length){

	size_t index = (e1000_regs[E1000_RDT] + 1)%NRXQ;
	if (!(rxq[index].status&E1000_RXD_STAT_DD)) 
	  return -E_E1000_RXBUF_EMPTY;

	if (!(rxq[index].status & E1000_RXD_STAT_EOP))
	  panic("e1000_receive: EOP not set");

	*length = rxq[index].length;
	memmove((void*)pck, &rx_paks[index], *length);

	rxq[index].status &= ~E1000_RXD_STAT_DD;
	rxq[index].status &= ~E1000_RXD_STAT_EOP;

	e1000_regs[E1000_RDT] = index;

	return 0;
}

void
clear_e1000_interrupt(void)
{
	// As per the Intel manual, section 13.4.7, writing to a bit clears
	// that bit, acknowledging the interrupt.
	e1000_regs[E1000_ICR] |= E1000_RXT0;
	lapic_eoi();
	irq_eoi();

}

void
e1000_trap_handler(void)
{
	struct Env *receiver = NULL;
	int i;

	// See if there's an environment waiting to receive a packet
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_e1000_waiting_rx)
		  receiver = &envs[i];
	}

	// If no environment is waiting, quietly acknowledge the interrupt
	if (!receiver) {
		clear_e1000_interrupt();
		return;
	}
	else {
		receiver->env_status = ENV_RUNNABLE;
		receiver->env_e1000_waiting_rx = false;
		clear_e1000_interrupt();
		return;
	}
}

// This method reads the MAC address 16 bits at a time from the EEPROM
void
read_mac_from_eeprom(void)
{
	uint8_t word_num;

	for (word_num = 0; word_num < E1000_NUM_MAC_WORDS; word_num++) {

		// Set address to read
		e1000_regs[E1000_EERD] |= (word_num << E1000_EERD_ADDR);

		// Tell controller to read
		e1000_regs[E1000_EERD] |= E1000_EERD_READ;

		// Spin until controller indicates it is down with the read
		while (!(e1000_regs[E1000_EERD] & E1000_EERD_DONE))
		  ;

		// Read value into memory
		mac[word_num] = e1000_regs[E1000_EERD] >> E1000_EERD_DATA;

		// Register has to be cleared, otherwise it keeps reading the
		// same value over and over
		e1000_regs[E1000_EERD] = 0x0;
	}
}


void
e1000_get_mac(uint8_t *mac_addr)
{
	*((uint32_t *) mac_addr) =  (uint32_t) e1000_regs[E1000_RAL];
	*((uint16_t*)(mac_addr + 4)) = (uint16_t) e1000_regs[E1000_RAH];
}
