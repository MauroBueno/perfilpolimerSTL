# Especificação de Variáveis para IHM PanelView 800

## Sistema de Controle de Bobinadeira - CFW500

---

## Sumário

1. [Visão Geral](#visão-geral)
2. [Variáveis de Entrada (Operador → CLP)](#variáveis-de-entrada-operador--clp)
3. [Variáveis de Monitoramento (CLP → IHM)](#variáveis-de-monitoramento-clp--ihm)
4. [Variáveis de Status e Alarmes](#variáveis-de-status-e-alarmes)
5. [Variáveis de Controle (Comandos)](#variáveis-de-controle-comandos)
6. [Resumo Total de Variáveis](#resumo-total-de-variáveis)
7. [Sugestões de Layout de Telas](#sugestões-de-layout-de-telas)
8. [Configuração de Comunicação](#configuração-de-comunicação)
9. [Validações e Limites](#validações-e-limites)

---

## Visão Geral

Este documento especifica todas as variáveis necessárias para criar as telas do IHM (Interface Homem-Máquina) no PanelView 800 para o sistema de controle de bobinadeira com três rolos independentes.

### Características do Sistema

- **Número de Rolos**: 3 (Rolo 1, Rolo 2, Rolo 3)
- **Inversor por Rolo**: WEG CFW500
- **Protocolo**: Modbus RTU
- **CLP**: Allen Bradley Micro850 (Connected Components Workbench)
- **IHM**: Allen Bradley PanelView 800
- **Taxa de Atualização**: 10 segundos para leituras de monitoramento

---

## Variáveis de Entrada (Operador → CLP)

Estas são as variáveis que o operador pode ajustar através do IHM. Valores são validados no CLP antes de serem enviados aos inversores.

### Rolo 1

| Variável          | Tipo | Unidade | Descrição              | Faixa Válida | Valor Padrão | Incremento Sugerido |
| ----------------- | ---- | ------- | ---------------------- | ------------ | ------------ | ------------------- |
| `SpeedMax_rolo1`  | REAL | Hz      | Velocidade Máxima      | 0.0 - 100.0  | 60.0         | 0.1                 |
| `SpeedMin_rolo1`  | REAL | Hz      | Velocidade Mínima      | 0.0 - 100.0  | 0.0          | 0.1                 |
| `TorqueMax_rolo1` | REAL | %       | Torque Máximo (Limite) | 0.0 - 200.0  | 100.0        | 1.0                 |

**Notas**:

- `SpeedMin` deve ser sempre ≤ `SpeedMax`
- Validação automática no CLP limita valores fora da faixa
- Valores são convertidos internamente (×100 para velocidade, ×10 para torque)

### Rolo 2

| Variável          | Tipo | Unidade | Descrição              | Faixa Válida | Valor Padrão | Incremento Sugerido |
| ----------------- | ---- | ------- | ---------------------- | ------------ | ------------ | ------------------- |
| `SpeedMax_rolo2`  | REAL | Hz      | Velocidade Máxima      | 0.0 - 100.0  | 60.0         | 0.1                 |
| `SpeedMin_rolo2`  | REAL | Hz      | Velocidade Mínima      | 0.0 - 100.0  | 0.0          | 0.1                 |
| `TorqueMax_rolo2` | REAL | %       | Torque Máximo (Limite) | 0.0 - 200.0  | 100.0        | 1.0                 |

### Rolo 3

| Variável          | Tipo | Unidade | Descrição              | Faixa Válida | Valor Padrão | Incremento Sugerido |
| ----------------- | ---- | ------- | ---------------------- | ------------ | ------------ | ------------------- |
| `SpeedMax_rolo3`  | REAL | Hz      | Velocidade Máxima      | 0.0 - 100.0  | 60.0         | 0.1                 |
| `SpeedMin_rolo3`  | REAL | Hz      | Velocidade Mínima      | 0.0 - 100.0  | 0.0          | 0.1                 |
| `TorqueMax_rolo3` | REAL | %       | Torque Máximo (Limite) | 0.0 - 200.0  | 100.0        | 1.0                 |

**Total de Variáveis de Entrada**: 9

---

## Variáveis de Monitoramento (CLP → IHM)

Estas variáveis exibem valores em tempo real do processo. São somente leitura no IHM.

### Rolo 1

| Variável                    | Tipo | Unidade  | Descrição                     | Taxa de Atualização | Formato Sugerido |
| --------------------------- | ---- | -------- | ----------------------------- | ------------------- | ---------------- |
| `TorquePercentScaled_rolo1` | REAL | %        | Torque Atual do Motor         | 10 segundos         | ##0.0            |
| `OutputFreqScaled_rolo1`    | REAL | Hz       | Velocidade Atual (Frequência) | 10 segundos         | ##0.0            |
| `OutputCurrentScaled_rolo1` | REAL | A        | Corrente de Saída             | 10 segundos         | ##0.0            |
| `P0409Scaled_rolo1`         | REAL | Variável | Parâmetro Adicional 1\*       | 10 segundos         | ####0            |
| `P0410Scaled_rolo1`         | REAL | Variável | Parâmetro Adicional 2\*       | 10 segundos         | ####0            |

**Nota**: \*P0409 e P0410 têm função dependente da configuração do CFW500. Consulte o manual do inversor para significado específico.

### Rolo 2

| Variável                    | Tipo | Unidade  | Descrição                     | Taxa de Atualização | Formato Sugerido |
| --------------------------- | ---- | -------- | ----------------------------- | ------------------- | ---------------- |
| `TorquePercentScaled_rolo2` | REAL | %        | Torque Atual do Motor         | 10 segundos         | ##0.0            |
| `OutputFreqScaled_rolo2`    | REAL | Hz       | Velocidade Atual (Frequência) | 10 segundos         | ##0.0            |
| `OutputCurrentScaled_rolo2` | REAL | A        | Corrente de Saída             | 10 segundos         | ##0.0            |
| `P0409Scaled_rolo2`         | REAL | Variável | Parâmetro Adicional 1\*       | 10 segundos         | ####0            |
| `P0410Scaled_rolo2`         | REAL | Variável | Parâmetro Adicional 2\*       | 10 segundos         | ####0            |

### Rolo 3

| Variável                    | Tipo | Unidade  | Descrição                     | Taxa de Atualização | Formato Sugerido |
| --------------------------- | ---- | -------- | ----------------------------- | ------------------- | ---------------- |
| `TorquePercentScaled_rolo3` | REAL | %        | Torque Atual do Motor         | 10 segundos         | ##0.0            |
| `OutputFreqScaled_rolo3`    | REAL | Hz       | Velocidade Atual (Frequência) | 10 segundos         | ##0.0            |
| `OutputCurrentScaled_rolo3` | REAL | A        | Corrente de Saída             | 10 segundos         | ##0.0            |
| `P0409Scaled_rolo3`         | REAL | Variável | Parâmetro Adicional 1\*       | 10 segundos         | ####0            |
| `P0410Scaled_rolo3`         | REAL | Variável | Parâmetro Adicional 2\*       | 10 segundos         | ####0            |

**Total de Variáveis de Monitoramento**: 15

---

## Variáveis de Status e Alarmes

Indicadores visuais para informar o operador sobre o estado do sistema.

### Rolo 1

| Variável                 | Tipo | Descrição                                 | Estado Normal | Cor Sugerida (Normal/Alarme) |
| ------------------------ | ---- | ----------------------------------------- | ------------- | ---------------------------- |
| `CommunicationOK_rolo1`  | BOOL | Comunicação Modbus OK                     | TRUE          | Verde / Vermelho             |
| `WriteError_rolo1`       | BOOL | Erro ao Escrever Parâmetros               | FALSE         | Verde / Vermelho             |
| `ReadError_rolo1`        | BOOL | Erro ao Ler Parâmetros                    | FALSE         | Verde / Vermelho             |
| `SpeedTorqueAlarm_rolo1` | BOOL | Alarme: Velocidade Baixa para Torque Alto | FALSE         | Verde / Amarelo              |
| `EnableDrive_rolo1`      | BOOL | Drive Habilitado/Em Operação              | -             | Cinza / Verde                |

**Descrições dos Alarmes**:

- **CommunicationOK**: Indica se comunicação Modbus está funcionando
- **WriteError**: Falha ao escrever parâmetros após 3 tentativas
- **ReadError**: Falha ao ler parâmetros após 3 tentativas
- **SpeedTorqueAlarm**: Disparado quando torque > 20% mas velocidade < (torque × 0.5 Hz/%)
- **EnableDrive**: Indica se motor está habilitado

### Rolo 2

| Variável                 | Tipo | Descrição                                 | Estado Normal | Cor Sugerida (Normal/Alarme) |
| ------------------------ | ---- | ----------------------------------------- | ------------- | ---------------------------- |
| `CommunicationOK_rolo2`  | BOOL | Comunicação Modbus OK                     | TRUE          | Verde / Vermelho             |
| `WriteError_rolo2`       | BOOL | Erro ao Escrever Parâmetros               | FALSE         | Verde / Vermelho             |
| `ReadError_rolo2`        | BOOL | Erro ao Ler Parâmetros                    | FALSE         | Verde / Vermelho             |
| `SpeedTorqueAlarm_rolo2` | BOOL | Alarme: Velocidade Baixa para Torque Alto | FALSE         | Verde / Amarelo              |
| `EnableDrive_rolo2`      | BOOL | Drive Habilitado/Em Operação              | -             | Cinza / Verde                |

### Rolo 3

| Variável                 | Tipo | Descrição                                 | Estado Normal | Cor Sugerida (Normal/Alarme) |
| ------------------------ | ---- | ----------------------------------------- | ------------- | ---------------------------- |
| `CommunicationOK_rolo3`  | BOOL | Comunicação Modbus OK                     | TRUE          | Verde / Vermelho             |
| `WriteError_rolo3`       | BOOL | Erro ao Escrever Parâmetros               | FALSE         | Verde / Vermelho             |
| `ReadError_rolo3`        | BOOL | Erro ao Ler Parâmetros                    | FALSE         | Verde / Vermelho             |
| `SpeedTorqueAlarm_rolo3` | BOOL | Alarme: Velocidade Baixa para Torque Alto | FALSE         | Verde / Amarelo              |
| `EnableDrive_rolo3`      | BOOL | Drive Habilitado/Em Operação              | -             | Cinza / Verde                |

**Total de Variáveis de Status/Alarme**: 15

---

## Variáveis de Controle (Comandos)

Botões e comandos que o operador pode acionar.

### Rolo 1

| Variável             | Tipo | Descrição                              | Ação                   | Tipo de Botão |
| -------------------- | ---- | -------------------------------------- | ---------------------- | ------------- |
| `WriteTrigger_rolo1` | BOOL | Forçar Escrita Imediata dos Parâmetros | Set momentâneo (pulso) | Push Button   |
| `EnableDrive_rolo1`  | BOOL | Habilitar/Desabilitar Drive            | Toggle (liga/desliga)  | Toggle Button |

**Comportamento**:

- **WriteTrigger**: Quando pressionado, força escrita imediata de todos os parâmetros. Auto-reset após escrita.
- **EnableDrive**: Alterna entre habilitar e desabilitar o motor do rolo.

### Rolo 2

| Variável             | Tipo | Descrição                              | Ação                   | Tipo de Botão |
| -------------------- | ---- | -------------------------------------- | ---------------------- | ------------- |
| `WriteTrigger_rolo2` | BOOL | Forçar Escrita Imediata dos Parâmetros | Set momentâneo (pulso) | Push Button   |
| `EnableDrive_rolo2`  | BOOL | Habilitar/Desabilitar Drive            | Toggle (liga/desliga)  | Toggle Button |

### Rolo 3

| Variável             | Tipo | Descrição                              | Ação                   | Tipo de Botão |
| -------------------- | ---- | -------------------------------------- | ---------------------- | ------------- |
| `WriteTrigger_rolo3` | BOOL | Forçar Escrita Imediata dos Parâmetros | Set momentâneo (pulso) | Push Button   |
| `EnableDrive_rolo3`  | BOOL | Habilitar/Desabilitar Drive            | Toggle (liga/desliga)  | Toggle Button |

**Total de Variáveis de Controle**: 6

---

## Resumo Total de Variáveis

| Categoria           | Quantidade | Tipo |
| ------------------- | ---------- | ---- |
| Entrada (Setpoints) | 9          | REAL |
| Monitoramento       | 15         | REAL |
| Status/Alarmes      | 15         | BOOL |
| Controle (Comandos) | 6          | BOOL |
| **TOTAL**           | **45**     | -    |

### Distribuição por Rolo

Cada rolo tem:

- 3 variáveis REAL de entrada (setpoints)
- 5 variáveis REAL de monitoramento
- 5 variáveis BOOL de status/alarme
- 2 variáveis BOOL de controle

**Total por Rolo**: 15 variáveis

---

## Sugestões de Layout de Telas

### 1. Tela Principal - Visão Geral

**Função**: Visão rápida dos três rolos com valores principais e acesso às configurações.

```
┌─────────────────────────────────────────────────────────────────┐
│  SISTEMA DE CONTROLE DE ROLOS - BOBINADEIRA    [Data/Hora]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │   ROLO 1      │  │   ROLO 2      │  │   ROLO 3      │       │
│  ├───────────────┤  ├───────────────┤  ├───────────────┤       │
│  │ Vel: 45.5 Hz  │  │ Vel: 42.8 Hz  │  │ Vel: 48.2 Hz  │       │
│  │ Trq: 65.2 %   │  │ Trq: 58.9 %   │  │ Trq: 72.3 %   │       │
│  │ Cor: 12.4 A   │  │ Cor: 11.8 A   │  │ Cor: 13.6 A   │       │
│  │               │  │               │  │               │       │
│  │ Status: ● OK  │  │ Status: ● OK  │  │ Status: ● OK  │       │
│  │               │  │               │  │               │       │
│  │  [Configurar] │  │  [Configurar] │  │  [Configurar] │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ SISTEMA                                                  │   │
│  │ ● Comunicação Modbus: OK                                 │   │
│  │ ● Alarmes Ativos: 0                                      │   │
│  │                                                          │   │
│  │ [Ver Alarmes] [Diagnóstico] [Configurações Globais]     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Elementos**:

- 3 painéis com dados em tempo real de cada rolo
- Indicadores de status por rolo
- Botões de navegação para telas detalhadas
- Área de status geral do sistema

---

### 2. Tela de Configuração Individual (Rolo X)

**Função**: Ajuste de parâmetros e monitoramento detalhado de um rolo.

```
┌─────────────────────────────────────────────────────────────────┐
│  CONFIGURAÇÃO - ROLO 1                          [← Voltar]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SETPOINTS (Valores de Configuração):                           │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                                                          │   │
│  │  Velocidade Máxima:  [  60.0  ] Hz                       │   │
│  │                      [- 0.1 -] [+ 0.1 +]                 │   │
│  │                      Faixa: 0.0 - 100.0 Hz               │   │
│  │                                                          │   │
│  │  Velocidade Mínima:  [   0.0  ] Hz                       │   │
│  │                      [- 0.1 -] [+ 0.1 +]                 │   │
│  │                      Faixa: 0.0 - 100.0 Hz               │   │
│  │                                                          │   │
│  │  Torque Máximo:      [ 100.0  ] %                        │   │
│  │                      [- 1.0 -] [+ 1.0 +]                 │   │
│  │                      Faixa: 0.0 - 200.0 %                │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  [ APLICAR MUDANÇAS ]  [ CANCELAR ]                             │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  MONITORAMENTO (Valores Atuais - Atualização: 10s):             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Velocidade Atual:    45.5 Hz                            │   │
│  │  Torque Atual:        65.2 %                             │   │
│  │  Corrente de Saída:   12.4 A                             │   │
│  │  Parâmetro P0409:     1234                               │   │
│  │  Parâmetro P0410:     5678                               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  CONTROLE E STATUS:                                             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Drive:           [●] LIGADO   [ ] DESLIGADO             │   │
│  │  Comunicação:     [●] OK       [ ] FALHA                 │   │
│  │  Erro Escrita:    [ ] OK       [ ] ERRO                  │   │
│  │  Erro Leitura:    [ ] OK       [ ] ERRO                  │   │
│  │  Alarme Vel/Trq:  [●] OK       [ ] ALARME                │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Elementos**:

- Campos numéricos editáveis com botões +/-
- Indicação de faixas válidas
- Botões "Aplicar" e "Cancelar"
- Display de valores atuais (não editáveis)
- Indicadores LED para status
- Botão toggle para habilitar/desabilitar drive

---

### 3. Tela de Alarmes e Diagnóstico

**Função**: Visualizar todos os alarmes e status de comunicação.

```
┌─────────────────────────────────────────────────────────────────┐
│  ALARMES E DIAGNÓSTICO                          [← Voltar]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ROLO 1                                                  │    │
│  │ ├─ Comunicação Modbus:    [●] OK                        │    │
│  │ ├─ Alarme Vel/Torque:     [●] Inativo                   │    │
│  │ ├─ Erro Escrita Params:   [●] Sem Erro                  │    │
│  │ ├─ Erro Leitura Params:   [●] Sem Erro                  │    │
│  │ └─ Drive Habilitado:      [●] Sim                       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ROLO 2                                                  │    │
│  │ ├─ Comunicação Modbus:    [●] OK                        │    │
│  │ ├─ Alarme Vel/Torque:     [●] Inativo                   │    │
│  │ ├─ Erro Escrita Params:   [●] Sem Erro                  │    │
│  │ ├─ Erro Leitura Params:   [●] Sem Erro                  │    │
│  │ └─ Drive Habilitado:      [●] Sim                       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ROLO 3                                                  │    │
│  │ ├─ Comunicação Modbus:    [●] OK                        │    │
│  │ ├─ Alarme Vel/Torque:     [!] ATIVO                     │    │
│  │ │   → Velocidade muito baixa para o torque aplicado     │    │
│  │ │      (Vel: 15.2 Hz, Trq: 85.3%, Esperado: >42.7 Hz)   │    │
│  │ ├─ Erro Escrita Params:   [●] Sem Erro                  │    │
│  │ ├─ Erro Leitura Params:   [●] Sem Erro                  │    │
│  │ └─ Drive Habilitado:      [●] Sim                       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ HISTÓRICO DE ALARMES (Últimos 10)                       │    │
│  │ 10:45:32 - Rolo 3 - Alarme Vel/Torque ATIVO             │    │
│  │ 09:23:15 - Rolo 2 - Erro Leitura (recuperado)           │    │
│  │ 08:12:45 - Sistema - Comunicação restabelecida          │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  [ RECONHECER ALARMES ]  [ LIMPAR HISTÓRICO ]                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Elementos**:

- Status detalhado de cada rolo
- Descrição de alarmes ativos
- Histórico de eventos
- Botões para reconhecimento de alarmes

---

### 4. Tela de Configurações Globais

**Função**: Parâmetros que afetam todo o sistema.

```
┌─────────────────────────────────────────────────────────────────┐
│  CONFIGURAÇÕES GLOBAIS DO SISTEMA               [← Voltar]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LIMITES DE SEGURANÇA:                                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Velocidade Máxima Global:    100.0 Hz (fixo)            │   │
│  │  Velocidade Mínima Global:      0.0 Hz (fixo)            │   │
│  │  Torque Máximo Global:        200.0 % (fixo)             │   │
│  │  Torque Mínimo Global:          0.0 % (fixo)             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  PARÂMETROS DE ALARME:                                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Razão Vel/Torque:      0.5 Hz/% (SPEED_TORQUE_RATIO)    │   │
│  │  Limiar Torque:        20.0 %                            │   │
│  │  Atraso Alarme:          5 seg                           │   │
│  │  Tempo Recuperação:     30 seg                           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  COMUNICAÇÃO:                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Protocolo:              Modbus RTU                       │   │
│  │  Nó Rolo 1:              1                                │   │
│  │  Nó Rolo 2:              2                                │   │
│  │  Nó Rolo 3:              3                                │   │
│  │  Taxa Atualização:       10 segundos                      │   │
│  │  Máximo de Retries:      3 tentativas                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  INFORMAÇÕES DO SISTEMA:                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Versão do Programa:     2.2                              │   │
│  │  CLP:                    Allen Bradley Micro850          │   │
│  │  IHM:                    PanelView 800                    │   │
│  │  Última Atualização:     Outubro 2025                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Elementos**:

- Informações somente leitura sobre limites e configurações
- Dados de sistema para referência do operador

---

## Configuração de Comunicação

### Configuração no FactoryTalk View Studio

1. **Criar Tag Database**:

   - Conectar ao controlador Micro850
   - Importar tags automaticamente ou criar manualmente
   - Verificar tipos de dados (REAL, BOOL)

2. **Configuração de Atualização**:

   - Tags de monitoramento: Atualização a cada 1-2 segundos (para display responsivo)
   - Tags de entrada: Atualização sob demanda (quando operador altera)
   - Tags de status: Atualização a cada 1 segundo

3. **Alarmes**:
   - Configurar alarmes para variáveis BOOL de erro
   - Prioridades:
     - Alta: `CommunicationOK` = FALSE
     - Média: `WriteError`, `ReadError`
     - Baixa: `SpeedTorqueAlarm`

---

## Validações e Limites

### Validação no IHM

Embora o CLP faça validação final, implementar validação no IHM melhora a experiência do usuário:

#### Velocidade (SpeedMax, SpeedMin)

```
Mínimo: 0.0 Hz
Máximo: 100.0 Hz
Regra: SpeedMin ≤ SpeedMax
```

#### Torque (TorqueMax)

```
Mínimo: 0.0 %
Máximo: 200.0 %
```

### Mensagens de Erro Sugeridas

| Condição            | Mensagem                                                 |
| ------------------- | -------------------------------------------------------- |
| SpeedMax > 100.0    | "Velocidade máxima não pode exceder 100.0 Hz"            |
| SpeedMin > SpeedMax | "Velocidade mínima deve ser menor que velocidade máxima" |
| TorqueMax > 200.0   | "Torque máximo não pode exceder 200.0%"                  |
| Valor negativo      | "Valores negativos não são permitidos"                   |

### Formatação de Displays

#### Valores REAL

- Velocidade: `##0.0` (ex: 45.5)
- Torque: `##0.0` (ex: 65.2)
- Corrente: `##0.0` (ex: 12.4)
- P0409/P0410: `####0` (ex: 1234)

#### Cores Sugeridas

- **Verde**: Normal/OK
- **Amarelo**: Aviso
- **Vermelho**: Erro/Alarme
- **Cinza**: Inativo/Desabilitado
- **Azul**: Informação

---

## Checklist de Desenvolvimento

### Fase 1: Criação de Tags

- [ ] Criar 9 tags REAL de entrada (SpeedMax, SpeedMin, TorqueMax × 3 rolos)
- [ ] Criar 15 tags REAL de monitoramento (5 × 3 rolos)
- [ ] Criar 15 tags BOOL de status/alarme (5 × 3 rolos)
- [ ] Criar 6 tags BOOL de controle (2 × 3 rolos)
- [ ] Verificar comunicação com CLP

### Fase 2: Tela Principal

- [ ] Criar layout com 3 painéis de rolos
- [ ] Vincular displays numéricos
- [ ] Adicionar indicadores de status
- [ ] Criar botões de navegação

### Fase 3: Telas de Configuração (3x)

- [ ] Criar campos de entrada numérica
- [ ] Implementar botões +/-
- [ ] Adicionar validação de entrada
- [ ] Vincular botão "Aplicar" ao WriteTrigger
- [ ] Adicionar displays de monitoramento
- [ ] Criar controles toggle para EnableDrive

### Fase 4: Tela de Alarmes

- [ ] Criar displays de status por rolo
- [ ] Adicionar descrições de alarmes
- [ ] Implementar histórico de eventos (se possível)
- [ ] Adicionar botões de reconhecimento

### Fase 5: Tela de Configurações Globais

- [ ] Criar displays informativos
- [ ] Adicionar dados de sistema

### Fase 6: Testes

- [ ] Testar leitura de todas as variáveis
- [ ] Testar escrita de setpoints
- [ ] Verificar alarmes
- [ ] Testar botões de controle
- [ ] Validar navegação entre telas
- [ ] Verificar atualização de dados

---

## Notas Finais

### Considerações de Segurança

1. **Acesso Restrito**: Considerar níveis de acesso (operador/engenheiro)
2. **Confirmação**: Adicionar confirmação antes de aplicar mudanças críticas
3. **Log de Mudanças**: Registrar quem/quando alterou setpoints

### Performance

- Taxa de atualização de 10 segundos no CLP é adequada para processo
- IHM pode atualizar display mais frequentemente (1-2s) para responsividade
- Limitar número de tags em scan contínuo para otimizar rede

### Expansão Futura

Variáveis já preparadas para expansão:

- `P0409Scaled_roloX`: Pode ser temperatura, tensão DC, etc.
- `P0410Scaled_roloX`: Pode ser potência, estado, etc.

Consultar `CFW500_Modbus_Mapping.md` e `CFW500_Mapeamento_Modbus_Portugues.md` para adicionar mais parâmetros conforme necessidade.

---

_Documento versão: 1.0_
_Data: Outubro 2025_
_Projeto: Sistema de Controle de Bobinadeira - CFW500_
_Para uso com: Allen Bradley PanelView 800 + Micro850_
