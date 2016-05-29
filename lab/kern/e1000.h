#ifndef JOS_KERN_E1000_H
#define JOS_KERN_E1000_H

#include <inc/types.h>
#include <kern/pci.h>

#define PKT_SIZE 2048
#define NTXQ 32
#define NRXQ 128
#define NMTA 128
#define ZERO 0x00000000

#define E1000_VENDOR_ID 0x8086
#define E1000_DEV_ID_82540EM             0x100E
#define E1000_EERD     0x00014/4  /* EEPROM Read - RW */
#define E1000_ICR      0x000C0/4  /* Interrupt Cause Read - R/clr */
#define E1000_IMS      0x000D0/4  /* Interrupt Mask Set - RW */
#define E1000_RCTL     0x00100/4  /* RX Control - RW */
#define E1000_TCTL     0x00400/4  /* TX Control - RW */
#define E1000_TIPG     0x00410/4  /* TX Inter-packet gap -RW */
#define E1000_RDBAL    0x02800/4  /* RX Descriptor Base Address Low - RW */
#define E1000_RDBAH    0x02804/4  /* RX Descriptor Base Address High - RW */
#define E1000_RDLEN    0x02808/4  /* RX Descriptor Length - RW */
#define E1000_RDH      0x02810/4  /* RX Descriptor Head - RW */
#define E1000_RDT      0x02818/4  /* RX Descriptor Tail - RW */
#define E1000_RDTR     0x02820/4  /* RX Delay Timer - RW */
#define E1000_TDBAL    0x03800/4  /* TX Descriptor Base Address Low - RW */
#define E1000_TDBAH    0x03804/4  /* TX Descriptor Base Address High - RW */
#define E1000_TDLEN    0x03808/4  /* TX Descriptor Length - RW */
#define E1000_TDH      0x03810/4  /* TX Descriptor Head - RW */
#define E1000_TDT      0x03818/4  /* TX Descripotr Tail - RW */
#define E1000_MTA      0x05200/4  /* Multicast Table Array - RW Array */
#define E1000_RAL      0x05400/4  /* Receive Address Low 32 bits - RW Array */
#define E1000_RAH      0x05404/4  /* Receive Address High 32 bits - RW Array */

/* Receive Address */
#define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */

/* Transmit Control */
#define E1000_TCTL_EN     0x00000002    /* enable tx */
#define E1000_TCTL_PSP    0x00000008    /* pad short packets */
#define E1000_TCTL_CT     0x00000100    /* collision threshold */
#define E1000_TCTL_COLD   0x00040000    /* collision distance */

/* Receive Control */
#define E1000_RCTL_EN             0x00000002    /* enable */
#define E1000_RCTL_LPE            0x00000020    /* long packet enable */
#define E1000_RCTL_LBM_NO         0xffffff3f    /* no loopback mode */
#define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
#define E1000_RCTL_SZ_2048        0xfffcffff    /* rx buffer size 2048 */

/* Transmit IPG */
#define E1000_IPGT 0
#define E1000_IPGT1 10 
#define E1000_IPGT2 20

/* Transmit Descriptor bit definitions */
#define E1000_TXD_CMD 24
#define E1000_TXD_STAT 0
#define E1000_TXD_CMD_EOP    0x01 /* End of Packet */
#define E1000_TXD_CMD_RS     0x08 /* Report Status */
#define E1000_TXD_CMD_DEXT   0x20 /* Descriptor extension (0 = legacy) */
#define E1000_TXD_STAT_DD    0x01 /* Descriptor Done */
#define E1000_TXD_CMD_TCP    0x01 /* TCP packet */
#define E1000_TXD_CMD_IP     0x02 /* IP packet */

/* Receive Descriptor bit definitions */
#define E1000_RXD_STAT_DD       0x00000001    /* Descriptor Done */
#define E1000_RXD_STAT_EOP      0x00000002    /* End of Packet */


/* Interrupt Cause Read */
#define E1000_ICR_LSC           0x00000004 /* Link Status Change */
#define E1000_ICR_RXSEQ         0x00000008 /* rx sequence error */
#define E1000_ICR_RXDMT0        0x00000010 /* rx desc min. threshold (0) */
#define E1000_ICR_RXO           0x00000040 /* rx overrun */
#define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */

// EEPROM
#define E1000_EERD_ADDR 8 /* num of bit shifts to get to addr section */
#define E1000_EERD_DATA 16 /* num of bit shifts to get to data section */
#define E1000_EERD_DONE 0x00000010 /* 4th bit */
#define E1000_EERD_READ 0x00000001 /* 0th bit */

// Receive Timer Interrupt mask
#define E1000_RXT0	0x00000080 /* 7th bit */

// MAC Address
#define E1000_NUM_MAC_WORDS 3

struct packet{
	char buf[PKT_SIZE];
};


/* Receive Descriptor */
struct e1000_rx_desc {
	uint64_t buffer_addr; /* Address of the descriptor's data buffer */
	uint16_t length;     /* Length of data DMAed into data buffer */
	uint16_t csum;       /* Packet checksum */
	uint8_t status;      /* Descriptor status */
	uint8_t errors;      /* Descriptor Errors */
	uint16_t special;
};

/* Transmit Descriptor */
struct e1000_tx_desc {
	uint64_t buffer_addr;       /* Address of the descriptor's data buffer */
	uint16_t length;    /* Data buffer length */
	uint8_t cso;        /* Checksum offset */
	uint8_t cmd;        /* Descriptor control */
	uint8_t status;     /* Descriptor status */
	uint8_t css;        /* Checksum start */
	uint16_t special;
};

int e1000_init(struct pci_func* pcif);
int e1000_transmit(char *pck, size_t length);
int e1000_receive(char *pck, size_t* length);
void e1000_get_mac(uint8_t* mac_addr);
void e1000_trap_handler();
#endif	// JOS_KERN_E1000_H
