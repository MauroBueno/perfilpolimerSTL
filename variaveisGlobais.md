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

| Variável                         | Tipo | Valor Inicial | Descrição                                        |
| -------------------------------- | ---- | ------------- | ------------------------------------------------ |
| MAX_RETRIES                      | INT  | 3             | Número máximo de tentativas para comunicações    |
| WriteRetryCount_rolo1            | INT  | 0             | Contador de retry para operações de escrita      |
| ReadRetryCount_rolo1             | INT  | 0             | Contador de retry para operações de leitura      |
| ReadRetryCount_P0408_P0410_rolo1 | INT  | 0             | Contador de retry para leitura P0408/P0409/P0410 |
| VerificationRetryCount_rolo1     | INT  | 0             | Contador de retry para operações de verificação  |
| WriteRetryCount_rolo2            | INT  | 0             | Contador de retry para operações de escrita      |
| ReadRetryCount_rolo2             | INT  | 0             | Contador de retry para operações de leitura      |
| ReadRetryCount_P0408_P0410_rolo2 | INT  | 0             | Contador de retry para leitura P0408/P0409/P0410 |
| VerificationRetryCount_rolo2     | INT  | 0             | Contador de retry para operações de verificação  |
| WriteRetryCount_rolo3            | INT  | 0             | Contador de retry para operações de escrita      |
| ReadRetryCount_rolo3             | INT  | 0             | Contador de retry para operações de leitura      |
| ReadRetryCount_P0408_P0410_rolo3 | INT  | 0             | Contador de retry para leitura P0408/P0409/P0410 |
| VerificationRetryCount_rolo3     | INT  | 0             | Contador de retry para operações de verificação  |

### Limites e Constantes do Sistema

| Variável                 | Tipo | Valor Inicial | Descrição                                         | Unidades |
| ------------------------ | ---- | ------------- | ------------------------------------------------- | -------- |
| SPEED_MAX_LIMIT          | REAL | 100.0         | Limite máximo de velocidade em Hz                 | Hz       |
| SPEED_MIN_LIMIT          | REAL | 0.0           | Limite mínimo de velocidade em Hz                 | Hz       |
| TORQUE_MAX_LIMIT         | REAL | 200.0         | Limite máximo de torque em %                      | %        |
| TORQUE_MIN_LIMIT         | REAL | 0.0           | Limite mínimo de torque em %                      | %        |
| SPEED_TORQUE_RATIO       | REAL | 0.5           | Razão mínima velocidade/torque (Hz/%)             | Hz/%     |
| SPEED_TORQUE_ALARM_DELAY | TIME | T#5s          | Atraso antes de disparar alarme velocidade-torque | segundos |
| ERROR_RECOVERY_TIME      | TIME | T#30s         | Tempo após o qual limpar flags de erro            | segundos |

### Timers de Recuperação de Erros

| Variável                 | Tipo | Valor Inicial | Descrição                                                     |
| ------------------------ | ---- | ------------- | ------------------------------------------------------------- |
| ErrorRecoveryTimer_rolo1 | TON  | -             | Timer para limpar flags de erro após comunicação bem-sucedida |
| ErrorRecoveryTimer_rolo2 | TON  | -             | Timer para limpar flags de erro após comunicação bem-sucedida |
| ErrorRecoveryTimer_rolo3 | TON  | -             | Timer para limpar flags de erro após comunicação bem-sucedida |

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
| ReadMsg_P0408_P0410_rolo1 | MSG_MODBUS | -             | Leitura P0408, P0409 e P0410                      |
| ReadMsg_P0100_rolo1       | MSG_MODBUS | -             | Para verificar P0100                              |
| ReadMsg_P0134_P0133_rolo1 | MSG_MODBUS | -             | P0134 (Max Speed) e P0133 (Min Speed)             |
| ReadMsg_P0169_P0170_rolo1 | MSG_MODBUS | -             | P0169 (Max Torque) e P0170 (Min Torque)           |

### Controles e Gatilhos

| Variável           | Tipo | Valor Inicial | Descrição            |
| ------------------ | ---- | ------------- | -------------------- |
| WriteTrigger_rolo1 | BOOL | -             | Gatilho para escrita |
| ReadTrigger_rolo1  | BOOL | -             | Gatilho para leitura |

### Timers

| Variável                    | Tipo | Valor Inicial | Descrição                                  |
| --------------------------- | ---- | ------------- | ------------------------------------------ |
| ReadTimer_rolo1             | TON  | -             | Timer para leituras periódicas (10s)       |
| ReadTimer_P0408_P0410_rolo1 | TON  | -             | Timer para leitura P0408/P0409/P0410 (10s) |
| VerificationTimer_rolo1     | TON  | -             | Timer para verificações periódicas (10s)   |
| SpeedTorqueAlarmTimer_rolo1 | TON  | -             | Timer para alarme velocidade-torque        |

### Setpoints Calculados

| Variável           | Tipo | Valor Inicial | Descrição                            |
| ------------------ | ---- | ------------- | ------------------------------------ |
| MaxSpeedSet_rolo1  | UINT | -             | Velocidade máxima configurada        |
| MinSpeedSet_rolo1  | UINT | -             | Velocidade mínima configurada        |
| MaxTorqueSet_rolo1 | UINT | -             | Torque máximo configurado            |
| MinTorqueSet_rolo1 | UINT | -             | Torque mínimo configurado            |
| P0498Set_rolo1     | BOOL | FALSE         | Comando para salvar parâmetros (0/1) |

### Valores Lidos do Drive

| Variável            | Tipo | Valor Inicial | Descrição                           |
| ------------------- | ---- | ------------- | ----------------------------------- |
| MaxSpeedRead_rolo1  | UINT | -             | Velocidade máxima lida              |
| MinSpeedRead_rolo1  | UINT | -             | Velocidade mínima lida              |
| MaxTorqueRead_rolo1 | UINT | -             | Torque máximo lido                  |
| MinTorqueRead_rolo1 | UINT | -             | Torque mínimo lido                  |
| P0498Read_rolo1     | BOOL | FALSE         | Status salvar parâmetros lido (0/1) |

### Valores de Monitoramento (RAW)

| Variável            | Tipo | Valor Inicial | Descrição                            |
| ------------------- | ---- | ------------- | ------------------------------------ |
| TorquePercent_rolo1 | UINT | -             | Percentual de torque                 |
| OutputFreq_rolo1    | UINT | -             | Frequência de saída (P0002)          |
| OutputCurrent_rolo1 | UINT | -             | Corrente de saída (P0003)            |
| P0408_rolo1         | UINT | -             | Vector Sensorless Enable (0 ou 1)    |
| P0409_rolo1         | UINT | -             | Resistência do Estator Rs (0.01 ohm) |
| P0410_rolo1         | UINT | -             | Corrente de Magnetização Im (0.01 A) |

### Valores Escalados para Display

| Variável                  | Tipo | Valor Inicial | Descrição                    | Unidades |
| ------------------------- | ---- | ------------- | ---------------------------- | -------- |
| TorquePercentScaled_rolo1 | REAL | -             | Torque percentual escalado   | %        |
| OutputCurrentScaled_rolo1 | REAL | -             | Corrente de saída escalada   | A        |
| OutputFreqScaled_rolo1    | REAL | -             | Frequência de saída escalada | Hz       |
| P0408Scaled_rolo1         | REAL | -             | Vector Enable (0.0 ou 1.0)   | -        |
| P0409Scaled_rolo1         | REAL | -             | Resistência do Estator Rs    | Ω        |
| P0410Scaled_rolo1         | REAL | -             | Corrente de Magnetização Im  | A        |
| TempReal_rolo1            | REAL | -             | Variável temporária REAL     | -        |

### Controle de Estado e Sequências

| Variável                   | Tipo | Valor Inicial | Descrição                          |
| -------------------------- | ---- | ------------- | ---------------------------------- |
| WriteStep_rolo1            | INT  | 0             | Passo da escrita sequencial        |
| ReadStep_rolo1             | INT  | 0             | Passo da leitura sequencial        |
| ReadStep_P0408_P0410_rolo1 | INT  | 0             | Passo da leitura P0408/P0409/P0410 |
| VerificationStep_rolo1     | INT  | 0             | Passo da verificação               |
| ControlTypeSet_rolo1       | UINT | 2             | P0100 = 2 para Vector Sensorless   |
| ControlTypeRead_rolo1      | UINT | -             | Tipo de controle lido              |
| VerificationTrigger_rolo1  | BOOL | -             | Gatilho de verificação             |

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

### Configurações Modbus - Rolo2

| Variável        | Tipo          | Valor Inicial                    | Descrição                   |
| --------------- | ------------- | -------------------------------- | --------------------------- |
| LocalCfg_rolo2  | MODBUSLOCPARA | (Channel := 2, TriggerType := 0) | Configuração local Modbus   |
| TargetCfg_rolo2 | MODBUSTARPARA | (Node := 2)                      | Configuração do alvo Modbus |
| LocalAddr_rolo2 | MODBUSLOCADDR | -                                | Endereço local Modbus       |

## Variáveis para CTRLROLO3 (POU)

_(Mesmas variáveis que CTRLROLO1, com sufixo `_rolo3` e Node := 3)_

### Configurações Modbus - Rolo3

| Variável        | Tipo          | Valor Inicial                    | Descrição                   |
| --------------- | ------------- | -------------------------------- | --------------------------- |
| LocalCfg_rolo3  | MODBUSLOCPARA | (Channel := 2, TriggerType := 0) | Configuração local Modbus   |
| TargetCfg_rolo3 | MODBUSTARPARA | (Node := 3)                      | Configuração do alvo Modbus |
| LocalAddr_rolo3 | MODBUSLOCADDR | -                                | Endereço local Modbus       |

## Notas Técnicas

### Inicializações

- Aplicadas apenas onde especificadas (ex.: `:= 0` para INTs, structs para MODBUSLOCPARA/MODBUSTARPARA)
- Tipos de dados devem estar disponíveis no CCW (geralmente pré-definidos para Modbus)

### Acesso Global

- `ModbusBusy` deve ser acessível de todos os POUs (declarar como global no projeto)

### Timers e Periodicidades

- **ReadTimer**: 10 segundos para leituras de P0009, P0002, P0003 (torque, frequência, corrente)
- **ReadTimer_P0409_P0410**: 10 segundos para leituras exclusivas de P0409/P0410
- **VerificationTimer**: 10 segundos para verificações críticas de parâmetros (P0100, velocidades, torques)
- **SpeedTorqueAlarmTimer**: 5 segundos para evitar alarmes falsos de velocidade vs torque

### Variáveis para PV800

- `TorqueMax`, `SpeedMax`, `SpeedMin` podem ser ajustadas na tela do HMI
- Valores são validados e limitados antes da conversão para unidades do inversor

### Lógica de Escrita

- Apenas escreve parâmetros quando valores do HMI mudam
- Evita escritas desnecessárias no equipamento
- Sistema de retry com até 3 tentativas por operação

### Sistema de Alarmes

- `SpeedTorqueAlarm`: Detecta quando velocidade < torque% × SPEED_TORQUE_RATIO
- Só ativo quando torque > 20% e drive habilitado
- Delay de 5 segundos para evitar falsos positivos

### Parâmetros P0408/P0409/P0410

- **P0408**: Vector Sensorless Enable (0 = Desabilitado, 1 = Habilitado) - Booleano
- **P0409**: Resistência do Estator (Rs) em ohms - Escala: ÷100 (0.01 ohm por unidade)
- **P0410**: Corrente de Magnetização (Im) em amperes - Escala: ÷100 (0.01 A por unidade)
- Leitura consecutiva (3 registros) com periodicidade de 10 segundos
- P0408: Valor booleano (0 ou 1)
- P0409/P0410: Valores reais escalados
- Valores brutos (UINT) e escalados (REAL) disponíveis
- Sistema de retry independente para estas leituras

### Estrutura de Comunicação

- Todas as operações Modbus são sequenciais usando flag `ModbusBusy`
- Quatro ciclos independentes:
  1. **Write Cycle**: Escrita de parâmetros (sob demanda)
  2. **Read Cycle**: Leitura de monitoramento a cada 10s (P0009, P0002, P0003)
  3. **Verification Cycle**: Verificação e correção de parâmetros críticos a cada 10s
  4. **P0408/P0409/P0410 Read Cycle**: Leitura de parâmetros Vector a cada 10s

---

_Data da Documentação: Outubro 2025_
_Versão do Sistema: 2.2_
_Última Atualização: Adição de leitura P0409/P0410 com ciclo independente_
