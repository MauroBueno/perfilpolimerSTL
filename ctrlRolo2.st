(* ST Program for CFW500 Parameter Control and Monitoring *)
(* For detailed Modbus register mapping and parameter documentation, see CFW500_Modbus_Mapping.md *)
(* Assumptions:
- Single inverter at Node = 2.
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
VerificationTimer_rolo2(IN := TRUE, PT := T#10s);
IF VerificationTimer_rolo2.Q THEN
    VerificationTrigger_rolo2 := TRUE;
    VerificationStep_rolo2 := 1;  // Start verification sequence
    VerificationTimer_rolo2(IN := FALSE); // Reset to restart timer
END_IF;

// Periodic Read Timer (every 10s for monitoring parameters)
ReadTimer_rolo2(IN := TRUE, PT := T#10s);
IF ReadTimer_rolo2.Q THEN
    ReadStep_rolo2 := 1;  // Start read sequence
    ReadTimer_rolo2(IN := FALSE); // Reset to restart timer
END_IF;

// Periodic Read Timer for P0408/P0409/P0410 (every 10s)
ReadTimer_P0408_P0410_rolo2(IN := TRUE, PT := T#10s);
IF ReadTimer_P0408_P0410_rolo2.Q THEN
    ReadStep_P0408_P0410_rolo2 := 1;  // Start P0408/P0409/P0410 read sequence
    ReadTimer_P0408_P0410_rolo2(IN := FALSE); // Reset to restart timer
END_IF;

// Detect changes in HMI values and compare with drive values to set write flag
IF TorqueMax_rolo2 <> TorqueMaxOld_rolo2 OR SpeedMax_rolo2 <> SpeedMaxOld_rolo2 OR SpeedMin_rolo2 <> SpeedMinOld_rolo2 THEN
    TorqueMaxOld_rolo2 := TorqueMax_rolo2;
    SpeedMaxOld_rolo2 := SpeedMax_rolo2;
    SpeedMinOld_rolo2 := SpeedMin_rolo2;
    // Check if different from drive values
    IF UINT(TorqueMax_rolo2 * 10) <> MaxTorqueRead_rolo2 OR UINT(SpeedMax_rolo2 * 100) <> MaxSpeedRead_rolo2 OR UINT(SpeedMin_rolo2 * 100) <> MinSpeedRead_rolo2 THEN
        WriteNeeded_rolo2 := TRUE;
    END_IF;
END_IF;

// Update set values from PV800 globals
// Parameter validation and bounds checking before scaling
// Ensures safe operation by clamping HMI inputs to valid ranges
IF SpeedMax_rolo2 > SPEED_MAX_LIMIT THEN
    SpeedMax_rolo2 := SPEED_MAX_LIMIT;
ELSIF SpeedMax_rolo2 < SPEED_MIN_LIMIT THEN
    SpeedMax_rolo2 := SPEED_MIN_LIMIT;
END_IF;

IF SpeedMin_rolo2 < SPEED_MIN_LIMIT THEN
    SpeedMin_rolo2 := SPEED_MIN_LIMIT;
ELSIF SpeedMin_rolo2 > SpeedMax_rolo2 THEN
    SpeedMin_rolo2 := SpeedMax_rolo2; // Ensure min <= max
END_IF;

IF TorqueMax_rolo2 > TORQUE_MAX_LIMIT THEN
    TorqueMax_rolo2 := TORQUE_MAX_LIMIT;
ELSIF TorqueMax_rolo2 < TORQUE_MIN_LIMIT THEN
    TorqueMax_rolo2 := TORQUE_MIN_LIMIT;
END_IF;

// Convert validated values to inverter units
MaxSpeedSet_rolo2 := UINT(SpeedMax_rolo2 * 100); // Convert Hz to 0.01 Hz units
MinSpeedSet_rolo2 := UINT(SpeedMin_rolo2 * 100);
MaxTorqueSet_rolo2 := UINT(TorqueMax_rolo2 * 10); // Convert % to 0.1% units
MinTorqueSet_rolo2 := UINT(0 * 10); // Assuming MinTorque is 0

// Write Logic (triggered by WriteNeeded or WriteTrigger; writes all params sequentially)
IF WriteNeeded_rolo2 OR WriteTrigger_rolo2 THEN
    CASE WriteStep_rolo2 OF
            0:
            LocalAddr_rolo2[1] := MaxSpeedSet_rolo2;
            TargetCfg_rolo2.Addr := 134;
            LocalCfg_rolo2.Cmd := 6;
            LocalCfg_rolo2.ElementCnt := 1;
            WriteMsg_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        IF WriteMsg_rolo2.Q THEN
                WriteStep_rolo2 := 1;
                MaxSpeedRead_rolo2 := LocalAddr_rolo2[1];
                WriteRetryCount_rolo2 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo2 < MAX_RETRIES THEN
                WriteRetryCount_rolo2 := WriteRetryCount_rolo2 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo2 := 1; // Advance on max retries reached
                WriteError_rolo2 := TRUE;
                WriteRetryCount_rolo2 := 0; // Reset for next operation
        END_IF;
            1:
            LocalAddr_rolo2[1] := MinSpeedSet_rolo2;
            TargetCfg_rolo2.Addr := 133;
            LocalCfg_rolo2.Cmd := 6;
            LocalCfg_rolo2.ElementCnt := 1;
            WriteMsg_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        IF WriteMsg_rolo2.Q THEN
                WriteStep_rolo2 := 2;
                MinSpeedRead_rolo2 := LocalAddr_rolo2[1];
                WriteRetryCount_rolo2 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo2 < MAX_RETRIES THEN
                WriteRetryCount_rolo2 := WriteRetryCount_rolo2 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo2 := 2; // Advance on max retries reached
                WriteError_rolo2 := TRUE;
                WriteRetryCount_rolo2 := 0; // Reset for next operation
        END_IF;
            2:
            LocalAddr_rolo2[1] := MaxTorqueSet_rolo2;
            TargetCfg_rolo2.Addr := 169;
            LocalCfg_rolo2.Cmd := 6;
            LocalCfg_rolo2.ElementCnt := 1;
            WriteMsg_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        IF WriteMsg_rolo2.Q THEN
                WriteStep_rolo2 := 3;
                MaxTorqueRead_rolo2 := LocalAddr_rolo2[1];
                WriteRetryCount_rolo2 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo2 < MAX_RETRIES THEN
                WriteRetryCount_rolo2 := WriteRetryCount_rolo2 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo2 := 3; // Advance on max retries reached
                WriteError_rolo2 := TRUE;
                WriteRetryCount_rolo2 := 0; // Reset for next operation
        END_IF;
            3:
            LocalAddr_rolo2[1] := MinTorqueSet_rolo2;
            TargetCfg_rolo2.Addr := 170;
            LocalCfg_rolo2.Cmd := 6;
            LocalCfg_rolo2.ElementCnt := 1;
            WriteMsg_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        IF WriteMsg_rolo2.Q THEN
                WriteStep_rolo2 := 4;
                MinTorqueRead_rolo2 := LocalAddr_rolo2[1];
                WriteRetryCount_rolo2 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo2 < MAX_RETRIES THEN
                WriteRetryCount_rolo2 := WriteRetryCount_rolo2 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo2 := 4; // Advance on max retries reached
                WriteError_rolo2 := TRUE;
                WriteRetryCount_rolo2 := 0; // Reset for next operation
        END_IF;
            4:
            // P0498 is boolean: TRUE = 1 (save), FALSE = 0 (don't save)
            IF P0498Set_rolo2 THEN
                LocalAddr_rolo2[1] := 1;
            ELSE
                LocalAddr_rolo2[1] := 0;
            END_IF;
            TargetCfg_rolo2.Addr := 498;
            LocalCfg_rolo2.Cmd := 6;
            LocalCfg_rolo2.ElementCnt := 1;
            WriteMsg_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        IF WriteMsg_rolo2.Q THEN
                WriteStep_rolo2 := 0;
                // Convert UINT response back to BOOL
                IF LocalAddr_rolo2[1] = 1 THEN
                    P0498Read_rolo2 := TRUE;
                ELSE
                    P0498Read_rolo2 := FALSE;
                END_IF;
                WriteTrigger_rolo2 := FALSE;
                WriteNeeded_rolo2 := FALSE;
                WriteRetryCount_rolo2 := 0; // Reset retry counter on success
        ELSIF WriteRetryCount_rolo2 < MAX_RETRIES THEN
                WriteRetryCount_rolo2 := WriteRetryCount_rolo2 + 1;
                // Retry the same operation
        ELSE
                WriteStep_rolo2 := 0; // Reset on max retries reached
                WriteTrigger_rolo2 := FALSE;
                WriteNeeded_rolo2 := FALSE;
                WriteError_rolo2 := TRUE;
                WriteRetryCount_rolo2 := 0; // Reset for next operation
        END_IF;
    END_CASE;
END_IF;

// Lógica para flags de erro e status
IF WriteMsg_rolo2.Q THEN
    WriteError_rolo2 := FALSE;
    CommunicationOK_rolo2 := TRUE;
ELSIF WriteRetryCount_rolo2 >= MAX_RETRIES THEN
    WriteError_rolo2 := TRUE;
    CommunicationOK_rolo2 := FALSE;
END_IF;

// Reset read error on successful read operations
IF ReadMsg_P0009_rolo2.Q OR ReadMsg_P0002_P0003_rolo2.Q OR ReadMsg_P0408_P0410_rolo2.Q THEN
    ReadError_rolo2 := FALSE;
    CommunicationOK_rolo2 := TRUE;
END_IF;

// Reset verification errors on successful verification operations
IF ReadMsg_P0100_rolo2.Q OR ReadMsg_P0134_P0133_rolo2.Q OR ReadMsg_P0169_P0170_rolo2.Q THEN
    // Verification errors are handled per operation, but we can clear general communication status
    CommunicationOK_rolo2 := TRUE;
END_IF;

// Error recovery mechanism - clear error flags after sustained successful communication
IF CommunicationOK_rolo2 THEN
    ErrorRecoveryTimer_rolo2(IN := TRUE, PT := ERROR_RECOVERY_TIME);
    IF ErrorRecoveryTimer_rolo2.Q THEN
        WriteError_rolo2 := FALSE;
        ReadError_rolo2 := FALSE;
        ErrorRecoveryTimer_rolo2(IN := FALSE); // Reset timer
    END_IF;
ELSE
    ErrorRecoveryTimer_rolo2(IN := FALSE); // Reset timer on communication failure
END_IF;

// Read Logic (sequential to avoid overloading Modbus channel)
CASE ReadStep_rolo2 OF
    1:  // Read P0009
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo2.Addr := 9;
            LocalCfg_rolo2.Cmd := 3;
            LocalCfg_rolo2.ElementCnt := 1;
            ReadMsg_P0009_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        END_IF;
        IF ReadMsg_P0009_rolo2.Q THEN
            TorquePercent_rolo2 := LocalAddr_rolo2[1];
            TempReal_rolo2 := UINT_TO_REAL(TorquePercent_rolo2);
            TorquePercentScaled_rolo2 := TempReal_rolo2 / 10.0;
            ReadStep_rolo2 := 2;
            ModbusBusy := FALSE;
            ReadRetryCount_rolo2 := 0; // Reset retry counter on success
        ELSIF ReadRetryCount_rolo2 < MAX_RETRIES THEN
            ReadRetryCount_rolo2 := ReadRetryCount_rolo2 + 1;
            ModbusBusy := FALSE; // Release bus for retry
            // Will retry on next cycle
        ELSE
            ReadStep_rolo2 := 2; // Advance on max retries
            ModbusBusy := FALSE;
            ReadError_rolo2 := TRUE;
            ReadRetryCount_rolo2 := 0; // Reset for next operation
        END_IF;
    2:  // Read P0002 and P0003
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo2.Addr := 2;
            LocalCfg_rolo2.Cmd := 3;
            LocalCfg_rolo2.ElementCnt := 2;
            ReadMsg_P0002_P0003_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        END_IF;
        IF ReadMsg_P0002_P0003_rolo2.Q THEN
            OutputFreq_rolo2 := LocalAddr_rolo2[1];
            OutputCurrent_rolo2 := LocalAddr_rolo2[2];
            TempReal_rolo2 := UINT_TO_REAL(OutputFreq_rolo2);
            OutputFreqScaled_rolo2 := TempReal_rolo2 / 10.0;
            TempReal_rolo2 := UINT_TO_REAL(OutputCurrent_rolo2);
            OutputCurrentScaled_rolo2 := TempReal_rolo2 / 10.0;
            
            // Speed vs Torque monitoring logic
            // Calculate expected minimum speed based on torque and ratio
            // If torque is high but speed is low, it may indicate motor stall or insufficient power
            IF TorquePercentScaled_rolo2 > 20.0 AND EnableDrive_rolo2 THEN  // Only monitor when drive is enabled and torque > 20%
                TempReal_rolo2 := TorquePercentScaled_rolo2 * SPEED_TORQUE_RATIO;  // Expected min speed = torque% * ratio
                IF OutputFreqScaled_rolo2 < TempReal_rolo2 THEN
                    // Speed is too low for the torque level - start alarm timer
                    SpeedTorqueAlarmTimer_rolo2(IN := TRUE, PT := SPEED_TORQUE_ALARM_DELAY);
                    IF SpeedTorqueAlarmTimer_rolo2.Q THEN
                        SpeedTorqueAlarm_rolo2 := TRUE;
                    END_IF;
                ELSE
                    // Speed is adequate - reset alarm
                    SpeedTorqueAlarm_rolo2 := FALSE;
                    SpeedTorqueAlarmTimer_rolo2(IN := FALSE);
                END_IF;
            ELSE
                // Reset alarm when drive disabled or low torque
                SpeedTorqueAlarm_rolo2 := FALSE;
                SpeedTorqueAlarmTimer_rolo2(IN := FALSE);
            END_IF;
            
            ReadStep_rolo2 := 0;  // Reset for next cycle
            ReadTrigger_rolo2 := FALSE;
            ModbusBusy := FALSE;
            ReadRetryCount_rolo2 := 0; // Reset retry counter on success
        ELSIF ReadRetryCount_rolo2 < MAX_RETRIES THEN
            ReadRetryCount_rolo2 := ReadRetryCount_rolo2 + 1;
            ModbusBusy := FALSE; // Release bus for retry
            // Will retry on next cycle
        ELSE
            ReadStep_rolo2 := 0; // Reset on max retries
            ReadTrigger_rolo2 := FALSE;
            ModbusBusy := FALSE;
            ReadError_rolo2 := TRUE;
            ReadRetryCount_rolo2 := 0; // Reset for next operation
        END_IF;
    END_CASE;

// Read Logic for P0408, P0409 and P0410 (separate 10-second cycle)
CASE ReadStep_P0408_P0410_rolo2 OF
    1:  // Read P0408, P0409 and P0410
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo2.Addr := 408;
            LocalCfg_rolo2.Cmd := 3;
            LocalCfg_rolo2.ElementCnt := 3;
            ReadMsg_P0408_P0410_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        END_IF;
        IF ReadMsg_P0408_P0410_rolo2.Q THEN
            P0408_rolo2 := LocalAddr_rolo2[1];  // Boolean: 0 or 1 (Vector Sensorless Enable)
            P0409_rolo2 := LocalAddr_rolo2[2];  // Stator Resistance (Rs) in ohms
            P0410_rolo2 := LocalAddr_rolo2[3];  // Magnetizing Current (Im) in amperes
            
            // Scale P0408 (Boolean)
            TempReal_rolo2 := UINT_TO_REAL(P0408_rolo2);
            P0408Scaled_rolo2 := TempReal_rolo2; // Will be 0.0 or 1.0 for boolean display
            
            // Scale P0409 (Stator Resistance in 0.01 ohm units)
            TempReal_rolo2 := UINT_TO_REAL(P0409_rolo2);
            P0409Scaled_rolo2 := TempReal_rolo2 / 100.0; // Convert to ohms
            
            // Scale P0410 (Magnetizing Current in 0.01 A units)
            TempReal_rolo2 := UINT_TO_REAL(P0410_rolo2);
            P0410Scaled_rolo2 := TempReal_rolo2 / 100.0; // Convert to amperes
            
            ReadStep_P0408_P0410_rolo2 := 0;  // Reset for next cycle
            ModbusBusy := FALSE;
            ReadRetryCount_P0408_P0410_rolo2 := 0; // Reset retry counter on success
        ELSIF ReadRetryCount_P0408_P0410_rolo2 < MAX_RETRIES THEN
            ReadRetryCount_P0408_P0410_rolo2 := ReadRetryCount_P0408_P0410_rolo2 + 1;
            ModbusBusy := FALSE; // Release bus for retry
            // Will retry on next cycle
        ELSE
            ReadStep_P0408_P0410_rolo2 := 0; // Reset on max retries
            ModbusBusy := FALSE;
            ReadError_rolo2 := TRUE;
            ReadRetryCount_P0408_P0410_rolo2 := 0; // Reset for next operation
        END_IF;
    END_CASE;

// Verification Logic (sequential to avoid overloading Modbus channel, check and force parameters)
CASE VerificationStep_rolo2 OF
    1:  // Read P0100 (Control Type)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo2.Addr := 100;
            LocalCfg_rolo2.Cmd := 3;
            LocalCfg_rolo2.ElementCnt := 1;
            ReadMsg_P0100_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        END_IF;
        IF ReadMsg_P0100_rolo2.Q THEN
            ControlTypeRead_rolo2 := LocalAddr_rolo2[1];
            IF ControlTypeRead_rolo2 <> ControlTypeSet_rolo2 THEN
                // Force write P0100
                LocalAddr_rolo2[1] := ControlTypeSet_rolo2;
                TargetCfg_rolo2.Addr := 100;
                LocalCfg_rolo2.Cmd := 6;
                LocalCfg_rolo2.ElementCnt := 1;
                WriteMsg_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
                IF WriteMsg_rolo2.Q THEN
                    VerificationStep_rolo2 := 2;
                    VerificationRetryCount_rolo2 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo2 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo2 := VerificationRetryCount_rolo2 + 1;
                ELSE
                    VerificationStep_rolo2 := 2; // Advance on max retries
                    VerificationRetryCount_rolo2 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo2 := 2;
                VerificationRetryCount_rolo2 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo2 < MAX_RETRIES THEN
            VerificationRetryCount_rolo2 := VerificationRetryCount_rolo2 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo2 := 2; // Advance on max retries
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo2 := 0;
        END_IF;
    2:  // Read P0134 and P0133 (Max/Min Speed)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo2.Addr := 134;
            LocalCfg_rolo2.Cmd := 3;
            LocalCfg_rolo2.ElementCnt := 2;
            ReadMsg_P0134_P0133_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        END_IF;
        IF ReadMsg_P0134_P0133_rolo2.Q THEN
            MaxSpeedRead_rolo2 := LocalAddr_rolo2[1];
            MinSpeedRead_rolo2 := LocalAddr_rolo2[2];
            IF MaxSpeedRead_rolo2 <> MaxSpeedSet_rolo2 OR MinSpeedRead_rolo2 <> MinSpeedSet_rolo2 THEN
                // Force write P0134 and P0133
                LocalAddr_rolo2[1] := MaxSpeedSet_rolo2;
                LocalAddr_rolo2[2] := MinSpeedSet_rolo2;
                TargetCfg_rolo2.Addr := 134;
                LocalCfg_rolo2.Cmd := 16; // Preset Multiple Registers for consecutive
                LocalCfg_rolo2.ElementCnt := 2;
                WriteMsg_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
                IF WriteMsg_rolo2.Q THEN
                    VerificationStep_rolo2 := 3;
                    VerificationRetryCount_rolo2 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo2 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo2 := VerificationRetryCount_rolo2 + 1;
                ELSE
                    VerificationStep_rolo2 := 3; // Advance on max retries
                    VerificationRetryCount_rolo2 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo2 := 3;
                VerificationRetryCount_rolo2 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo2 < MAX_RETRIES THEN
            VerificationRetryCount_rolo2 := VerificationRetryCount_rolo2 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo2 := 3; // Advance on max retries
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo2 := 0;
        END_IF;
    3:  // Read P0169 and P0170 (Max/Min Torque)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo2.Addr := 169;
            LocalCfg_rolo2.Cmd := 3;
            LocalCfg_rolo2.ElementCnt := 2;
            ReadMsg_P0169_P0170_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
        END_IF;
        IF ReadMsg_P0169_P0170_rolo2.Q THEN
            MaxTorqueRead_rolo2 := LocalAddr_rolo2[1];
            MinTorqueRead_rolo2 := LocalAddr_rolo2[2];
            IF MaxTorqueRead_rolo2 <> MaxTorqueSet_rolo2 OR MinTorqueRead_rolo2 <> MinTorqueSet_rolo2 THEN
                // Force write P0169 and P0170
                LocalAddr_rolo2[1] := MaxTorqueSet_rolo2;
                LocalAddr_rolo2[2] := MinTorqueSet_rolo2;
                TargetCfg_rolo2.Addr := 169;
                LocalCfg_rolo2.Cmd := 16; // Preset Multiple Registers
                LocalCfg_rolo2.ElementCnt := 2;
                WriteMsg_rolo2(IN := TRUE, LocalCfg := LocalCfg_rolo2, TargetCfg := TargetCfg_rolo2, LocalAddr := LocalAddr_rolo2);
                IF WriteMsg_rolo2.Q THEN
                    VerificationStep_rolo2 := 0; // Reset
                    VerificationTrigger_rolo2 := FALSE;
                    VerificationRetryCount_rolo2 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo2 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo2 := VerificationRetryCount_rolo2 + 1;
                ELSE
                    VerificationStep_rolo2 := 0; // Reset on max retries
                    VerificationTrigger_rolo2 := FALSE;
                    VerificationRetryCount_rolo2 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo2 := 0; // Reset
                VerificationTrigger_rolo2 := FALSE;
                VerificationRetryCount_rolo2 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo2 < MAX_RETRIES THEN
            VerificationRetryCount_rolo2 := VerificationRetryCount_rolo2 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo2 := 0; // Reset on max retries
            VerificationTrigger_rolo2 := FALSE;
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo2 := 0;
        END_IF;
    END_CASE;
