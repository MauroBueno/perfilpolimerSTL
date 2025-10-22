(* ST Program for CFW500 Parameter Control and Monitoring *)
(* For detailed Modbus register mapping and parameter documentation, see CFW500_Modbus_Mapping.md *)
(* Assumptions:
- Single inverter at Node = 3.
- Registers are direct: Pxxxx at holding register xxxx.
- Scaling: Values are integers; for decimals (e.g., P0009 in 0.1%), divide by 10.0 for REAL display.
- P0498 assumed as UINT (0/1 for disable/enable); adjust if different.
- Writes triggered by WriteTrigger BOOL (e.g., from HMI or logic).
- Reads every 1 second for P0009, P0002, P0003 (torque, output frequency, output current).
- Verification every 10 seconds for critical parameters (P0100, speeds, torques) to force Vector Sensorless and limits.
- Use separate MSG_MODBUS instances to avoid conflicts.
- Add error handling (e.g., check .Q and .Error) as needed.
*)

// Periodic Verification Timer (every 10s to check critical parameters)
VerificationTimer_rolo3(IN := TRUE, PT := T#10s);
IF VerificationTimer_rolo3.Q THEN
    VerificationTrigger_rolo3 := TRUE;
    VerificationStep_rolo3 := 1;  // Start verification sequence
    VerificationTimer_rolo3(IN := FALSE); // Reset to restart timer
END_IF;

// Periodic Read Timer (every 1s for monitoring parameters)
ReadTimer_rolo3(IN := TRUE, PT := T#1s);
IF ReadTimer_rolo3.Q THEN
    ReadStep_rolo3 := 1;  // Start read sequence
    ReadTimer_rolo3(IN := FALSE); // Reset to restart timer
END_IF;

// Detect changes in HMI values and compare with drive values to set write flag
IF TorqueMax_rolo3 <> TorqueMaxOld_rolo3 OR SpeedMax_rolo3 <> SpeedMaxOld_rolo3 OR SpeedMin_rolo3 <> SpeedMinOld_rolo3 THEN
    TorqueMaxOld_rolo3 := TorqueMax_rolo3;
    SpeedMaxOld_rolo3 := SpeedMax_rolo3;
    SpeedMinOld_rolo3 := SpeedMin_rolo3;
    // Check if different from drive values
    IF UINT(TorqueMax_rolo3 * 10) <> MaxTorqueRead_rolo3 OR UINT(SpeedMax_rolo3 * 100) <> MaxSpeedRead_rolo3 OR UINT(SpeedMin_rolo3 * 100) <> MinSpeedRead_rolo3 THEN
        WriteNeeded_rolo3 := TRUE;
    END_IF;
END_IF;

// Update set values from PV800 globals
// Parameter validation and bounds checking before scaling
// Ensures safe operation by clamping HMI inputs to valid ranges
IF SpeedMax_rolo3 > SPEED_MAX_LIMIT THEN
    SpeedMax_rolo3 := SPEED_MAX_LIMIT;
ELSIF SpeedMax_rolo3 < SPEED_MIN_LIMIT THEN
    SpeedMax_rolo3 := SPEED_MIN_LIMIT;
END_IF;

IF SpeedMin_rolo3 < SPEED_MIN_LIMIT THEN
    SpeedMin_rolo3 := SPEED_MIN_LIMIT;
ELSIF SpeedMin_rolo3 > SpeedMax_rolo3 THEN
    SpeedMin_rolo3 := SpeedMax_rolo3; // Ensure min <= max
END_IF;

IF TorqueMax_rolo3 > TORQUE_MAX_LIMIT THEN
    TorqueMax_rolo3 := TORQUE_MAX_LIMIT;
ELSIF TorqueMax_rolo3 < TORQUE_MIN_LIMIT THEN
    TorqueMax_rolo3 := TORQUE_MIN_LIMIT;
END_IF;

// Convert validated values to inverter units
MaxSpeedSet_rolo3 := UINT(SpeedMax_rolo3 * 100); // Convert Hz to 0.01 Hz units
MinSpeedSet_rolo3 := UINT(SpeedMin_rolo3 * 100);
MaxTorqueSet_rolo3 := UINT(TorqueMax_rolo3 * 10); // Convert % to 0.1% units
MinTorqueSet_rolo3 := UINT(0 * 10); // Assuming MinTorque is 0

// Write Logic (triggered by WriteNeeded or WriteTrigger; writes all params sequentially)
IF WriteNeeded_rolo3 OR WriteTrigger_rolo3 THEN
    CASE WriteStep_rolo3 OF
            0:
            LocalAddr_rolo3[1] := MaxSpeedSet_rolo3;
            TargetCfg_rolo3.Addr := 134;
            LocalCfg_rolo3.Cmd := 6;
            LocalCfg_rolo3.ElementCnt := 1;
            WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        IF WriteMsg_rolo3.Q THEN
                WriteStep_rolo3 := 1;
                MaxSpeedRead_rolo3 := LocalAddr_rolo3[1];
                WriteRetryCount_rolo3 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo3 := 1; // Advance on max retries reached
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0; // Reset for next operation
        END_IF;
            1:
            LocalAddr_rolo3[1] := MinSpeedSet_rolo3;
            TargetCfg_rolo3.Addr := 133;
            LocalCfg_rolo3.Cmd := 6;
            LocalCfg_rolo3.ElementCnt := 1;
            WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        IF WriteMsg_rolo3.Q THEN
                WriteStep_rolo3 := 2;
                MinSpeedRead_rolo3 := LocalAddr_rolo3[1];
                WriteRetryCount_rolo3 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo3 := 2; // Advance on max retries reached
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0; // Reset for next operation
        END_IF;
            2:
            LocalAddr_rolo3[1] := MaxTorqueSet_rolo3;
            TargetCfg_rolo3.Addr := 169;
            LocalCfg_rolo3.Cmd := 6;
            LocalCfg_rolo3.ElementCnt := 1;
            WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        IF WriteMsg_rolo3.Q THEN
                WriteStep_rolo3 := 3;
                MaxTorqueRead_rolo3 := LocalAddr_rolo3[1];
                WriteRetryCount_rolo3 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo3 := 3; // Advance on max retries reached
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0; // Reset for next operation
        END_IF;
            3:
            LocalAddr_rolo3[1] := MinTorqueSet_rolo3;
            TargetCfg_rolo3.Addr := 170;
            LocalCfg_rolo3.Cmd := 6;
            LocalCfg_rolo3.ElementCnt := 1;
            WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        IF WriteMsg_rolo3.Q THEN
                WriteStep_rolo3 := 4;
                MinTorqueRead_rolo3 := LocalAddr_rolo3[1];
                WriteRetryCount_rolo3 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo3 := 4; // Advance on max retries reached
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0; // Reset for next operation
        END_IF;
            4:
            LocalAddr_rolo3[1] := P0498Set_rolo3;
            TargetCfg_rolo3.Addr := 498;
            LocalCfg_rolo3.Cmd := 6;
            LocalCfg_rolo3.ElementCnt := 1;
            WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        IF WriteMsg_rolo3.Q THEN
                WriteStep_rolo3 := 0;
                P0498Read_rolo3 := LocalAddr_rolo3[1];
                WriteTrigger_rolo3 := FALSE;
                WriteNeeded_rolo3 := FALSE;
                WriteRetryCount_rolo3 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo3 := 0; // Reset on max retries reached
                WriteTrigger_rolo3 := FALSE;
                WriteNeeded_rolo3 := FALSE;
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0; // Reset for next operation
        END_IF;
    END_CASE;

// Lógica para flags de erro e status
IF WriteMsg_rolo3.Q THEN
    WriteError_rolo3 := FALSE;
    CommunicationOK_rolo3 := TRUE;
ELSIF WriteRetryCount_rolo3 >= MAX_RETRIES THEN
    WriteError_rolo3 := TRUE;
    CommunicationOK_rolo3 := FALSE;
END_IF;

// Reset read error on successful read operations
IF ReadMsg_P0009_rolo3.Q OR ReadMsg_P0002_P0003_rolo3.Q THEN
    ReadError_rolo3 := FALSE;
    CommunicationOK_rolo3 := TRUE;
END_IF;

// Reset verification errors on successful verification operations
IF ReadMsg_P0100_rolo3.Q OR ReadMsg_P0134_P0133_rolo3.Q OR ReadMsg_P0169_P0170_rolo3.Q THEN
    // Verification errors are handled per operation, but we can clear general communication status
    CommunicationOK_rolo3 := TRUE;
END_IF;

// Error recovery mechanism - clear error flags after sustained successful communication
IF CommunicationOK_rolo3 THEN
    ErrorRecoveryTimer_rolo3(IN := TRUE, PT := ERROR_RECOVERY_TIME);
    IF ErrorRecoveryTimer_rolo3.Q THEN
        WriteError_rolo3 := FALSE;
        ReadError_rolo3 := FALSE;
        ErrorRecoveryTimer_rolo3(IN := FALSE); // Reset timer
    END_IF;
ELSE
    ErrorRecoveryTimer_rolo3(IN := FALSE); // Reset timer on communication failure
END_IF;

// Read Logic (sequential to avoid overloading Modbus channel)
CASE ReadStep_rolo3 OF
    1:  // Read P0009
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo3.Addr := 9;
            LocalCfg_rolo3.Cmd := 3;
            LocalCfg_rolo3.ElementCnt := 1;
            ReadMsg_P0009_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        END_IF;
        IF ReadMsg_P0009_rolo3.Q THEN
            TorquePercent_rolo3 := LocalAddr_rolo3[1];
            TempReal_rolo3 := UINT_TO_REAL(TorquePercent_rolo3);
            TorquePercentScaled_rolo3 := TempReal_rolo3 / 10.0;
            ReadStep_rolo3 := 2;
            ModbusBusy := FALSE;
            ReadRetryCount_rolo3 := 0; // Reset retry counter on success
        ELSIF ReadRetryCount_rolo3 < MAX_RETRIES THEN
            ReadRetryCount_rolo3 := ReadRetryCount_rolo3 + 1;
            ModbusBusy := FALSE; // Release bus for retry
            // Will retry on next cycle
        ELSE
            ReadStep_rolo3 := 2; // Advance on max retries
            ModbusBusy := FALSE;
            ReadError_rolo3 := TRUE;
            ReadRetryCount_rolo3 := 0; // Reset for next operation
        END_IF;
    2:  // Read P0002 and P0003
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo3.Addr := 2;
            LocalCfg_rolo3.Cmd := 3;
            LocalCfg_rolo3.ElementCnt := 2;
            ReadMsg_P0002_P0003_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        END_IF;
        IF ReadMsg_P0002_P0003_rolo3.Q THEN
            OutputFreq_rolo3 := LocalAddr_rolo3[1];
            OutputCurrent_rolo3 := LocalAddr_rolo3[2];
            TempReal_rolo3 := UINT_TO_REAL(OutputFreq_rolo3);
            OutputFreqScaled_rolo3 := TempReal_rolo3 / 10.0;
            TempReal_rolo3 := UINT_TO_REAL(OutputCurrent_rolo3);
            OutputCurrentScaled_rolo3 := TempReal_rolo3 / 10.0;
            
            // Speed vs Torque monitoring logic
            // Calculate expected minimum speed based on torque and ratio
            // If torque is high but speed is low, it may indicate motor stall or insufficient power
            IF TorquePercentScaled_rolo3 > 20.0 AND EnableDrive_rolo3 THEN  // Only monitor when drive is enabled and torque > 20%
                TempReal_rolo3 := TorquePercentScaled_rolo3 * SPEED_TORQUE_RATIO;  // Expected min speed = torque% * ratio
                IF OutputFreqScaled_rolo3 < TempReal_rolo3 THEN
                    // Speed is too low for the torque level - start alarm timer
                    SpeedTorqueAlarmTimer_rolo3(IN := TRUE, PT := SPEED_TORQUE_ALARM_DELAY);
                    IF SpeedTorqueAlarmTimer_rolo3.Q THEN
                        SpeedTorqueAlarm_rolo3 := TRUE;
                    END_IF;
                ELSE
                    // Speed is adequate - reset alarm
                    SpeedTorqueAlarm_rolo3 := FALSE;
                    SpeedTorqueAlarmTimer_rolo3(IN := FALSE);
                END_IF;
            ELSE
                // Reset alarm when drive disabled or low torque
                SpeedTorqueAlarm_rolo3 := FALSE;
                SpeedTorqueAlarmTimer_rolo3(IN := FALSE);
            END_IF;
            
            ReadStep_rolo3 := 0;  // Reset for next cycle
            ReadTrigger_rolo3 := FALSE;
            ModbusBusy := FALSE;
            ReadRetryCount_rolo3 := 0; // Reset retry counter on success
        ELSIF ReadRetryCount_rolo3 < MAX_RETRIES THEN
            ReadRetryCount_rolo3 := ReadRetryCount_rolo3 + 1;
            ModbusBusy := FALSE; // Release bus for retry
            // Will retry on next cycle
        ELSE
            ReadStep_rolo3 := 0; // Reset on max retries
            ReadTrigger_rolo3 := FALSE;
            ModbusBusy := FALSE;
            ReadError_rolo3 := TRUE;
            ReadRetryCount_rolo3 := 0; // Reset for next operation
        END_IF;
    END_CASE;

// Verification Logic (sequential to avoid overloading Modbus channel, check and force parameters)
CASE VerificationStep_rolo3 OF
    1:  // Read P0100 (Control Type)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo3.Addr := 100;
            LocalCfg_rolo3.Cmd := 3;
            LocalCfg_rolo3.ElementCnt := 1;
            ReadMsg_P0100_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        END_IF;
        IF ReadMsg_P0100_rolo3.Q THEN
            ControlTypeRead_rolo3 := LocalAddr_rolo3[1];
            IF ControlTypeRead_rolo3 <> ControlTypeSet_rolo3 THEN
                // Force write P0100
                LocalAddr_rolo3[1] := ControlTypeSet_rolo3;
                TargetCfg_rolo3.Addr := 100;
                LocalCfg_rolo3.Cmd := 6;
                LocalCfg_rolo3.ElementCnt := 1;
                WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
                IF WriteMsg_rolo3.Q THEN
                    VerificationStep_rolo3 := 2;
                    VerificationRetryCount_rolo3 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
                ELSE
                    VerificationStep_rolo3 := 2; // Advance on max retries
                    VerificationRetryCount_rolo3 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo3 := 2;
                VerificationRetryCount_rolo3 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
            VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo3 := 2; // Advance on max retries
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo3 := 0;
        END_IF;
    2:  // Read P0134 and P0133 (Max/Min Speed)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo3.Addr := 134;
            LocalCfg_rolo3.Cmd := 3;
            LocalCfg_rolo3.ElementCnt := 2;
            ReadMsg_P0134_P0133_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        END_IF;
        IF ReadMsg_P0134_P0133_rolo3.Q THEN
            MaxSpeedRead_rolo3 := LocalAddr_rolo3[1];
            MinSpeedRead_rolo3 := LocalAddr_rolo3[2];
            IF MaxSpeedRead_rolo3 <> MaxSpeedSet_rolo3 OR MinSpeedRead_rolo3 <> MinSpeedSet_rolo3 THEN
                // Force write P0134 and P0133
                LocalAddr_rolo3[1] := MaxSpeedSet_rolo3;
                LocalAddr_rolo3[2] := MinSpeedSet_rolo3;
                TargetCfg_rolo3.Addr := 134;
                LocalCfg_rolo3.Cmd := 16; // Preset Multiple Registers for consecutive
                LocalCfg_rolo3.ElementCnt := 2;
                WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
                IF WriteMsg_rolo3.Q THEN
                    VerificationStep_rolo3 := 3;
                    VerificationRetryCount_rolo3 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
                ELSE
                    VerificationStep_rolo3 := 3; // Advance on max retries
                    VerificationRetryCount_rolo3 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo3 := 3;
                VerificationRetryCount_rolo3 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
            VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo3 := 3; // Advance on max retries
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo3 := 0;
        END_IF;
    3:  // Read P0169 and P0170 (Max/Min Torque)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo3.Addr := 169;
            LocalCfg_rolo3.Cmd := 3;
            LocalCfg_rolo3.ElementCnt := 2;
            ReadMsg_P0169_P0170_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        END_IF;
        IF ReadMsg_P0169_P0170_rolo3.Q THEN
            MaxTorqueRead_rolo3 := LocalAddr_rolo3[1];
            MinTorqueRead_rolo3 := LocalAddr_rolo3[2];
            IF MaxTorqueRead_rolo3 <> MaxTorqueSet_rolo3 OR MinTorqueRead_rolo3 <> MinTorqueSet_rolo3 THEN
                // Force write P0169 and P0170
                LocalAddr_rolo3[1] := MaxTorqueSet_rolo3;
                LocalAddr_rolo3[2] := MinTorqueSet_rolo3;
                TargetCfg_rolo3.Addr := 169;
                LocalCfg_rolo3.Cmd := 16; // Preset Multiple Registers
                LocalCfg_rolo3.ElementCnt := 2;
                WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
                IF WriteMsg_rolo3.Q THEN
                    VerificationStep_rolo3 := 0; // Reset
                    VerificationTrigger_rolo3 := FALSE;
                    VerificationRetryCount_rolo3 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
                ELSE
                    VerificationStep_rolo3 := 0; // Reset on max retries
                    VerificationTrigger_rolo3 := FALSE;
                    VerificationRetryCount_rolo3 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo3 := 0; // Reset
                VerificationTrigger_rolo3 := FALSE;
                VerificationRetryCount_rolo3 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
            VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo3 := 0; // Reset on max retries
            VerificationTrigger_rolo3 := FALSE;
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo3 := 0;
        END_IF;
    END_CASE;
