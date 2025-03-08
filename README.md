# APB Slave Module

## Overview
This module implements an **Advanced Peripheral Bus (APB) Slave** that interfaces with an APB Master. The APB Slave supports secure data transactions based on the `Prot` signal and allows read/write operations based on the APB protocol.

## Features
- **Supports APB protocol** with `psel`, `penable`, and `pwrite` control signals.
- **Memory-mapped storage** with a 32-word (32-bit wide) memory array.
- **Secure transactions**: Only secured accesses (`Prot[1] == 0`) are allowed.
- **Byte-wise write enable** using `pstrobe`.
- **Implements three states**: `idle`, `setup`, and `access`.

## APB Interface Signals
### **Inputs**
| Signal | Width | Description |
|--------|------|-------------|
| `clk` | 1-bit | Clock signal |
| `resetn` | 1-bit | Active-low reset signal |
| `pwrite` | 1-bit | Write enable (1 = Write, 0 = Read) |
| `addr` | 5-bit | Memory address |
| `psel` | 1-bit | APB select signal |
| `penable` | 1-bit | APB enable signal |
| `pstrobe` | 4-bit | Byte-wise write enable |
| `Prot` | 3-bit | Protection signal (Secure = `Prot[1] == 0`) |
| `pwdata` | 32-bit | Write data |

### **Outputs**
| Signal | Width | Description |
|--------|------|-------------|
| `pready` | 1-bit | Ready signal (indicates transfer completion) |
| `pslverr` | 1-bit | Error signal (unused for secured access) |
| `prdata` | 32-bit | Read data |

## State Machine
The APB Slave operates in three states:
1. **Idle**: Waits for `psel` to be asserted.
2. **Setup**: Moves to `access` when `psel` and `penable` are asserted.
3. **Access**: Performs read/write operations based on `pwrite`. If `Prot[1] == 1`, the transaction is blocked.

## Memory Operation
- **Read (`pwrite = 0`)**: Data is read from `memory[addr]` into `prdata`.
- **Write (`pwrite = 1`)**: Data is written to `memory[addr]` with selective byte updates based on `pstrobe`.

### **Memory Update Function**
The `update_memory` function selectively updates memory based on `pstrobe`:
```verilog
function logic [31:0] update_memory(
  input logic [31:0] pwdata,
  input logic [3:0]  pstrobe,
  input logic [31:0] memory_data
);
  begin
    if (pstrobe[0]) memory_data[7:0]   = pwdata[7:0];   
    if (pstrobe[1]) memory_data[15:8]  = pwdata[15:8];  
    if (pstrobe[2]) memory_data[23:16] = pwdata[23:16];
    if (pstrobe[3]) memory_data[31:24] = pwdata[31:24];
    update_memory = memory_data;
  end
endfunction
```

## Usage
1. **Reset** the module using `resetn` (active low).
2. **Initiate a transaction** by asserting `psel`.
3. **Set `penable`** after `psel` is asserted to transition into `access`.
4. **Perform read/write operations** based on `pwrite`.
5. **Check `pready`** to ensure transaction completion.
6. **Secure Access Only**: Transactions are processed only when `Prot[1] == 0`.

## Notes
- If an unsecured access (`Prot[1] == 1`) is detected, the transaction is ignored, and the module returns to the `idle` state.
- `pready` is asserted in the `access` state to indicate a valid transaction.
- `pslverr` is currently not used but can be extended for error handling.

## Future Enhancements
- Add `pslverr` handling for invalid transactions.
- Extend memory size for larger address space.
- Implement additional security features.

## Author
- **Nithesh Kamireddy**
- **Date**: March 2025

## License
This project is licensed under the MIT License.

