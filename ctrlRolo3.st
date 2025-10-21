(* ST Program for CFW500 Parameter Control and Monitoring *)
(* Assumptions:
- Single inverter at Node = 3.
- Registers are direct: Pxxxx at holding register xxxx.
- Scaling: Values are integers; for decimals (e.g., P0009 in 0.1%), divide by 10.0 for REAL display.
- P0498 assumed as UINT (0/1 for disable/enable); adjust if different.
- Writes triggered by WriteTrigger BOOL (e.g., from HMI or logic).
- Reads every 1.4 seconds for P0009, P0002, P0003 (torque, output frequency, output current).
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

// Update set values from PV800 globals
MaxSpeedSet_rolo3 := UINT(SpeedMax_rolo3 * 100); // Convert Hz to 0.01 Hz units
MinSpeedSet_rolo3 := UINT(SpeedMin_rolo3 * 100);
MaxTorqueSet_rolo3 := UINT(TorqueMax_rolo3 * 10); // Convert % to 0.1% units
MinTorqueSet_rolo3 := UINT(0 * 10); // Assuming MinTorque is 0

// Write Logic (triggered by WriteTrigger; writes all params sequentially)
IF WriteTrigger_rolo3 THEN
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
        END_IF;
    END_CASE;

// Lógica para flags de erro e status
IF WriteMsg_rolo3.Q THEN
    WriteError_rolo3 := FALSE;
    CommunicationOK_rolo3 := TRUE;
ELSE
    WriteError_rolo3 := TRUE;
    CommunicationOK_rolo3 := FALSE;
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
            ReadStep_rolo3 := 0;  // Reset for next cycle
            ReadTrigger_rolo3 := FALSE;
            ModbusBusy := FALSE;
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
                END_IF;
            ELSE
                VerificationStep_rolo3 := 2;
            END_IF;
            ModbusBusy := FALSE;
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
                END_IF;
            ELSE
                VerificationStep_rolo3 := 3;
            END_IF;
            ModbusBusy := FALSE;
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
                END_IF;
            ELSE
                VerificationStep_rolo3 := 0; // Reset
                VerificationTrigger_rolo3 := FALSE;
            END_IF;
            ModbusBusy := FALSE;
        END_IF;
    END_CASE;
