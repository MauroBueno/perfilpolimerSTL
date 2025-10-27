# CFW500 Modbus Register Mapping

## Overview

This document provides the Modbus register mapping for the WEG CFW500 frequency inverter used in the winding machine control system. All three rollers (Rolo 1, 2, and 3) use identical parameter structures but are accessed via different Modbus node addresses.

## Connection Details

- **Protocol**: Modbus RTU
- **Node Addresses**:
  - Rolo 1: Node = 1
  - Rolo 2: Node = 2
  - Rolo 3: Node = 3
- **Channel**: 2 (configured in PLC)
- **Baud Rate**: Typically 9600 or 19200 (verify in inverter settings)
- **Data Format**: 8-N-1 (8 data bits, No parity, 1 stop bit)

## Register Address Convention

CFW500 uses a direct mapping where parameter Pxxxx corresponds to Modbus holding register address xxxx.

**Example**: P0134 → Holding Register 134

## Function Codes Used

| Function Code | Description              | Usage in Project                    |
| ------------- | ------------------------ | ----------------------------------- |
| 3             | Read Holding Registers   | Read parameters and monitoring data |
| 6             | Write Single Register    | Write individual parameters         |
| 16            | Write Multiple Registers | Write consecutive parameters        |

## Critical Parameters

### P0100 - Control Type

| Parameter | Address | Type | Range | Description          | Units |
| --------- | ------- | ---- | ----- | -------------------- | ----- |
| P0100     | 100     | UINT | 0-5   | Motor control method | -     |

**Values**:

- 0 = V/f (Scalar)
- 1 = VVW (Vector Voltage/Frequency)
- **2 = Vector Sensorless** ← Used in this project
- 3 = Vector with Encoder
- 4 = Vector with Resolver
- 5 = Direct Torque Control

**Project Configuration**: Set to 2 (Vector Sensorless) for optimal torque control.

### Speed Limits

| Parameter | Address | Type | Range   | Description   | Units  | Scaling |
| --------- | ------- | ---- | ------- | ------------- | ------ | ------- |
| P0133     | 133     | UINT | 0-60000 | Minimum Speed | 0.01Hz | ÷100    |
| P0134     | 134     | UINT | 0-60000 | Maximum Speed | 0.01Hz | ÷100    |

**Notes**:

- Values stored as 0.01 Hz units
- Example: 6000 = 60.00 Hz
- Project limits: 0-100 Hz (validated before writing)

### Torque Limits

| Parameter | Address | Type | Range  | Description    | Units | Scaling |
| --------- | ------- | ---- | ------ | -------------- | ----- | ------- |
| P0169     | 169     | UINT | 0-2000 | Maximum Torque | 0.1%  | ÷10     |
| P0170     | 170     | UINT | 0-2000 | Minimum Torque | 0.1%  | ÷10     |

**Notes**:

- Values stored as 0.1% units
- Example: 1000 = 100.0%
- Project limits: 0-200% (validated before writing)
- P0170 typically set to 0 in this application

## Monitoring Parameters

### Real-time Operating Data

| Parameter | Address | Type | Range    | Description              | Units    | Scaling  | Read Cycle |
| --------- | ------- | ---- | -------- | ------------------------ | -------- | -------- | ---------- |
| P0002     | 2       | UINT | 0-60000  | Output Frequency         | 0.1Hz    | ÷10      | 10s        |
| P0003     | 3       | UINT | 0-65535  | Output Current           | 0.1A     | ÷10      | 10s        |
| P0009     | 9       | UINT | 0-2000   | Motor Torque             | 0.1%     | ÷10      | 10s        |
| P0409     | 409     | UINT | Variable | Additional Parameter 1\* | Variable | Variable | 10s        |
| P0410     | 410     | UINT | Variable | Additional Parameter 2\* | Variable | Variable | 10s        |

**Notes on P0409 and P0410**: The exact function of these parameters depends on CFW500 configuration and firmware version. Consult your specific inverter manual for:

- Detailed function and description
- Appropriate scaling factor
- Valid value range
- Units of measurement

Common possible uses:

- Inverter temperature
- DC bus voltage
- Active/reactive power
- Additional operational states

### Additional Monitoring Parameters

| Parameter | Address | Type | Range | Description                | Units | Scaling | Read Cycle |
| --------- | ------- | ---- | ----- | -------------------------- | ----- | ------- | ---------- |
| P0409     | 409     | UINT | 0-1   | Vector Sensorless Config 1 | -     | 1:1     | 10s        |
| P0410     | 410     | UINT | 0-1   | Vector Sensorless Config 2 | -     | 1:1     | 10s        |

**Notes on P0409 and P0410**:

- These are boolean parameters (0 or 1) used for Vector Sensorless configuration
- **0** = Feature disabled
- **1** = Feature enabled
- Exact function depends on CFW500 firmware version
- Consult CFW500 manual for specific parameter definitions
- Values stored as UINT but represent boolean states
- Independent retry mechanism for these parameters

### Additional Useful Parameters (Not Currently Implemented)

The following parameters may be useful for future system expansion:

| Parameter | Address | Type | Range   | Description          | Scaling | Units | Access     |
| --------- | ------- | ---- | ------- | -------------------- | ------- | ----- | ---------- |
| P0001     | 1       | UINT | 0-65535 | Motor Speed          | ×1      | RPM   | Read Only  |
| P0004     | 4       | UINT | 0-65535 | Output Voltage       | ×1      | V     | Read Only  |
| P0005     | 5       | UINT | 0-60000 | Input Frequency      | ×0.01   | Hz    | Read Only  |
| P0006     | 6       | UINT | 0-65535 | DC Link Voltage      | ×1      | V     | Read Only  |
| P0007     | 7       | UINT | 0-200   | Inverter Temperature | ×1      | °C    | Read Only  |
| P0011     | 11      | UINT | Bitmap  | Inverter Status      | Bitmap  | -     | Read Only  |
| P0220     | 220     | UINT | 0-9999  | Acceleration Time    | ×0.1    | s     | Read/Write |
| P0221     | 221     | UINT | 0-9999  | Deceleration Time    | ×0.1    | s     | Read/Write |

## Parameter Access Sequence

#### Write Sequence (On HMI Change or WriteTrigger)

1. **Step 0**: Write P0134 (Max Speed)
2. **Step 1**: Write P0133 (Min Speed)
3. **Step 2**: Write P0169 (Max Torque)
4. **Step 3**: Write P0170 (Min Torque)

**Notes**:

- Sequential execution with retry logic (max 3 attempts)
- Only triggered when HMI values change or operator presses "Apply"
- Parameters are automatically saved by CFW500 upon write
- Avoids unnecessary writes to inverter

### Read Sequence (Every 10 seconds)

**Monitoring Cycle**:

1. **Step 1**: Read P0009 (Torque)
2. **Step 2**: Read P0002 and P0003 (Frequency and Current) - consecutive read

**P0409/P0410 Cycle** (separate, also every 10 seconds):

1. **Step 1**: Read P0409 and P0410 - consecutive read

**Notes**:

- ModbusBusy flag ensures sequential access
- Each operation includes retry logic
- Consecutive registers read together for efficiency

### Verification Sequence (Every 10 seconds)

1. **Step 1**: Read P0100, verify and force to 2 if different
2. **Step 2**: Read P0134/P0133, verify and force if different
3. **Step 3**: Read P0169/P0170, verify and force if different

**Purpose**: Ensures critical parameters remain at desired values even if changed externally.

## Data Scaling Examples

### Speed Conversion

```
HMI Value (Hz) → Inverter Value
60.00 Hz × 100 = 6000 (0x1770)

Inverter Value → Display Value
6000 ÷ 100.0 = 60.00 Hz
```

### Torque Conversion

```
HMI Value (%) → Inverter Value
100.0% × 10 = 1000 (0x03E8)

Inverter Value → Display Value
1000 ÷ 10.0 = 100.0%
```

### Current Conversion

```
Inverter Value → Display Value
245 ÷ 10.0 = 24.5 A
```

## Error Handling

### Retry Mechanism

- **Maximum Retries**: 3 attempts per operation
- **Retry Counter Variables**:
  - `WriteRetryCount_roloX`
  - `ReadRetryCount_roloX`
  - `ReadRetryCount_P0409_P0410_roloX` ← Separate retry counter for P0409/P0410
  - `VerificationRetryCount_roloX`

### Error Flags

| Flag                    | Description                          | Recovery                     |
| ----------------------- | ------------------------------------ | ---------------------------- |
| `WriteError_roloX`      | Write operation failed after retries | Cleared after 30s of success |
| `ReadError_roloX`       | Read operation failed after retries  | Cleared after 30s of success |
| `CommunicationOK_roloX` | Overall communication status         | Updated on each operation    |

### Error Recovery

- **Recovery Time**: 30 seconds (ERROR_RECOVERY_TIME)
- **Mechanism**: Automatic flag clearing after sustained successful communication
- **Implementation**: Uses TON timer per roller

## Communication Timing

### Timer Configuration

| Timer                 | Period | Purpose                           |
| --------------------- | ------ | --------------------------------- |
| ReadTimer             | 10s    | Triggers P0009, P0002, P0003 read |
| ReadTimer_P0409_P0410 | 10s    | Triggers P0409, P0410 read        |
| VerificationTimer     | 10s    | Triggers parameter verification   |
| SpeedTorqueAlarmTimer | 5s     | Delay for speed-torque alarm      |
| ErrorRecoveryTimer    | 30s    | Error flag auto-clear delay       |

### Bus Arbitration

- **Global Flag**: `ModbusBusy` (shared across all three rollers)
- **Purpose**: Prevents simultaneous Modbus operations
- **Usage**: Checked before any read/write operation
- **Released**: After each operation completes

## Alarm Logic

### Speed vs Torque Monitoring

**Condition**: `TorquePercentScaled > 20.0% AND OutputFreqScaled < (TorquePercentScaled × SPEED_TORQUE_RATIO)`

**Parameters**:

- **Threshold**: 20% torque
- **Ratio**: 0.5 Hz/% (configurable via SPEED_TORQUE_RATIO constant)
- **Delay**: 5 seconds before alarm activation
- **Purpose**: Detect motor stall or insufficient power conditions

**Example**:

```
If Torque = 80%
Expected Minimum Speed = 80% × 0.5 = 40 Hz
If Actual Speed < 40 Hz for 5 seconds → SpeedTorqueAlarm = TRUE
```

## Integration Notes

### PLC Side (Connected Components Workbench)

1. **Function Blocks Used**: `MSG_MODBUS`
2. **Data Types Required**:
   - `MODBUSLOCPARA` (Local configuration)
   - `MODBUSTARPARA` (Target configuration)
   - `MODBUSLOCADDR` (Address array)
3. **Array Size**: Minimum 2 elements for consecutive reads

### HMI Side (PanelView 800)

1. **Input Variables** (from HMI):

   - `TorqueMax_roloX` (UINT, 0.1% units)
   - `SpeedMax_roloX` (UINT, 0.1 Hz units)
   - `SpeedMin_roloX` (UINT, 0.1 Hz units)

2. **Display Variables** (to HMI):

   - `TorquePercentScaled_roloX` (REAL, %)
   - `OutputFreqScaled_roloX` (REAL, Hz)
   - `OutputCurrentScaled_roloX` (REAL, A)
   - `P0409Scaled_roloX` (REAL, units TBD)
   - `P0410Scaled_roloX` (REAL, units TBD)

3. **Status Indicators**:
   - `CommunicationOK_roloX` (BOOL)
   - `WriteError_roloX` (BOOL)
   - `ReadError_roloX` (BOOL)
   - `SpeedTorqueAlarm_roloX` (BOOL)

## Safety Limits

### Enforced in PLC Logic

| Parameter | Minimum | Maximum | Units |
| --------- | ------- | ------- | ----- |
| Speed     | 0.0     | 100.0   | Hz    |
| Torque    | 0.0     | 200.0   | %     |

**Implementation**: Values clamped before conversion to inverter units.

## Troubleshooting Guide

### Common Issues

1. **Communication Timeout**

   - Check physical RS-485 connection
   - Verify node address configuration
   - Check baud rate settings
   - Ensure only one device using Modbus at a time

2. **Parameter Not Writing**

   - Verify P0498 is set to 1 (enabled)
   - Check if inverter is in local control mode
   - Verify parameter is not locked by another function

3. **Incorrect Values**

   - Verify scaling factors in code match manual
   - Check data type conversions (UINT to REAL)
   - Ensure proper bounds checking before write

4. **Frequent Retries**

   - Increase communication timeout if needed
   - Check for electrical noise on RS-485 lines
   - Verify proper cable termination

5. **P0409/P0410 Unexpected Values**
   - Consult specific CFW500 manual for parameter definitions
   - Check inverter firmware version
   - Adjust scaling according to actual parameter function

## Future Expansion

To add new parameters to the system:

1. **Identify Parameter**: Consult CFW500 manual for number and function
2. **Add Variables**: Create raw (UINT) and scaled (REAL) variables
3. **Create MSG_MODBUS**: Instantiate new function block
4. **Add to Cycle**: Integrate into appropriate read cycle
5. **Implement Retry**: Add specific retry counter
6. **Update HMI**: Create display/input screens as needed

## Reference Documents

- **WEG CFW500 User Manual**: Parameter definitions and electrical specifications
- **WEG CFW500 Parameters Manual**: Firmware-specific parameter details
- **WEG CFW500 Modbus Manual**: Detailed register mapping and protocol specifications
- **Connected Components Workbench Help**: MSG_MODBUS function block documentation
- **Modbus RTU Specification**: Protocol details and timing requirements

## Version History

| Version | Date    | Changes                                                                                              |
| ------- | ------- | ---------------------------------------------------------------------------------------------------- |
| 1.0     | 2025-10 | Initial documentation                                                                                |
| 2.0     | 2025-10 | Added verification cycle, retry logic, alarm monitoring                                              |
| 2.1     | 2025-10 | Corrected timer periodicities to 10s                                                                 |
| 2.2     | 2025-10 | Added P0409/P0410 monitoring with separate 10s cycle, list of useful parameters for future expansion |
| 2.3     | 2025-10 | Corrected P0409/P0410 mapping and description, updated scaling information                           |
| 2.4     | 2025-10 | Updated control parameters table with default values and ranges                                      |

---

_Last Updated: October 2025_
_Project: Perfil Bobinadeira - Winding Machine Control System_
_Changelog: Added P0409/P0410, useful parameters list for future expansion, bus arbitration details_
