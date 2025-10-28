(* ST Program for CFW500 Parameter Control and Monitoring - Rolo 3 *)
(* Same structure as Rolo1, with _rolo3 suffix and Node = 3 *)

// Periodic Verification Timer (every 10s to check critical parameters)
VerificationTimer_rolo3(IN := TRUE, PT := T#10s);
IF VerificationTimer_rolo3.Q THEN
    VerificationTrigger_rolo3 := TRUE;
    VerificationStep_rolo3 := 1;
    VerificationTimer_rolo3(IN := FALSE);
END_IF;

// Periodic Read Timer (every 10s for monitoring parameters)
ReadTimer_rolo3(IN := TRUE, PT := T#10s);
IF ReadTimer_rolo3.Q THEN
    ReadStep_rolo3 := 1;
    ReadTimer_rolo3(IN := FALSE);
END_IF;

// Periodic Read Timer for P0408/P0409/P0410 (every 10s)
ReadTimer_P0408_P0410_rolo3(IN := TRUE, PT := T#10s);
IF ReadTimer_P0408_P0410_rolo3.Q THEN
    ReadStep_P0408_P0410_rolo3 := 1;  // Start P0408/P0409/P0410 read sequence
    ReadTimer_P0408_P0410_rolo3(IN := FALSE); // Reset to restart timer
END_IF;

// Detect changes in HMI values and compare with drive values to set write flag
IF TorqueMax_rolo3 <> TorqueMaxOld_rolo3 OR SpeedMax_rolo3 <> SpeedMaxOld_rolo3 OR SpeedMin_rolo3 <> SpeedMinOld_rolo3 OR SpeedTorqueRatio_rolo3 <> SpeedTorqueRatioOld_rolo3 THEN
    TorqueMaxOld_rolo3 := TorqueMax_rolo3;
    SpeedMaxOld_rolo3 := SpeedMax_rolo3;
    SpeedMinOld_rolo3 := SpeedMin_rolo3;
    SpeedTorqueRatioOld_rolo3 := SpeedTorqueRatio_rolo3;
    IF UINT(TorqueMax_rolo3 * 10) <> MaxTorqueRead_rolo3 OR UINT(SpeedMax_rolo3 * 100) <> MaxSpeedRead_rolo3 OR UINT(SpeedMin_rolo3 * 100) <> MinSpeedRead_rolo3 THEN
        WriteNeeded_rolo3 := TRUE;
    END_IF;
END_IF;

// Update set values from PV800 globals
IF SpeedMax_rolo3 > SPEED_MAX_LIMIT THEN
    SpeedMax_rolo3 := SPEED_MAX_LIMIT;
ELSIF SpeedMax_rolo3 < SPEED_MIN_LIMIT THEN
    SpeedMax_rolo3 := SPEED_MIN_LIMIT;
END_IF;

IF SpeedMin_rolo3 < SPEED_MIN_LIMIT THEN
    SpeedMin_rolo3 := SPEED_MIN_LIMIT;
ELSIF SpeedMin_rolo3 > SpeedMax_rolo3 THEN
    SpeedMin_rolo3 := SpeedMax_rolo3;
END_IF;

IF TorqueMax_rolo3 > TORQUE_MAX_LIMIT THEN
    TorqueMax_rolo3 := TORQUE_MAX_LIMIT;
ELSIF TorqueMax_rolo3 < TORQUE_MIN_LIMIT THEN
    TorqueMax_rolo3 := TORQUE_MIN_LIMIT;
END_IF;

IF SpeedTorqueRatio_rolo3 > SPEED_TORQUE_RATIO_MAX_LIMIT THEN
    SpeedTorqueRatio_rolo3 := SPEED_TORQUE_RATIO_MAX_LIMIT;
ELSIF SpeedTorqueRatio_rolo3 < SPEED_TORQUE_RATIO_MIN_LIMIT THEN
    SpeedTorqueRatio_rolo3 := SPEED_TORQUE_RATIO_MIN_LIMIT;
END_IF;

// Convert validated values to inverter units
MaxSpeedSet_rolo3 := UINT(SpeedMax_rolo3 * 100);
MinSpeedSet_rolo3 := UINT(SpeedMin_rolo3 * 100);
MaxTorqueSet_rolo3 := UINT(TorqueMax_rolo3 * 10);
MinTorqueSet_rolo3 := UINT(0 * 10);

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
                WriteRetryCount_rolo3 := 0;
            ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
            ELSE
                WriteStep_rolo3 := 1;
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0;
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
                WriteRetryCount_rolo3 := 0;
            ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
            ELSE
                WriteStep_rolo3 := 2;
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0;
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
                WriteRetryCount_rolo3 := 0;
            ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
            ELSE
                WriteStep_rolo3 := 3;
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0;
            END_IF;
        3:
            LocalAddr_rolo3[1] := MinTorqueSet_rolo3;
            TargetCfg_rolo3.Addr := 170;
            LocalCfg_rolo3.Cmd := 6;
            LocalCfg_rolo3.ElementCnt := 1;
            WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
            IF WriteMsg_rolo3.Q THEN
                WriteStep_rolo3 := 0;  // Reset - Write sequence complete
                MinTorqueRead_rolo3 := LocalAddr_rolo3[1];
                WriteTrigger_rolo3 := FALSE;
                WriteNeeded_rolo3 := FALSE;
                WriteRetryCount_rolo3 := 0;
            ELSIF WriteRetryCount_rolo3 < MAX_RETRIES THEN
                WriteRetryCount_rolo3 := WriteRetryCount_rolo3 + 1;
            ELSE
                WriteStep_rolo3 := 0;  // Reset on max retries
                WriteTrigger_rolo3 := FALSE;
                WriteNeeded_rolo3 := FALSE;
                WriteError_rolo3 := TRUE;
                WriteRetryCount_rolo3 := 0;
            END_IF;
    END_CASE;
END_IF;

// Lógica para flags de erro e status
IF WriteMsg_rolo3.Q THEN
    WriteError_rolo3 := FALSE;
    CommunicationOK_rolo3 := TRUE;
ELSIF WriteRetryCount_rolo3 >= MAX_RETRIES THEN
    WriteError_rolo3 := TRUE;
    CommunicationOK_rolo3 := FALSE;
END_IF;

IF ReadMsg_P0009_rolo3.Q OR ReadMsg_P0002_P0003_rolo3.Q OR ReadMsg_P0408_P0410_rolo3.Q THEN
    ReadError_rolo3 := FALSE;
    CommunicationOK_rolo3 := TRUE;
END_IF;

IF ReadMsg_P0100_rolo3.Q OR ReadMsg_P0134_P0133_rolo3.Q OR ReadMsg_P0169_P0170_rolo3.Q THEN
    CommunicationOK_rolo3 := TRUE;
END_IF;

IF CommunicationOK_rolo3 THEN
    ErrorRecoveryTimer_rolo3(IN := TRUE, PT := ERROR_RECOVERY_TIME);
    IF ErrorRecoveryTimer_rolo3.Q THEN
        WriteError_rolo3 := FALSE;
        ReadError_rolo3 := FALSE;
        ErrorRecoveryTimer_rolo3(IN := FALSE);
    END_IF;
ELSE
    ErrorRecoveryTimer_rolo3(IN := FALSE);
END_IF;

// Read Logic (sequential to avoid overloading Modbus channel)
CASE ReadStep_rolo3 OF
    1:
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
            ReadRetryCount_rolo3 := 0;
        ELSIF ReadRetryCount_rolo3 < MAX_RETRIES THEN
            ReadRetryCount_rolo3 := ReadRetryCount_rolo3 + 1;
            ModbusBusy := FALSE;
        ELSE
            ReadStep_rolo3 := 2;
            ModbusBusy := FALSE;
            ReadError_rolo3 := TRUE;
            ReadRetryCount_rolo3 := 0;
        END_IF;
    2:
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
            
            IF TorquePercentScaled_rolo3 > 20.0 AND EnableDrive_rolo3 THEN
                TempReal_rolo3 := TorquePercentScaled_rolo3 * SpeedTorqueRatio_rolo3;
                IF OutputFreqScaled_rolo3 < TempReal_rolo3 THEN
                    SpeedTorqueAlarmTimer_rolo3(IN := TRUE, PT := SPEED_TORQUE_ALARM_DELAY);
                    IF SpeedTorqueAlarmTimer_rolo3.Q THEN
                        SpeedTorqueAlarm_rolo3 := TRUE;
                    END_IF;
                ELSE
                    SpeedTorqueAlarm_rolo3 := FALSE;
                    SpeedTorqueAlarmTimer_rolo3(IN := FALSE);
                END_IF;
            ELSE
                SpeedTorqueAlarm_rolo3 := FALSE;
                SpeedTorqueAlarmTimer_rolo3(IN := FALSE);
            END_IF;
            
            ReadStep_rolo3 := 0;
            ReadTrigger_rolo3 := FALSE;
            ModbusBusy := FALSE;
            ReadRetryCount_rolo3 := 0;
        ELSIF ReadRetryCount_rolo3 < MAX_RETRIES THEN
            ReadRetryCount_rolo3 := ReadRetryCount_rolo3 + 1;
            ModbusBusy := FALSE;
        ELSE
            ReadStep_rolo3 := 0;
            ReadTrigger_rolo3 := FALSE;
            ModbusBusy := FALSE;
            ReadError_rolo3 := TRUE;
            ReadRetryCount_rolo3 := 0;
        END_IF;
END_CASE;

// Read Logic for P0408, P0409 and P0410 (separate 10-second cycle)
CASE ReadStep_P0408_P0410_rolo3 OF
    1:  // Read P0408, P0409 and P0410
        IF NOT ModbusBusy THEN
            ModbusBusy := TRUE;
            TargetCfg_rolo3.Addr := 408;
            LocalCfg_rolo3.Cmd := 3;
            LocalCfg_rolo3.ElementCnt := 3;
            ReadMsg_P0408_P0410_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
        END_IF;
        IF ReadMsg_P0408_P0410_rolo3.Q THEN
            P0408_rolo3 := LocalAddr_rolo3[1];  // Boolean: 0 or 1 (Vector Sensorless Enable)
            P0409_rolo3 := LocalAddr_rolo3[2];  // Stator Resistance (Rs) in ohms
            P0410_rolo3 := LocalAddr_rolo3[3];  // Magnetizing Current (Im) in amperes
            
            // Scale P0408 (Boolean)
            TempReal_rolo3 := UINT_TO_REAL(P0408_rolo3);
            P0408Scaled_rolo3 := TempReal_rolo3; // Will be 0.0 or 1.0 for boolean display
            
            // Scale P0409 (Stator Resistance in 0.01 ohm units)
            TempReal_rolo3 := UINT_TO_REAL(P0409_rolo3);
            P0409Scaled_rolo3 := TempReal_rolo3 / 100.0; // Convert to ohms
            
            // Scale P0410 (Magnetizing Current in 0.01 A units)
            TempReal_rolo3 := UINT_TO_REAL(P0410_rolo3);
            P0410Scaled_rolo3 := TempReal_rolo3 / 100.0; // Convert to amperes
            
            ReadStep_P0408_P0410_rolo3 := 0;  // Reset for next cycle
            ModbusBusy := FALSE;
            ReadRetryCount_P0408_P0410_rolo3 := 0; // Reset retry counter on success
        ELSIF ReadRetryCount_P0408_P0410_rolo3 < MAX_RETRIES THEN
            ReadRetryCount_P0408_P0410_rolo3 := ReadRetryCount_P0408_P0410_rolo3 + 1;
            ModbusBusy := FALSE; // Release bus for retry
            // Will retry on next cycle
        ELSE
            ReadStep_P0408_P0410_rolo3 := 0; // Reset on max retries
            ModbusBusy := FALSE;
            ReadError_rolo3 := TRUE;
            ReadRetryCount_P0408_P0410_rolo3 := 0; // Reset for next operation
        END_IF;
    END_CASE;

// Verification Logic
CASE VerificationStep_rolo3 OF
    1:
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
                LocalAddr_rolo3[1] := ControlTypeSet_rolo3;
                TargetCfg_rolo3.Addr := 100;
                LocalCfg_rolo3.Cmd := 6;
                LocalCfg_rolo3.ElementCnt := 1;
                WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
                IF WriteMsg_rolo3.Q THEN
                    VerificationStep_rolo3 := 2;
                    VerificationRetryCount_rolo3 := 0;
                ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
                ELSE
                    VerificationStep_rolo3 := 2;
                    VerificationRetryCount_rolo3 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo3 := 2;
                VerificationRetryCount_rolo3 := 0;
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
            VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
            ModbusBusy := FALSE;
        ELSE
            VerificationStep_rolo3 := 2;
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo3 := 0;
        END_IF;
    2:
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
                LocalAddr_rolo3[1] := MaxSpeedSet_rolo3;
                LocalAddr_rolo3[2] := MinSpeedSet_rolo3;
                TargetCfg_rolo3.Addr := 134;
                LocalCfg_rolo3.Cmd := 16;
                LocalCfg_rolo3.ElementCnt := 2;
                WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
                IF WriteMsg_rolo3.Q THEN
                    VerificationStep_rolo3 := 3;
                    VerificationRetryCount_rolo3 := 0;
                ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
                ELSE
                    VerificationStep_rolo3 := 3;
                    VerificationRetryCount_rolo3 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo3 := 3;
                VerificationRetryCount_rolo3 := 0;
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
            VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
            ModbusBusy := FALSE;
        ELSE
            VerificationStep_rolo3 := 3;
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo3 := 0;
        END_IF;
    3:
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
                LocalAddr_rolo3[1] := MaxTorqueSet_rolo3;
                LocalAddr_rolo3[2] := MinTorqueSet_rolo3;
                TargetCfg_rolo3.Addr := 169;
                LocalCfg_rolo3.Cmd := 16;
                LocalCfg_rolo3.ElementCnt := 2;
                WriteMsg_rolo3(IN := TRUE, LocalCfg := LocalCfg_rolo3, TargetCfg := TargetCfg_rolo3, LocalAddr := LocalAddr_rolo3);
                IF WriteMsg_rolo3.Q THEN
                    VerificationStep_rolo3 := 0;
                    VerificationTrigger_rolo3 := FALSE;
                    VerificationRetryCount_rolo3 := 0;
                ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
                    VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
                ELSE
                    VerificationStep_rolo3 := 0;
                    VerificationTrigger_rolo3 := FALSE;
                    VerificationRetryCount_rolo3 := 0;
                END_IF;
            ELSE
                VerificationStep_rolo3 := 0;
                VerificationTrigger_rolo3 := FALSE;
                VerificationRetryCount_rolo3 := 0;
            END_IF;
            ModbusBusy := FALSE;
        ELSIF VerificationRetryCount_rolo3 < MAX_RETRIES THEN
            VerificationRetryCount_rolo3 := VerificationRetryCount_rolo3 + 1;
            ModbusBusy := FALSE;
        ELSE
            VerificationStep_rolo3 := 0;
            VerificationTrigger_rolo3 := FALSE;
            ModbusBusy := FALSE;
            VerificationRetryCount_rolo3 := 0;
        END_IF;
END_CASE;
