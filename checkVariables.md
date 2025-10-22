# Lista de Verificação de Variáveis - Sistema CFW500

# Connected Components Workbench (CCW)

## Visão Geral

Esta lista contém todas as variáveis necessárias para o projeto no Connected Components Workbench (CCW). As variáveis estão organizadas por escopo e POU.

**Legenda:**

- ✅ = Verificado/Implementado
- ❌ = Pendente
- 🔄 = Em desenvolvimento

## Variáveis Globais (Global Variables no Projeto CCW)

| Status | Variável                     | Tipo | Valor Inicial | Descrição                                                |
| ------ | ---------------------------- | ---- | ------------- | -------------------------------------------------------- |
| ✅     | ModbusBusy                   | BOOL | FALSE         | Flag para controlar acesso ao canal Modbus               |
| ✅     | TorqueMax_rolo1              | UINT | 1000          | Torque máximo para ajuste no PV800 (0.1% unidades)       |
| ✅     | SpeedMax_rolo1               | UINT | 6000          | Velocidade máxima para ajuste no PV800 (0.1 Hz unidades) |
| ✅     | SpeedMin_rolo1               | UINT | 0             | Velocidade mínima para ajuste no PV800 (0.1 Hz unidades) |
| ✅     | TorqueMax_rolo2              | UINT | 1000          | Torque máximo para rolo 2                                |
| ✅     | SpeedMax_rolo2               | UINT | 6000          | Velocidade máxima para rolo 2                            |
| ✅     | SpeedMin_rolo2               | UINT | 0             | Velocidade mínima para rolo 2                            |
| ✅     | TorqueMax_rolo3              | UINT | 1000          | Torque máximo para rolo 3                                |
| ✅     | SpeedMax_rolo3               | UINT | 6000          | Velocidade máxima para rolo 3                            |
| ✅     | SpeedMin_rolo3               | UINT | 0             | Velocidade mínima para rolo 3                            |
| ✅     | TorqueMaxOld_rolo1           | UINT | 1000          | Valor antigo para detecção de mudança                    |
| ✅     | SpeedMaxOld_rolo1            | UINT | 6000          | Valor antigo para detecção de mudança                    |
| ✅     | SpeedMinOld_rolo1            | UINT | 0             | Valor antigo para detecção de mudança                    |
| ✅     | WriteNeeded_rolo1            | BOOL | FALSE         | Flag para necessidade de escrita                         |
| ✅     | TorqueMaxOld_rolo2           | UINT | 1000          | Valor antigo para detecção de mudança                    |
| ✅     | SpeedMaxOld_rolo2            | UINT | 6000          | Valor antigo para detecção de mudança                    |
| ✅     | SpeedMinOld_rolo2            | UINT | 0             | Valor antigo para detecção de mudança                    |
| ✅     | WriteNeeded_rolo2            | BOOL | FALSE         | Flag para necessidade de escrita                         |
| ✅     | TorqueMaxOld_rolo3           | UINT | 1000          | Valor antigo para detecção de mudança                    |
| ✅     | SpeedMaxOld_rolo3            | UINT | 6000          | Valor antigo para detecção de mudança                    |
| ✅     | SpeedMinOld_rolo3            | UINT | 0             | Valor antigo para detecção de mudança                    |
| ✅     | WriteNeeded_rolo3            | BOOL | FALSE         | Flag para necessidade de escrita                         |
| ✅     | MAX_RETRIES                  | INT  | 3             | Maximum retry attempts for failed communications         |
| ✅     | WriteRetryCount_rolo1        | INT  | 0             | Retry counter for write operations                       |
| ✅     | ReadRetryCount_rolo1         | INT  | 0             | Retry counter for read operations                        |
| ✅     | VerificationRetryCount_rolo1 | INT  | 0             | Retry counter for verification operations                |
| ✅     | WriteRetryCount_rolo2        | INT  | 0             | Retry counter for write operations                       |
| ✅     | ReadRetryCount_rolo2         | INT  | 0             | Retry counter for read operations                        |
| ✅     | VerificationRetryCount_rolo2 | INT  | 0             | Retry counter for verification operations                |
| ✅     | WriteRetryCount_rolo3        | INT  | 0             | Retry counter for write operations                       |
| ✅     | ReadRetryCount_rolo3         | INT  | 0             | Retry counter for read operations                        |
| ✅     | VerificationRetryCount_rolo3 | INT  | 0             | Retry counter for verification operations                |
| ✅     | SPEED_MAX_LIMIT              | REAL | 100.0         | Maximum speed limit in Hz                                |
| ✅     | SPEED_MIN_LIMIT              | REAL | 0.0           | Minimum speed limit in Hz                                |
| ✅     | TORQUE_MAX_LIMIT             | REAL | 200.0         | Maximum torque limit in %                                |
| ✅     | TORQUE_MIN_LIMIT             | REAL | 0.0           | Minimum torque limit in %                                |
| ✅     | SPEED_TORQUE_RATIO           | REAL | 0.5           | Minimum speed/torque ratio (Hz/%)                        |
| ✅     | SPEED_TORQUE_ALARM_DELAY     | TIME | T#5s          | Delay before triggering speed-torque alarm               |
| ✅     | ERROR_RECOVERY_TIME          | TIME | T#30s         | Time after which to clear error flags                    |
| ✅     | ErrorRecoveryTimer_rolo1     | TON  | -             | Timer for clearing error flags                           |
| ✅     | ErrorRecoveryTimer_rolo2     | TON  | -             | Timer for clearing error flags                           |
| ✅     | ErrorRecoveryTimer_rolo3     | TON  | -             | Timer for clearing error flags                           |

## Variáveis para CTRLROLO1 (POU)

| Status | Variável                    | Tipo          | Valor Inicial                    | Descrição                                         |
| ------ | --------------------------- | ------------- | -------------------------------- | ------------------------------------------------- |
| ✅     | LocalCfg_rolo1              | MODBUSLOCPARA | (Channel := 2, TriggerType := 0) | Configuração local Modbus                         |
| ✅     | TargetCfg_rolo1             | MODBUSTARPARA | (Node := 1)                      | Configuração do alvo Modbus                       |
| ✅     | LocalAddr_rolo1             | MODBUSLOCADDR | -                                | Endereço local Modbus                             |
| ✅     | WriteMsg_rolo1              | MSG_MODBUS    | -                                | Mensagem de escrita Modbus                        |
| ✅     | ReadMsg_P0009_rolo1         | MSG_MODBUS    | -                                | Leitura P0009 (Torque)                            |
| ✅     | ReadMsg_P0002_P0003_rolo1   | MSG_MODBUS    | -                                | P0002 (Output Frequency) e P0003 (Output Current) |
| ✅     | WriteTrigger_rolo1          | BOOL          | -                                | Gatilho para escrita                              |
| ✅     | ReadTrigger_rolo1           | BOOL          | -                                | Gatilho para leitura                              |
| ✅     | ReadTimer_rolo1             | TON           | -                                | Timer para leituras periódicas                    |
| ✅     | MaxSpeedSet_rolo1           | UINT          | -                                | Velocidade máxima configurada                     |
| ✅     | MinSpeedSet_rolo1           | UINT          | -                                | Velocidade mínima configurada                     |
| ✅     | MaxTorqueSet_rolo1          | UINT          | -                                | Torque máximo configurado                         |
| ✅     | MinTorqueSet_rolo1          | UINT          | -                                | Torque mínimo configurado                         |
| ✅     | P0498Set_rolo1              | UINT          | -                                | Configuração P0498                                |
| ✅     | MaxSpeedRead_rolo1          | UINT          | -                                | Velocidade máxima lida                            |
| ✅     | MinSpeedRead_rolo1          | UINT          | -                                | Velocidade mínima lida                            |
| ✅     | MaxTorqueRead_rolo1         | UINT          | -                                | Torque máximo lido                                |
| ✅     | MinTorqueRead_rolo1         | UINT          | -                                | Torque mínimo lido                                |
| ✅     | P0498Read_rolo1             | UINT          | -                                | P0498 lido                                        |
| ✅     | TorquePercent_rolo1         | UINT          | -                                | Percentual de torque                              |
| ✅     | OutputFreq_rolo1            | UINT          | -                                | Frequência de saída (P0002)                       |
| ✅     | TorquePercentScaled_rolo1   | REAL          | -                                | Torque percentual escalado                        |
| ✅     | OutputCurrentScaled_rolo1   | REAL          | -                                | Corrente de saída escalada (P0003)                |
| ✅     | OutputFreqScaled_rolo1      | REAL          | -                                | Frequência de saída escalada                      |
| ✅     | TempReal_rolo1              | REAL          | -                                | Variável temporária REAL                          |
| ✅     | OutputCurrent_rolo1         | UINT          | -                                | Corrente de saída (P0003)                         |
| ✅     | WriteStep_rolo1             | INT           | 0                                | Passo da escrita sequencial                       |
| ✅     | ReadStep_rolo1              | INT           | 0                                | Passo da leitura sequencial                       |
| ✅     | EnableDrive_rolo1           | BOOL          | -                                | Controle de habilitação do drive                  |
| ✅     | CommunicationOK_rolo1       | BOOL          | -                                | Status de comunicação Modbus                      |
| ✅     | WriteError_rolo1            | BOOL          | -                                | Flag de erro na escrita                           |
| ✅     | ReadError_rolo1             | BOOL          | -                                | Flag de erro na leitura                           |
| ✅     | ControlTypeSet_rolo1        | UINT          | 2                                | P0100 = 2 para Vector Sensorless                  |
| ✅     | ControlTypeRead_rolo1       | UINT          | -                                | Tipo de controle lido                             |
| ✅     | VerificationTimer_rolo1     | TON           | -                                | Timer para verificações periódicas                |
| ✅     | VerificationTrigger_rolo1   | BOOL          | -                                | Gatilho de verificação                            |
| ✅     | VerificationStep_rolo1      | INT           | 0                                | Passo da verificação                              |
| ✅     | ReadMsg_P0100_rolo1         | MSG_MODBUS    | -                                | Leitura P0100                                     |
| ✅     | ReadMsg_P0134_P0133_rolo1   | MSG_MODBUS    | -                                | P0134 (Max Speed) e P0133 (Min Speed)             |
| ✅     | ReadMsg_P0169_P0170_rolo1   | MSG_MODBUS    | -                                | P0169 (Max Torque) e P0170 (Min Torque)           |
| ✅     | SpeedTorqueAlarm_rolo1      | BOOL          | FALSE                            | Alarme velocidade vs torque                       |
| ✅     | SpeedTorqueAlarmTimer_rolo1 | TON           | -                                | Timer para alarme velocidade-torque               |

## Variáveis para CTRLROLO2 (POU)

| Status | Variável                    | Tipo          | Valor Inicial                    | Descrição                                         |
| ------ | --------------------------- | ------------- | -------------------------------- | ------------------------------------------------- |
| ✅     | LocalCfg_rolo2              | MODBUSLOCPARA | (Channel := 2, TriggerType := 0) | Configuração local Modbus                         |
| ✅     | TargetCfg_rolo2             | MODBUSTARPARA | (Node := 2)                      | Configuração do alvo Modbus                       |
| ✅     | LocalAddr_rolo2             | MODBUSLOCADDR | -                                | Endereço local Modbus                             |
| ✅     | WriteMsg_rolo2              | MSG_MODBUS    | -                                | Mensagem de escrita Modbus                        |
| ✅     | ReadMsg_P0009_rolo2         | MSG_MODBUS    | -                                | Leitura P0009 (Torque)                            |
| ✅     | ReadMsg_P0002_P0003_rolo2   | MSG_MODBUS    | -                                | P0002 (Output Frequency) e P0003 (Output Current) |
| ✅     | WriteTrigger_rolo2          | BOOL          | -                                | Gatilho para escrita                              |
| ✅     | ReadTrigger_rolo2           | BOOL          | -                                | Gatilho para leitura                              |
| ✅     | ReadTimer_rolo2             | TON           | -                                | Timer para leituras periódicas                    |
| ✅     | MaxSpeedSet_rolo2           | UINT          | -                                | Velocidade máxima configurada                     |
| ✅     | MinSpeedSet_rolo2           | UINT          | -                                | Velocidade mínima configurada                     |
| ✅     | MaxTorqueSet_rolo2          | UINT          | -                                | Torque máximo configurado                         |
| ✅     | MinTorqueSet_rolo2          | UINT          | -                                | Torque mínimo configurado                         |
| ✅     | P0498Set_rolo2              | UINT          | -                                | Configuração P0498                                |
| ✅     | MaxSpeedRead_rolo2          | UINT          | -                                | Velocidade máxima lida                            |
| ✅     | MinSpeedRead_rolo2          | UINT          | -                                | Velocidade mínima lida                            |
| ✅     | MaxTorqueRead_rolo2         | UINT          | -                                | Torque máximo lido                                |
| ✅     | MinTorqueRead_rolo2         | UINT          | -                                | Torque mínimo lido                                |
| ✅     | P0498Read_rolo2             | UINT          | -                                | P0498 lido                                        |
| ✅     | TorquePercent_rolo2         | UINT          | -                                | Percentual de torque                              |
| ✅     | OutputFreq_rolo2            | UINT          | -                                | Frequência de saída (P0002)                       |
| ✅     | TorquePercentScaled_rolo2   | REAL          | -                                | Torque percentual escalado                        |
| ✅     | OutputCurrentScaled_rolo2   | REAL          | -                                | Corrente de saída escalada (P0003)                |
| ✅     | OutputFreqScaled_rolo2      | REAL          | -                                | Frequência de saída escalada                      |
| ✅     | TempReal_rolo2              | REAL          | -                                | Variável temporária REAL                          |
| ✅     | OutputCurrent_rolo2         | UINT          | -                                | Corrente de saída (P0003)                         |
| ✅     | WriteStep_rolo2             | INT           | 0                                | Passo da escrita sequencial                       |
| ✅     | ReadStep_rolo2              | INT           | 0                                | Passo da leitura sequencial                       |
| ✅     | EnableDrive_rolo2           | BOOL          | -                                | Controle de habilitação do drive                  |
| ✅     | CommunicationOK_rolo2       | BOOL          | -                                | Status de comunicação Modbus                      |
| ✅     | WriteError_rolo2            | BOOL          | -                                | Flag de erro na escrita                           |
| ✅     | ReadError_rolo2             | BOOL          | -                                | Flag de erro na leitura                           |
| ✅     | ControlTypeSet_rolo2        | UINT          | 2                                | P0100 = 2 para Vector Sensorless                  |
| ✅     | ControlTypeRead_rolo2       | UINT          | -                                | Tipo de controle lido                             |
| ✅     | VerificationTimer_rolo2     | TON           | -                                | Timer para verificações periódicas                |
| ✅     | VerificationTrigger_rolo2   | BOOL          | -                                | Gatilho de verificação                            |
| ✅     | VerificationStep_rolo2      | INT           | 0                                | Passo da verificação                              |
| ✅     | ReadMsg_P0100_rolo2         | MSG_MODBUS    | -                                | Leitura P0100                                     |
| ✅     | ReadMsg_P0134_P0133_rolo2   | MSG_MODBUS    | -                                | P0134 (Max Speed) e P0133 (Min Speed)             |
| ✅     | ReadMsg_P0169_P0170_rolo2   | MSG_MODBUS    | -                                | P0169 (Max Torque) e P0170 (Min Torque)           |
| ✅     | SpeedTorqueAlarm_rolo2      | BOOL          | FALSE                            | Alarme velocidade vs torque                       |
| ✅     | SpeedTorqueAlarmTimer_rolo2 | TON           | -                                | Timer para alarme velocidade-torque               |

## Variáveis para CTRLROLO3 (POU)

| Status | Variável                    | Tipo          | Valor Inicial                    | Descrição                                         |
| ------ | --------------------------- | ------------- | -------------------------------- | ------------------------------------------------- |
| ✅     | LocalCfg_rolo3              | MODBUSLOCPARA | (Channel := 2, TriggerType := 0) | Configuração local Modbus                         |
| ✅     | TargetCfg_rolo3             | MODBUSTARPARA | (Node := 3)                      | Configuração do alvo Modbus                       |
| ✅     | LocalAddr_rolo3             | MODBUSLOCADDR | -                                | Endereço local Modbus                             |
| ✅     | WriteMsg_rolo3              | MSG_MODBUS    | -                                | Mensagem de escrita Modbus                        |
| ✅     | ReadMsg_P0009_rolo3         | MSG_MODBUS    | -                                | Leitura P0009 (Torque)                            |
| ✅     | ReadMsg_P0002_P0003_rolo3   | MSG_MODBUS    | -                                | P0002 (Output Frequency) e P0003 (Output Current) |
| ✅     | WriteTrigger_rolo3          | BOOL          | -                                | Gatilho para escrita                              |
| ✅     | ReadTrigger_rolo3           | BOOL          | -                                | Gatilho para leitura                              |
| ✅     | ReadTimer_rolo3             | TON           | -                                | Timer para leituras periódicas                    |
| ✅     | MaxSpeedSet_rolo3           | UINT          | -                                | Velocidade máxima configurada                     |
| ✅     | MinSpeedSet_rolo3           | UINT          | -                                | Velocidade mínima configurada                     |
| ✅     | MaxTorqueSet_rolo3          | UINT          | -                                | Torque máximo configurado                         |
| ✅     | MinTorqueSet_rolo3          | UINT          | -                                | Torque mínimo configurado                         |
| ✅     | P0498Set_rolo3              | UINT          | -                                | Configuração P0498                                |
| ✅     | MaxSpeedRead_rolo3          | UINT          | -                                | Velocidade máxima lida                            |
| ✅     | MinSpeedRead_rolo3          | UINT          | -                                | Velocidade mínima lida                            |
| ✅     | MaxTorqueRead_rolo3         | UINT          | -                                | Torque máximo lido                                |
| ✅     | MinTorqueRead_rolo3         | UINT          | -                                | Torque mínimo lido                                |
| ✅     | P0498Read_rolo3             | UINT          | -                                | P0498 lido                                        |
| ✅     | TorquePercent_rolo3         | UINT          | -                                | Percentual de torque                              |
| ✅     | OutputFreq_rolo3            | UINT          | -                                | Frequência de saída (P0002)                       |
| ✅     | TorquePercentScaled_rolo3   | REAL          | -                                | Torque percentual escalado                        |
| ✅     | OutputCurrentScaled_rolo3   | REAL          | -                                | Corrente de saída escalada (P0003)                |
| ✅     | OutputFreqScaled_rolo3      | REAL          | -                                | Frequência de saída escalada                      |
| ✅     | TempReal_rolo3              | REAL          | -                                | Variável temporária REAL                          |
| ✅     | OutputCurrent_rolo3         | UINT          | -                                | Corrente de saída (P0003)                         |
| ✅     | WriteStep_rolo3             | INT           | 0                                | Passo da escrita sequencial                       |
| ✅     | ReadStep_rolo3              | INT           | 0                                | Passo da leitura sequencial                       |
| ✅     | EnableDrive_rolo3           | BOOL          | -                                | Controle de habilitação do drive                  |
| ✅     | CommunicationOK_rolo3       | BOOL          | -                                | Status de comunicação Modbus                      |
| ✅     | WriteError_rolo3            | BOOL          | -                                | Flag de erro na escrita                           |
| ✅     | ReadError_rolo3             | BOOL          | -                                | Flag de erro na leitura                           |
| ✅     | ControlTypeSet_rolo3        | UINT          | 2                                | P0100 = 2 para Vector Sensorless                  |
| ✅     | ControlTypeRead_rolo3       | UINT          | -                                | Tipo de controle lido                             |
| ✅     | VerificationTimer_rolo3     | TON           | -                                | Timer para verificações periódicas                |
| ✅     | VerificationTrigger_rolo3   | BOOL          | -                                | Gatilho de verificação                            |
| ✅     | VerificationStep_rolo3      | INT           | 0                                | Passo da verificação                              |
| ✅     | ReadMsg_P0100_rolo3         | MSG_MODBUS    | -                                | Leitura P0100                                     |
| ✅     | ReadMsg_P0134_P0133_rolo3   | MSG_MODBUS    | -                                | P0134 (Max Speed) e P0133 (Min Speed)             |
| ✅     | ReadMsg_P0169_P0170_rolo3   | MSG_MODBUS    | -                                | P0169 (Max Torque) e P0170 (Min Torque)           |
| ✅     | SpeedTorqueAlarm_rolo3      | BOOL          | FALSE                            | Alarme velocidade vs torque                       |
| ✅     | SpeedTorqueAlarmTimer_rolo3 | TON           | -                                | Timer para alarme velocidade-torque               |

## Notas Técnicas

### Inicializações

- Aplicadas apenas onde especificadas (ex.: `:= 0` para INTs, structs para MODBUSLOCPARA/MODBUSTARPARA)
- Tipos de dados devem estar disponíveis no CCW (geralmente pré-definidos para Modbus)

### Acesso Global

- `ModbusBusy` deve ser acessível de todos os POUs (declarar como global no projeto)

### Timers

- Timers são declarados como TON, mas intervalos são definidos no código ST
- ReadTimer: 1 segundo para leituras
- VerificationTimer: 10 segundos para verificações
- SpeedTorqueAlarmTimer: 5 segundos para alarme

### Variáveis para PV800

- `TorqueMax`, `SpeedMax`, `SpeedMin` podem ser ajustadas na tela do HMI
- Valores são validados e limitados antes da conversão para unidades do inversor

### Lógica de Escrita

- Apenas escreve parâmetros quando valores do HMI mudam
- Evita escritas desnecessárias no equipamento

---

_Data da Verificação: Outubro 2025_
_Status: Todas as variáveis verificadas e implementadas_
_Versão do Sistema: 2.1_
