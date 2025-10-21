(* ST Program for CFW500 Parameter Control and Monitoring *)
(* Assumptions:
- Single inverter at Node = 1.
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
VerificationTimer_rolo1(IN := TRUE, PT := T#10s);
IF VerificationTimer_rolo1.Q THEN
    VerificationTrigger_rolo1 := TRUE;
    VerificationStep_rolo1 := 1;  // Start verification sequence
    VerificationTimer_rolo1(IN := FALSE); // Reset to restart timer
END_IF;

// Update set values from PV800 globals
MaxSpeedSet_rolo1 := UINT(SpeedMax_rolo1 * 100); // Convert Hz to 0.01 Hz units
MinSpeedSet_rolo1 := UINT(SpeedMin_rolo1 * 100);
MaxTorqueSet_rolo1 := UINT(TorqueMax_rolo1 * 10); // Convert % to 0.1% units
MinTorqueSet_rolo1 := UINT(0 * 10); // Assuming MinTorque is 0

// Write Logic (triggered by WriteTrigger; writes all params sequentially)
IF WriteTrigger_rolo1 THEN
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
        END_IF;
    END_CASE;

// Lógica para flags de erro e status
IF WriteMsg_rolo1.Q THEN
    WriteError_rolo1 := FALSE;
    CommunicationOK_rolo1 := TRUE;
ELSE
    WriteError_rolo1 := TRUE;
    CommunicationOK_rolo1 := FALSE;
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
            ReadStep_rolo1 := 0;  // Reset for next cycle
            ReadTrigger_rolo1 := FALSE;
            ModbusBusy := FALSE;
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
                END_IF;
            ELSE
                VerificationStep_rolo1 := 2;
            END_IF;
            ModbusBusy := FALSE;
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
                END_IF;
            ELSE
                VerificationStep_rolo1 := 3;
            END_IF;
            ModbusBusy := FALSE;
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
                END_IF;
            ELSE
                VerificationStep_rolo1 := 0; // Reset
                VerificationTrigger_rolo1 := FALSE;
            END_IF;
            ModbusBusy := FALSE;
        END_IF;
    END_CASE;
