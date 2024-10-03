`ifndef WB_ADDR_WIDTH
 `define WB_ADDR_WIDTH 64
`endif

`ifndef WB_DATA_WIDTH
 `define WB_DATA_WIDTH 64
`endif

`ifndef WB_GRANULARITY
 `define WB_GRANULARITY 8
`endif

`ifndef WB_SEL_SIZE
 `define WB_SEL_SIZE `WB_DATA_WIDTH / `WB_GRANULARITY
`endif
