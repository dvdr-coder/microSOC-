package uvm_lite_pkg;
  typedef class uvm_lite_env;

  class uart_item;
    byte data;
  endclass

  class uart_monitor;
    virtual soc_if vif;
    mailbox #(uart_item) mbx;

    function new(virtual soc_if vif, mailbox #(uart_item) mbx);
      this.vif = vif;
      this.mbx = mbx;
    endfunction

    task run();
      uart_item item;
      logic [7:0] rx_byte;
      
      // Wait for reset release
      wait(vif.rst_n == 1'b1);

      forever begin
        @(negedge vif.uart_tx); // Start bit detect
        repeat(1) @(posedge vif.clk);
        for (int i = 0; i < 8; i++) begin
          repeat(1) @(posedge vif.clk);
          rx_byte[i] = vif.uart_tx;
        end
        repeat(1) @(posedge vif.clk); // Stop bit

        item = new();
        item.data = rx_byte;
        mbx.put(item);
      end
    endtask
  endclass

  class scoreboard;
    mailbox #(uart_item) mbx;

    function new(mailbox #(uart_item) mbx);
      this.mbx = mbx;
    endfunction

    task run();
      uart_item item;
      forever begin
        mbx.get(item);
        $write("%c", item.data);
      end
    endtask
  endclass

  class uvm_lite_env;
    virtual soc_if vif;
    mailbox #(uart_item) mbx;
    uart_monitor mon;
    scoreboard   sb;

    function new(virtual soc_if vif);
      this.vif = vif;
      this.mbx = new();
      this.mon = new(vif, mbx);
      this.sb  = new(mbx);
    endfunction

    task run();
      fork
        mon.run();
        sb.run();
      join_none
    endtask
  endclass
endpackage
