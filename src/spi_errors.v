//-----------------------------------------------------------------------------
//Name        : spi_errors.v
//Author      : Tudor Durnea <tudor.durnea@nobugconsulting.ro>
//Date        : 28.07.2008
//-----------------------------------------------------------------------------
//Description : environment for verification
//-----------------------------------------------------------------------------

//`define WB_ADDR_ERR		// inverse bit 3 of addr
//`define WB_SEL_ERR		// inverse bit 2 of select
//`define WB_WE_ERR		// random value
//`define WB_STB_ERR		// random value
//`define WB_CYC_ERR		// random value

//`define WB_RST_DISABLE_ERR	// disable reset pin
//`define WB_RST_RAND_ERR	// randomize reset pin values

//`define WB_CLK_ERR		// double clock period
 
//`define WB_NO_ACK_ERR		// No ACK pulse
//`define WB_ACK_PULSED_ERR	// ACK pulses with inversed levels at middle

//`define WB_INT_ERR		// Assert INT_O after 8 bits on any line

//`define SPI_NO_SCLK_ERR	// No pulse on SCLK pin
//`define SPI_RAND_SCLK_ERR	// SCLK pulses with variable width

//`define SPI_NO_MOSI_ERR	// No pulse on MOSI line
//`define SPI_MOSI_DELAYED_ERR	// Delay the MOSI pulsese from SCLK with 1 WB clock

//`define TX0_NO_UPDATE_ERR	// Only reset loads TX0
//`define TX0_SWAP_ERR		// swap input value

//`define TX1_NO_UPDATE_ERR	// Only reset loads TX1
//`define TX1_SWAP_ERR		// swap input value

//`define TX2_NO_UPDATE_ERR	// Only reset loads TX2
//`define TX2_SWAP_ERR		// swap input value

//`define TX3_NO_UPDATE_ERR	// Only reset loads TX3
//`define TX3_SWAP_ERR		// swap input value

//`define RX_NO_UPDATE_ERR	// Only reset loads RX0
//`define RX_SHIFT_ERR		// Move the bits from MISO with 1 position

//`define CTRL_NO_UPDATE_ERR	// Only reset loads CTRL register
//`define ASS_LOAD_TX_NEG_ERR	// Bit ASS loads previous TX_NEG value
//`define IE_LOAD_GO_BSY_ERR	// Bit IE loads the data in bit for GO_BSY
//`define LSB_SWITCH_ERR	// Bit LSB loads inversed value from data bus
//`define TX_NEG_XOR_ERR	// Bit TX_NEG loads new data xored with previous stored value
//`define RX_NEG_RAND_ERR	// random value
//`define GO_BSY_STUCK_1_ERR	// Bit GO_BSY gets stucked on 1
//`define CHAR_LEN_PLUS_4_ERR	// CHAR_LEN is bigger with 4 than input data

//`define DIVIDER_NO_UPDATE_ERR	// Only reset updates DIVIDER register
//`define DIVIDER_SHIFT_1_ERR	// Shift DIVIDER value with one position

//`define SS_NO_UPDATE_ERR	// Only reset updates SS register
//`define SS_RAND_ERR		// random position for a 1 bit
//`define SS_SHIFT_ERR		// SS is loaded with circular shifted data value

//`define WRITE_AFTER_GOBSY_ERR // registers are writable for 2 wb_clk cycles after GOBSY is set
