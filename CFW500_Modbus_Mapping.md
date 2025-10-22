# CFW500 Modbus RTU Register Mapping Documentation

## Overview

This document provides detailed mapping of CFW500 inverter parameters used in the polymer profiling machine control system. All registers are accessed via Modbus RTU protocol with the following configuration:

- **Protocol**: Modbus RTU
- **Baud Rate**: Configured in Micro850 channel settings
- **Parity**: None (typical for industrial applications)
- **Data Bits**: 8
- **Stop Bits**: 1
- **Node Addresses**: 1, 2, 3 (one per roller/inverter)

## Register Addressing Convention

- All addresses are holding registers (function code 3 for read, 16 for write)
- CFW500 parameter PXXXX maps to Modbus register XXXX
- Example: P0009 (Torque) = Register 9

## Parameter Mapping Table

### Monitoring Parameters (Read-Only)

| Parameter | Register | Description      | Scaling | Units | Data Type | Update Rate |
| --------- | -------- | ---------------- | ------- | ----- | --------- | ----------- |
| P0002     | 2        | Output Frequency | ×0.1    | Hz    | UINT      | 1 second    |
| P0003     | 3        | Output Current   | ×0.1    | A     | UINT      | 1 second    |
| P0009     | 9        | Motor Torque     | ×0.1    | %     | UINT      | 1 second    |

### Control Parameters (Read/Write)

| Parameter | Register | Description             | Scaling | Units | Data Type | Default | Range         |
| --------- | -------- | ----------------------- | ------- | ----- | --------- | ------- | ------------- |
| P0100     | 100      | Control Type            | 1:1     | -     | UINT      | 2       | 0-5           |
| P0133     | 133      | Minimum Speed Reference | ×0.01   | Hz    | UINT      | 0       | 0-SpeedMax    |
| P0134     | 134      | Maximum Speed Reference | ×0.01   | Hz    | UINT      | 6000    | SpeedMin-6500 |
| P0169     | 169      | Maximum Torque Limit    | ×0.1    | %     | UINT      | 1500    | 0-2000        |
| P0170     | 170      | Minimum Torque Limit    | ×0.1    | %     | UINT      | 0       | -2000-0       |
| P0498     | 498      | Parameter Save          | 0/1     | -     | UINT      | 0       | 0-1           |

## Control Type (P0100) Values

- **0**: V/F Control
- **1**: V/F with Encoder
- **2**: Vector Sensorless (Used in this application)
- **3**: Vector with Encoder
- **4**: V/F Quadratic
- **5**: V/F with Encoder Quadratic

## Scaling Details

### Frequency Parameters (P0133, P0134)

- **HMI Input**: Real number in Hz (e.g., 60.0 Hz)
- **Scaling**: Multiply by 100 to get UINT (e.g., 60.0 × 100 = 6000)
- **CFW500 Storage**: UINT representing 0.01 Hz units
- **Formula**: `Register_Value = HMI_Value × 100`

### Torque Parameters (P0169, P0170)

- **HMI Input**: Real number in % (e.g., 150.0%)
- **Scaling**: Multiply by 10 to get UINT (e.g., 150.0 × 10 = 1500)
- **CFW500 Storage**: UINT representing 0.1% units
- **Formula**: `Register_Value = HMI_Value × 10`

### Monitoring Parameters (P0002, P0003, P0009)

- **CFW500 Output**: UINT in scaled units
- **HMI Display**: Divide by 10 for real values
- **Formula**: `Display_Value = Register_Value ÷ 10`

## Communication Protocol Details

### Read Operations

- **Function Code**: 3 (Read Holding Registers)
- **Single Register**: ElementCnt = 1
- **Multiple Registers**: ElementCnt = 2 (for consecutive parameters)

### Write Operations

- **Function Code**: 6 (Preset Single Register) for single parameters
- **Function Code**: 16 (Preset Multiple Registers) for consecutive parameters
- **ElementCnt**: Number of registers to write

## Error Handling

- **Timeout**: System retries failed operations up to 3 times
- **Error Flags**: Separate tracking for read/write/verification errors
- **Recovery**: Automatic error clearing after 30 seconds of successful communication

## Application-Specific Usage

### Roller Control Logic

Each roller (rolo1, rolo2, rolo3) implements identical control logic:

1. **Periodic Monitoring**: Reads P0002, P0003, P0009 every 1 second
2. **Parameter Validation**: HMI inputs clamped to safe ranges before scaling
3. **Change Detection**: Only writes parameters when HMI values differ from inverter values
4. **Verification**: Checks critical parameters every 10 seconds and forces correction if needed

### Safety Limits

- **Speed Range**: 0.0 - 100.0 Hz (configurable via SPEED_MAX_LIMIT)
- **Torque Range**: 0.0 - 200.0% (configurable via TORQUE_MAX_LIMIT)
- **Inter-Lock**: SpeedMin ≤ SpeedMax enforced automatically

## Troubleshooting

### Common Issues

1. **Communication Timeout**: Check Modbus wiring, baud rate, and node addresses
2. **Parameter Not Updating**: Verify HMI value differs from current inverter value
3. **Invalid Values**: Check scaling calculations and HMI input ranges

### Diagnostic Parameters

- Monitor `CommunicationOK_roloX` for overall communication status
- Check retry counters (`WriteRetryCount_roloX`, etc.) for communication quality
- Review error flags for specific failure modes

## References

- CFW500 User Manual - Modbus RTU Communication
- Allen Bradley Micro850 Controller - Modbus Master Configuration
- IEC 61131-3 Structured Text Programming Guidelines

---

_Document Version: 1.0_
_Last Updated: October 22, 2025_
_System: Polymer Profiling Machine - CFW500 Control_</content>
<parameter name="filePath">c:\Users\mauro.bueno\Downloads\PerfilBobinadeira\CFW500_Modbus_Mapping.md
