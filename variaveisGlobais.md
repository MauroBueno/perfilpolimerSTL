# Variáveis Globais - Sistema CFW500

# Connected Components Workbench (CCW)

## Visão Geral

Este documento contém todas as variáveis necessárias para o projeto no Connected Components Workbench (CCW). As variáveis estão organizadas por escopo e POU.

**Instruções de Uso:**

- Copie e declare essas variáveis no CCW conforme indicado
- As inicializações são baseadas no código ST
- Para os POUs, substitua X por 1, 2 ou 3 conforme o POU (ex.: para CTRLROLO1, use `_rolo1`)

## Variáveis Globais (Global Variables no Projeto CCW)

### Controles Gerais do Sistema

| Variável   | Tipo | Valor Inicial | Descrição                                  |
| ---------- | ---- | ------------- | ------------------------------------------ |
| ModbusBusy | BOOL | FALSE         | Flag para controlar acesso ao canal Modbus |

### Setpoints por Rolo (Ajustáveis via HMI)

| Variável        | Tipo | Valor Inicial | Descrição                              | Unidades |
| --------------- | ---- | ------------- | -------------------------------------- | -------- |
| TorqueMax_rolo1 | UINT | 1000          | Torque máximo para ajuste no PV800     | 0.1%     |
| SpeedMax_rolo1  | UINT | 6000          | Velocidade máxima para ajuste no PV800 | 0.1 Hz   |
| SpeedMin_rolo1  | UINT | 0             | Velocidade mínima para ajuste no PV800 | 0.1 Hz   |
| TorqueMax_rolo2 | UINT | 1000          | Torque máximo rolo 2                   | 0.1%     |
| SpeedMax_rolo2  | UINT | 6000          | Velocidade máxima rolo 2               | 0.1 Hz   |
| SpeedMin_rolo2  | UINT | 0             | Velocidade mínima rolo 2               | 0.1 Hz   |
| TorqueMax_rolo3 | UINT | 1000          | Torque máximo rolo 3                   | 0.1%     |
| SpeedMax_rolo3  | UINT | 6000          | Velocidade máxima rolo 3               | 0.1 Hz   |
| SpeedMin_rolo3  | UINT | 0             | Velocidade mínima rolo 3               | 0.1 Hz   |

### Detecção de Mudanças (Valores Anteriores)

| Variável           | Tipo | Valor Inicial | Descrição                             |
| ------------------ | ---- | ------------- | ------------------------------------- |
| TorqueMaxOld_rolo1 | UINT | 1000          | Valor antigo para detecção de mudança |
| SpeedMaxOld_rolo1  | UINT | 6000          | Valor antigo para detecção de mudança |
| SpeedMinOld_rolo1  | UINT | 0             | Valor antigo para detecção de mudança |
| WriteNeeded_rolo1  | BOOL | FALSE         | Flag para necessidade de escrita      |
| TorqueMaxOld_rolo2 | UINT | 1000          | Valor antigo para detecção de mudança |
| SpeedMaxOld_rolo2  | UINT | 6000          | Valor antigo para detecção de mudança |
| SpeedMinOld_rolo2  | UINT | 0             | Valor antigo para detecção de mudança |
| WriteNeeded_rolo2  | BOOL | FALSE         | Flag para necessidade de escrita      |
| TorqueMaxOld_rolo3 | UINT | 1000          | Valor antigo para detecção de mudança |
| SpeedMaxOld_rolo3  | UINT | 6000          | Valor antigo para detecção de mudança |
| SpeedMinOld_rolo3  | UINT | 0             | Valor antigo para detecção de mudança |
| WriteNeeded_rolo3  | BOOL | FALSE         | Flag para necessidade de escrita      |

### Sistema de Retry e Recuperação de Erros

| Variável                     | Tipo | Valor Inicial | Descrição                                        |
| ---------------------------- | ---- | ------------- | ------------------------------------------------ |
| MAX_RETRIES                  | INT  | 3             | Maximum retry attempts for failed communications |
| WriteRetryCount_rolo1        | INT  | 0             | Retry counter for write operations               |
| ReadRetryCount_rolo1         | INT  | 0             | Retry counter for read operations                |
| VerificationRetryCount_rolo1 | INT  | 0             | Retry counter for verification operations        |
| WriteRetryCount_rolo2        | INT  | 0             | Retry counter for write operations               |
| ReadRetryCount_rolo2         | INT  | 0             | Retry counter for read operations                |
| VerificationRetryCount_rolo2 | INT  | 0             | Retry counter for verification operations        |
| WriteRetryCount_rolo3        | INT  | 0             | Retry counter for write operations               |
| ReadRetryCount_rolo3         | INT  | 0             | Retry counter for read operations                |
| VerificationRetryCount_rolo3 | INT  | 0             | Retry counter for verification operations        |

### Limites e Constantes do Sistema

| Variável                 | Tipo | Valor Inicial | Descrição                                  | Unidades |
| ------------------------ | ---- | ------------- | ------------------------------------------ | -------- |
| SPEED_MAX_LIMIT          | REAL | 100.0         | Maximum speed limit in Hz                  | Hz       |
| SPEED_MIN_LIMIT          | REAL | 0.0           | Minimum speed limit in Hz                  | Hz       |
| TORQUE_MAX_LIMIT         | REAL | 200.0         | Maximum torque limit in %                  | %        |
| TORQUE_MIN_LIMIT         | REAL | 0.0           | Minimum torque limit in %                  | %        |
| SPEED_TORQUE_RATIO       | REAL | 0.5           | Minimum speed/torque ratio (Hz/%)          | Hz/%     |
| SPEED_TORQUE_ALARM_DELAY | TIME | T#5s          | Delay before triggering speed-torque alarm | segundos |
| ERROR_RECOVERY_TIME      | TIME | T#30s         | Time after which to clear error flags      | segundos |

### Timers de Recuperação de Erros

| Variável                 | Tipo | Valor Inicial | Descrição                                                     |
| ------------------------ | ---- | ------------- | ------------------------------------------------------------- |
| ErrorRecoveryTimer_rolo1 | TON  | -             | Timer for clearing error flags after successful communication |
| ErrorRecoveryTimer_rolo2 | TON  | -             | Timer for clearing error flags after successful communication |
| ErrorRecoveryTimer_rolo3 | TON  | -             | Timer for clearing error flags after successful communication |

## Variáveis para CTRLROLO1 (POU)

### Configurações Modbus

| Variável        | Tipo          | Valor Inicial                    | Descrição                   |
| --------------- | ------------- | -------------------------------- | --------------------------- |
| LocalCfg_rolo1  | MODBUSLOCPARA | (Channel := 2, TriggerType := 0) | Configuração local Modbus   |
| TargetCfg_rolo1 | MODBUSTARPARA | (Node := 1)                      | Configuração do alvo Modbus |
| LocalAddr_rolo1 | MODBUSLOCADDR | -                                | Endereço local Modbus       |

### Mensagens Modbus

| Variável                  | Tipo       | Valor Inicial | Descrição                                         |
| ------------------------- | ---------- | ------------- | ------------------------------------------------- |
| WriteMsg_rolo1            | MSG_MODBUS | -             | Mensagem de escrita Modbus                        |
| ReadMsg_P0009_rolo1       | MSG_MODBUS | -             | Leitura P0009 (Torque)                            |
| ReadMsg_P0002_P0003_rolo1 | MSG_MODBUS | -             | P0002 (Output Frequency) e P0003 (Output Current) |
| ReadMsg_P0100_rolo1       | MSG_MODBUS | -             | Para verificar P0100                              |
| ReadMsg_P0134_P0133_rolo1 | MSG_MODBUS | -             | P0134 (Max Speed) e P0133 (Min Speed)             |
| ReadMsg_P0169_P0170_rolo1 | MSG_MODBUS | -             | P0169 (Max Torque) e P0170 (Min Torque)           |

### Controles e Gatilhos

| Variável           | Tipo | Valor Inicial | Descrição            |
| ------------------ | ---- | ------------- | -------------------- |
| WriteTrigger_rolo1 | BOOL | -             | Gatilho para escrita |
| ReadTrigger_rolo1  | BOOL | -             | Gatilho para leitura |

### Timers

| Variável                    | Tipo | Valor Inicial | Descrição                           |
| --------------------------- | ---- | ------------- | ----------------------------------- |
| ReadTimer_rolo1             | TON  | -             | Timer para leituras periódicas      |
| VerificationTimer_rolo1     | TON  | -             | Timer para verificações periódicas  |
| SpeedTorqueAlarmTimer_rolo1 | TON  | -             | Timer para alarme velocidade-torque |

### Setpoints Calculados

| Variável           | Tipo | Valor Inicial | Descrição                     |
| ------------------ | ---- | ------------- | ----------------------------- |
| MaxSpeedSet_rolo1  | UINT | -             | Velocidade máxima configurada |
| MinSpeedSet_rolo1  | UINT | -             | Velocidade mínima configurada |
| MaxTorqueSet_rolo1 | UINT | -             | Torque máximo configurado     |
| MinTorqueSet_rolo1 | UINT | -             | Torque mínimo configurado     |
| P0498Set_rolo1     | UINT | -             | Configuração P0498            |

### Valores Lidos do Drive

| Variável            | Tipo | Valor Inicial | Descrição              |
| ------------------- | ---- | ------------- | ---------------------- |
| MaxSpeedRead_rolo1  | UINT | -             | Velocidade máxima lida |
| MinSpeedRead_rolo1  | UINT | -             | Velocidade mínima lida |
| MaxTorqueRead_rolo1 | UINT | -             | Torque máximo lido     |
| MinTorqueRead_rolo1 | UINT | -             | Torque mínimo lido     |
| P0498Read_rolo1     | UINT | -             | P0498 lido             |

### Valores de Monitoramento (RAW)

| Variável            | Tipo | Valor Inicial | Descrição                   |
| ------------------- | ---- | ------------- | --------------------------- |
| TorquePercent_rolo1 | UINT | -             | Percentual de torque        |
| OutputFreq_rolo1    | UINT | -             | Frequência de saída (P0002) |
| OutputCurrent_rolo1 | UINT | -             | Corrente de saída (P0003)   |

### Valores Escalados para Display

| Variável                  | Tipo | Valor Inicial | Descrição                    | Unidades |
| ------------------------- | ---- | ------------- | ---------------------------- | -------- |
| TorquePercentScaled_rolo1 | REAL | -             | Torque percentual escalado   | %        |
| OutputCurrentScaled_rolo1 | REAL | -             | Corrente de saída escalada   | A        |
| OutputFreqScaled_rolo1    | REAL | -             | Frequência de saída escalada | Hz       |
| TempReal_rolo1            | REAL | -             | Variável temporária REAL     | -        |

### Controle de Estado e Sequências

| Variável                  | Tipo | Valor Inicial | Descrição                        |
| ------------------------- | ---- | ------------- | -------------------------------- |
| WriteStep_rolo1           | INT  | 0             | Passo da escrita sequencial      |
| ReadStep_rolo1            | INT  | 0             | Passo da leitura sequencial      |
| VerificationStep_rolo1    | INT  | 0             | Passo da verificação             |
| ControlTypeSet_rolo1      | UINT | 2             | P0100 = 2 para Vector Sensorless |
| ControlTypeRead_rolo1     | UINT | -             | Tipo de controle lido            |
| VerificationTrigger_rolo1 | BOOL | -             | Gatilho de verificação           |

### Status e Controle do Drive

| Variável               | Tipo | Valor Inicial | Descrição                        |
| ---------------------- | ---- | ------------- | -------------------------------- |
| EnableDrive_rolo1      | BOOL | -             | Controle de habilitação do drive |
| CommunicationOK_rolo1  | BOOL | -             | Status de comunicação Modbus     |
| WriteError_rolo1       | BOOL | -             | Flag de erro na escrita          |
| ReadError_rolo1        | BOOL | -             | Flag de erro na leitura          |
| SpeedTorqueAlarm_rolo1 | BOOL | FALSE         | Alarme velocidade vs torque      |

## Variáveis para CTRLROLO2 (POU)

_(Mesmas variáveis que CTRLROLO1, com sufixo `_rolo2` e Node := 2)_

## Variáveis para CTRLROLO3 (POU)

_(Mesmas variáveis que CTRLROLO1, com sufixo `_rolo3` e Node := 3)_

## Notas Técnicas

### Inicializações

- Aplicadas apenas onde especificadas (ex.: `:= 0` para INTs, structs para MODBUSLOCPARA/MODBUSTARPARA)
- Tipos de dados devem estar disponíveis no CCW (geralmente pré-definidos para Modbus)

### Acesso Global

- `ModbusBusy` deve ser acessível de todos os POUs (declarar como global no projeto)

### Timers

- `ReadTimer`: 1 segundo para leituras periódicas
- `VerificationTimer`: 10 segundos para verificações críticas
- `SpeedTorqueAlarmTimer`: 5 segundos para evitar alarmes falsos

### Variáveis para PV800

- `TorqueMax`, `SpeedMax`, `SpeedMin` podem ser ajustadas na tela do HMI
- Valores são validados e limitados antes da conversão para unidades do inversor

### Lógica de Escrita

- Apenas escreve parâmetros quando valores do HMI mudam
- Evita escritas desnecessárias no equipamento

### Sistema de Alarmes

- `SpeedTorqueAlarm`: Detecta quando velocidade < torque% × SPEED_TORQUE_RATIO
- Só ativo quando torque > 20% e drive habilitado

---

_Data da Documentação: Outubro 2025_
_Versão do Sistema: 2.1_
