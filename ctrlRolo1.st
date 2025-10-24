(* ST Program for CFW500 Parameter Control and Monitoring - Rolo 1 *)
(* For detailed Modbus register mapping and parameter documentation, see CFW500_Modbus_Mapping.md *)
(* Assumptions:
- Single inverter at Node = 1.
- Registers are direct: Pxxxx at holding register xxxx.
- Scaling: Values are integers; for decimals (e.g., P0009 in 0.1%), divide by 10.0 for REAL display.
- P0498 assumed as UINT (0/1 for disable/enable); adjust if different.
- Writes triggered by WriteTrigger BOOL (e.g., from HMI or logic).
- Reads every 10 second for P0009, P0002, P0003 (torque, output frequency, output current).
- Reads every 10 seconds for P0409, P0410.
- Verification every 10 seconds for critical parameters (P0100, speeds, torques) to force Vector Sensorless and limits.
- Use separate MSG_MODBUS instances to avoid conflicts.
- Add error handling (e.g., check .Q and .Error) as needed.
*)

// Periodic Verification Timer (every 10s to check critical parameters)
VerificationTimer_rolo1(IN := TRUE, PT := T#10s);
IF VerificationTimer_rolo1.Q THEN
    VerificationTrigger_rolo1 := TRUE;
    VerificationStep_rolo1 := 1;  // Start verification sequence
    VerificationTimer_rolo1(IN := FALSE); // Reset to restart timer
END_IF;

// Periodic Read Timer (every 10s for monitoring parameters)
ReadTimer_rolo1(IN := TRUE, PT := T#10s);
IF ReadTimer_rolo1.Q THEN
    ReadStep_rolo1 := 1;  // Start read sequence
    ReadTimer_rolo1(IN := FALSE); // Reset to restart timer
END_IF;

// Periodic Read Timer for P0409/P0410 (every 10s)
ReadTimer_P0409_P0410_rolo1(IN := TRUE, PT := T#10s);
IF ReadTimer_P0409_P0410_rolo1.Q THEN
    ReadStep_P0409_P0410_rolo1 := 1;  // Start P0409/P0410 read sequence
    ReadTimer_P0409_P0410_rolo1(IN := FALSE); // Reset to restart timer
END_IF;

// Detect changes in HMI values and compare with drive values to set write flag
IF TorqueMax_rolo1 <> TorqueMaxOld_rolo1 OR SpeedMax_rolo1 <> SpeedMaxOld_rolo1 OR SpeedMin_rolo1 <> SpeedMinOld_rolo1 THEN
    TorqueMaxOld_rolo1 := TorqueMax_rolo1;
    SpeedMaxOld_rolo1 := SpeedMax_rolo1;
    SpeedMinOld_rolo1 := SpeedMin_rolo1;
    // Check if different from drive values
    IF UINT(TorqueMax_rolo1 * 10) <> MaxTorqueRead_rolo1 OR UINT(SpeedMax_rolo1 * 100) <> MaxSpeedRead_rolo1 OR UINT(SpeedMin_rolo1 * 100) <> MinSpeedRead_rolo1 THEN
        WriteNeeded_rolo1 := TRUE;
    END_IF;
END_IF;

// Update set values from PV800 globals
// Parameter validation and bounds checking before scaling
// Ensures safe operation by clamping HMI inputs to valid ranges
IF SpeedMax_rolo1 > SPEED_MAX_LIMIT THEN
    SpeedMax_rolo1 := SPEED_MAX_LIMIT;
ELSIF SpeedMax_rolo1 < SPEED_MIN_LIMIT THEN
    SpeedMax_rolo1 := SPEED_MIN_LIMIT;
END_IF;

IF SpeedMin_rolo1 < SPEED_MIN_LIMIT THEN
    SpeedMin_rolo1 := SPEED_MIN_LIMIT;
ELSIF SpeedMin_rolo1 > SpeedMax_rolo1 THEN
    SpeedMin_rolo1 := SpeedMax_rolo1; // Ensure min <= max
END_IF;

IF TorqueMax_rolo1 > TORQUE_MAX_LIMIT THEN
    TorqueMax_rolo1 := TORQUE_MAX_LIMIT;
ELSIF TorqueMax_rolo1 < TORQUE_MIN_LIMIT THEN
    TorqueMax_rolo1 := TORQUE_MIN_LIMIT;
END_IF;

// Convert validated values to inverter units
MaxSpeedSet_rolo1 := UINT(SpeedMax_rolo1 * 100); // Convert Hz to 0.01 Hz units
MinSpeedSet_rolo1 := UINT(SpeedMin_rolo1 * 100);
MaxTorqueSet_rolo1 := UINT(TorqueMax_rolo1 * 10); // Convert % to 0.1% units
MinTorqueSet_rolo1 := UINT(0 * 10); // Assuming MinTorque is 0

// Write Logic (triggered by WriteNeeded or WriteTrigger; writes all params sequentially)
IF WriteNeeded_rolo1 OR WriteTrigger_rolo1 THEN
    CASE WriteStep_rolo1 OF
        0:
            LocalAddr_rolo1[1] := MaxSpeedSet_rolo1;
            TargetCfg_rolo1.Addr := 134;
            LocalCfg_rolo1.Cmd := 6;
            LocalCfg_rolo1.ElementCnt := 1;
            WriteMsg_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
            IF WriteMsg_rolo1.Q THEN
                WriteStep_rolo1 := 1;
                MaxSpeedRead_rolo1 := LocalAddr_rolo1[1];
                WriteRetryCount_rolo1 := 0;
            ELSIF WriteRetryCount_rolo1 < MAX_RETRIES THEN
                WriteRetryCount_rolo1 := WriteRetryCount_rolo1 + 1;
            ELSE
                WriteStep_rolo1 := 1;
                WriteError_rolo1 := TRUE;
                WriteRetryCount_rolo1 := 0;
            END_IF;
        1:
            LocalAddr_rolo1[1] := MinSpeedSet_rolo1;
            TargetCfg_rolo1.Addr := 133;
            LocalCfg_rolo1.Cmd := 6;
            LocalCfg_rolo1.ElementCnt := 1;
            WriteMsg_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
            IF WriteMsg_rolo1.Q THEN
                WriteStep_rolo1 := 2;
                MinSpeedRead_rolo1 := LocalAddr_rolo1[1];
                WriteRetryCount_rolo1 := 0;
            ELSIF WriteRetryCount_rolo1 < MAX_RETRIES THEN
                WriteRetryCount_rolo1 := WriteRetryCount_rolo1 + 1;
            ELSE
                WriteStep_rolo1 := 2;
                WriteError_rolo1 := TRUE;
                WriteRetryCount_rolo1 := 0;
            END_IF;
        2:
            LocalAddr_rolo1[1] := MaxTorqueSet_rolo1;
            TargetCfg_rolo1.Addr := 169;
            LocalCfg_rolo1.Cmd := 6;
            LocalCfg_rolo1.ElementCnt := 1;
            WriteMsg_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
            IF WriteMsg_rolo1.Q THEN
                WriteStep_rolo1 := 3;
                MaxTorqueRead_rolo1 := LocalAddr_rolo1[1];
                WriteRetryCount_rolo1 := 0;
            ELSIF WriteRetryCount_rolo1 < MAX_RETRIES THEN
                WriteRetryCount_rolo1 := WriteRetryCount_rolo1 + 1;
            ELSE
                WriteStep_rolo1 := 3;
                WriteError_rolo1 := TRUE;
                WriteRetryCount_rolo1 := 0;
            END_IF;
        3:
            LocalAddr_rolo1[1] := MinTorqueSet_rolo1;
            TargetCfg_rolo1.Addr := 170;
            LocalCfg_rolo1.Cmd := 6;
            LocalCfg_rolo1.ElementCnt := 1;
            WriteMsg_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
            IF WriteMsg_rolo1.Q THEN
                WriteStep_rolo1 := 4;
                MinTorqueRead_rolo1 := LocalAddr_rolo1[1];
                WriteRetryCount_rolo1 := 0;
            ELSIF WriteRetryCount_rolo1 < MAX_RETRIES THEN
                WriteRetryCount_rolo1 := WriteRetryCount_rolo1 + 1;
            ELSE
                WriteStep_rolo1 := 4;
                WriteError_rolo1 := TRUE;
                WriteRetryCount_rolo1 := 0;
            END_IF;
        4:
            LocalAddr_rolo1[1] := P0498Set_rolo1;
            TargetCfg_rolo1.Addr := 498;
            LocalCfg_rolo1.Cmd := 6;
            LocalCfg_rolo1.ElementCnt := 1;
            WriteMsg_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
            IF WriteMsg_rolo1.Q THEN
                WriteStep_rolo1 := 0;
                P0498Read_rolo1 := LocalAddr_rolo1[1];
                WriteTrigger_rolo1 := FALSE;
                WriteNeeded_rolo1 := FALSE;
                WriteRetryCount_rolo1 := 0;
            ELSIF WriteRetryCount_rolo1 < MAX_RETRIES THEN
                WriteRetryCount_rolo1 := WriteRetryCount_rolo1 + 1;
            ELSE
                WriteStep_rolo1 := 0;
                WriteTrigger_rolo1 := FALSE;
                WriteNeeded_rolo1 := FALSE;
                WriteError_rolo1 := TRUE;
                WriteRetryCount_rolo1 := 0;
            END_IF;
    END_CASE;
END_IF;

// Lógica para flags de erro e status
IF WriteMsg_rolo1.Q THEN
    WriteError_rolo1 := FALSE;
    CommunicationOK_rolo1 := TRUE;
ELSIF WriteRetryCount_rolo1 >= MAX_RETRIES THEN
    WriteError_rolo1 := TRUE;
    CommunicationOK_rolo1 := FALSE;
END_IF;

// Reset read error on successful read operations
IF ReadMsg_P0009_rolo1.Q OR ReadMsg_P0002_P0003_rolo1.Q OR ReadMsg_P0409_P0410_rolo1.Q THEN
    ReadError_rolo1 := FALSE;
    CommunicationOK_rolo1 := TRUE;
END_IF;

// Reset verification errors on successful verification operations
IF ReadMsg_P0100_rolo1.Q OR ReadMsg_P0134_P0133_rolo1.Q OR ReadMsg_P0169_P0170_rolo1.Q THEN
    CommunicationOK_rolo1 := TRUE;
END_IF;

// Error recovery mechanism - clear error flags after sustained successful communication
IF CommunicationOK_rolo1 THEN
    ErrorRecoveryTimer_rolo1(IN := TRUE, PT := ERROR_RECOVERY_TIME);
    IF ErrorRecoveryTimer_rolo1.Q THEN
        WriteError_rolo1 := FALSE;
        ReadError_rolo1 := FALSE;
        ErrorRecoveryTimer_rolo1(IN := FALSE);
    END_IF;
ELSE
    ErrorRecoveryTimer_rolo1(IN := FALSE);
END_IF;

// Read Logic (sequential to avoid overloading Modbus channel)
CASE ReadStep_rolo1 OF
    1:  // Read P0009
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo1.Addr := 9;
            LocalCfg_rolo1.Cmd := 3;
            LocalCfg_rolo1.ElementCnt := 1;
            ReadMsg_P0009_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
        END_IF;
        IF ReadMsg_P0009_rolo1.Q THEN
            TorquePercent_rolo1 := LocalAddr_rolo1[1];
            TempReal_rolo1 := UINT_TO_REAL(TorquePercent_rolo1);
            TorquePercentScaled_rolo1 := TempReal_rolo1 / 10.0;
            ReadStep_rolo1 := 2;
            ModbusBusy := FALSE;
            ReadRetryCount_rolo1 := 0;
        ELSIF ReadRetryCount_rolo1 < MAX_RETRIES THEN
            ReadRetryCount_rolo1 := ReadRetryCount_rolo1 + 1;
            ModbusBusy := FALSE;
        ELSE
            ReadStep_rolo1 := 2;
            ModbusBusy := FALSE;
            ReadError_rolo1 := TRUE;
            ReadRetryCount_rolo1 := 0;
        END_IF;
    2:  // Read P0002 and P0003
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo1.Addr := 2;
            LocalCfg_rolo1.Cmd := 3;
            LocalCfg_rolo1.ElementCnt := 2;
            ReadMsg_P0002_P0003_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
        END_IF;
        IF ReadMsg_P0002_P0003_rolo1.Q THEN
            OutputFreq_rolo1 := LocalAddr_rolo1[1];
            OutputCurrent_rolo1 := LocalAddr_rolo1[2];
            TempReal_rolo1 := UINT_TO_REAL(OutputFreq_rolo1);
            OutputFreqScaled_rolo1 := TempReal_rolo1 / 10.0;
            TempReal_rolo1 := UINT_TO_REAL(OutputCurrent_rolo1);
            OutputCurrentScaled_rolo1 := TempReal_rolo1 / 10.0;
            
            // Speed vs Torque monitoring logic
            // Calculate expected minimum speed based on torque and ratio
            // If torque is high but speed is low, it may indicate motor stall or insufficient power
            IF TorquePercentScaled_rolo1 > 20.0 AND EnableDrive_rolo1 THEN  // Only monitor when drive is enabled and torque > 20%
                TempReal_rolo1 := TorquePercentScaled_rolo1 * SPEED_TORQUE_RATIO;  // Expected min speed = torque% * ratio
                IF OutputFreqScaled_rolo1 < TempReal_rolo1 THEN
                    // Speed is too low for the torque level - start alarm timer
                    SpeedTorqueAlarmTimer_rolo1(IN := TRUE, PT := SPEED_TORQUE_ALARM_DELAY);
                    IF SpeedTorqueAlarmTimer_rolo1.Q THEN
                        SpeedTorqueAlarm_rolo1 := TRUE;
                    END_IF;
                ELSE
                    // Speed is adequate - reset alarm
                    SpeedTorqueAlarm_rolo1 := FALSE;
                    SpeedTorqueAlarmTimer_rolo1(IN := FALSE);
                END_IF;
            ELSE
                // Reset alarm when drive disabled or low torque
                SpeedTorqueAlarm_rolo1 := FALSE;
                SpeedTorqueAlarmTimer_rolo1(IN := FALSE);
            END_IF;
            
            ReadStep_rolo1 := 0;  // Reset for next cycle
            ReadTrigger_rolo1 := FALSE;
            ModbusBusy := FALSE;
            ReadRetryCount_rolo1 := 0;
        ELSIF ReadRetryCount_rolo1 < MAX_RETRIES THEN
            ReadRetryCount_rolo1 := ReadRetryCount_rolo1 + 1;
            ModbusBusy := FALSE;
        ELSE
            ReadStep_rolo1 := 0; // Reset on max retries
            ReadTrigger_rolo1 := FALSE;
            ModbusBusy := FALSE;
            ReadError_rolo1 := TRUE;
            ReadRetryCount_rolo1 := 0; // Reset for next operation
        END_IF;
END_CASE;

// Read Logic for P0409 and P0410 (separate 10-second cycle)
CASE ReadStep_P0409_P0410_rolo1 OF
    1:  // Read P0409 and P0410
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo1.Addr := 409;
            LocalCfg_rolo1.Cmd := 3;
            LocalCfg_rolo1.ElementCnt := 2;
            ReadMsg_P0409_P0410_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
        END_IF;
        IF ReadMsg_P0409_P0410_rolo1.Q THEN
            P0409_rolo1 := LocalAddr_rolo1[1];
            P0410_rolo1 := LocalAddr_rolo1[2];
            TempReal_rolo1 := UINT_TO_REAL(P0409_rolo1);
            P0409Scaled_rolo1 := TempReal_rolo1; // Scaling depends on parameter definition
            TempReal_rolo1 := UINT_TO_REAL(P0410_rolo1);
            P0410Scaled_rolo1 := TempReal_rolo1; // Scaling depends on parameter definition
            
            ReadStep_P0409_P0410_rolo1 := 0;  // Reset for next cycle
            ModbusBusy := FALSE;
            ReadRetryCount_P0409_P0410_rolo1 := 0; // Reset retry counter on success
        ELSIF ReadRetryCount_P0409_P0410_rolo1 < MAX_RETRIES THEN
            ReadRetryCount_P0409_P0410_rolo1 := ReadRetryCount_P0409_P0410_rolo1 + 1;
            ModbusBusy := FALSE; // Release bus for retry
            // Will retry on next cycle
        ELSE
            ReadStep_P0409_P0410_rolo1 := 0; // Reset on max retries
            ModbusBusy := FALSE;
            ReadError_rolo1 := TRUE;
            ReadRetryCount_P0409_P0410_rolo1 := 0; // Reset for next operation
        END_IF;
    END_CASE;

// Verification Logic (sequential to avoid overloading Modbus channel, check and force parameters)
CASE VerificationStep_rolo1 OF
    1:  // Read P0100 (Control Type)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo1.Addr := 100;
            LocalCfg_rolo1.Cmd := 3;
            LocalCfg_rolo1.ElementCnt := 1;
            ReadMsg_P0100_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
        END_IF;
        IF ReadMsg_P0100_rolo1.Q THEN
            ControlTypeRead_rolo1 := LocalAddr_rolo1[1];
            IF ControlTypeRead_rolo1 <> ControlTypeSet_rolo1 THEN
                // Force write P0100
                LocalAddr_rolo1[1] := ControlTypeSet_rolo1;
                TargetCfg_rolo1.Addr := 100;
                LocalCfg_rolo1.Cmd := 6;
                LocalCfg_rolo1.ElementCnt := 1;
                WriteMsg_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
                IF WriteMsg_rolo1.Q THEN
                    VerificationStep_rolo1 := 2;
                    VerificationRetryCount_rolo1 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo1 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo1 := VerificationRetryCount_rolo1 + 1;
                ELSE
                    VerificationStep_rolo1 := 2; // Advance on max retries
                    VerificationRetryCount_rolo1 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo1 := 2;
                VerificationRetryCount_rolo1 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo1 < MAX_RETRIES THEN
            VerificationRetryCount_rolo1 := VerificationRetryCount_rolo1 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo1 := 2; // Advance on max retries
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo1 := 0;
        END_IF;
    2:  // Read P0134 and P0133 (Max/Min Speed)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo1.Addr := 134;
            LocalCfg_rolo1.Cmd := 3;
            LocalCfg_rolo1.ElementCnt := 2;
            ReadMsg_P0134_P0133_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
        END_IF;
        IF ReadMsg_P0134_P0133_rolo1.Q THEN
            MaxSpeedRead_rolo1 := LocalAddr_rolo1[1];
            MinSpeedRead_rolo1 := LocalAddr_rolo1[2];
            IF MaxSpeedRead_rolo1 <> MaxSpeedSet_rolo1 OR MinSpeedRead_rolo1 <> MinSpeedSet_rolo1 THEN
                // Force write P0134 and P0133
                LocalAddr_rolo1[1] := MaxSpeedSet_rolo1;
                LocalAddr_rolo1[2] := MinSpeedSet_rolo1;
                TargetCfg_rolo1.Addr := 134;
                LocalCfg_rolo1.Cmd := 16; // Preset Multiple Registers for consecutive
                LocalCfg_rolo1.ElementCnt := 2;
                WriteMsg_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
                IF WriteMsg_rolo1.Q THEN
                    VerificationStep_rolo1 := 3;
                    VerificationRetryCount_rolo1 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo1 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo1 := VerificationRetryCount_rolo1 + 1;
                ELSE
                    VerificationStep_rolo1 := 3; // Advance on max retries
                    VerificationRetryCount_rolo1 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo1 := 3;
                VerificationRetryCount_rolo1 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo1 < MAX_RETRIES THEN
            VerificationRetryCount_rolo1 := VerificationRetryCount_rolo1 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo1 := 3; // Advance on max retries
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo1 := 0;
        END_IF;
    3:  // Read P0169 and P0170 (Max/Min Torque)
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo1.Addr := 169;
            LocalCfg_rolo1.Cmd := 3;
            LocalCfg_rolo1.ElementCnt := 2;
            ReadMsg_P0169_P0170_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
        END_IF;
        IF ReadMsg_P0169_P0170_rolo1.Q THEN
            MaxTorqueRead_rolo1 := LocalAddr_rolo1[1];
            MinTorqueRead_rolo1 := LocalAddr_rolo1[2];
            IF MaxTorqueRead_rolo1 <> MaxTorqueSet_rolo1 OR MinTorqueRead_rolo1 <> MinTorqueSet_rolo1 THEN
                // Force write P0169 and P0170
                LocalAddr_rolo1[1] := MaxTorqueSet_rolo1;
                LocalAddr_rolo1[2] := MinTorqueSet_rolo1;
                TargetCfg_rolo1.Addr := 169;
                LocalCfg_rolo1.Cmd := 16; // Preset Multiple Registers
                LocalCfg_rolo1.ElementCnt := 2;
                WriteMsg_rolo1(IN := TRUE, LocalCfg := LocalCfg_rolo1, TargetCfg := TargetCfg_rolo1, LocalAddr := LocalAddr_rolo1);
                IF WriteMsg_rolo1.Q THEN
                    VerificationStep_rolo1 := 0; // Reset
                    VerificationTrigger_rolo1 := FALSE;
                    VerificationRetryCount_rolo1 := 0; // Reset on success
                ELSIF VerificationRetryCount_rolo1 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo1 := VerificationRetryCount_rolo1 + 1;
                ELSE
                    VerificationStep_rolo1 := 0; // Reset on max retries
                    VerificationTrigger_rolo1 := FALSE;
                    VerificationRetryCount_rolo1 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo1 := 0; // Reset
                VerificationTrigger_rolo1 := FALSE;
                VerificationRetryCount_rolo1 := 0; // Reset on success
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo1 < MAX_RETRIES THEN
            VerificationRetryCount_rolo1 := VerificationRetryCount_rolo1 + 1;
            ModbusBusy := FALSE; // Release bus for retry
        ELSE
            VerificationStep_rolo1 := 0; // Reset on max retries
            VerificationTrigger_rolo1 := FALSE;
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo1 := 0;
        END_IF;
    END_CASE;
