# Lista de TAGS HMI - Correlação com Variáveis Micro850
# Sistema de Controle CFW500 - Comunicação Modbus RTU
# Data: Outubro 2025

## Visão Geral
Esta lista contém as variáveis que devem receber valores do IHM (PV800), com os nomes sugeridos para o IHM
e sua correlação direta com as variáveis no controlador Micro850.

## Variáveis de Setpoint por Rolo

### Rolo 1 (Node 1)
| Tag HMI Sugerido | Variável Micro850 | Tipo | Unidade | Descrição | Faixa Válida |
|------------------|-------------------|------|---------|-----------|-------------|
| TORQUE_MAX_ROLO1 | TorqueMax_rolo1 | UINT | 0.1% | Torque máximo do rolo 1 | 0-2000 (0.0-200.0%) |
| SPEED_MAX_ROLO1 | SpeedMax_rolo1 | UINT | 0.1 Hz | Velocidade máxima do rolo 1 | 0-10000 (0.0-100.0 Hz) |
| SPEED_MIN_ROLO1 | SpeedMin_rolo1 | UINT | 0.1 Hz | Velocidade mínima do rolo 1 | 0-10000 (0.0-100.0 Hz) |

### Rolo 2 (Node 2)
| Tag HMI Sugerido | Variável Micro850 | Tipo | Unidade | Descrição | Faixa Válida |
|------------------|-------------------|------|---------|-----------|-------------|
| TORQUE_MAX_ROLO2 | TorqueMax_rolo2 | UINT | 0.1% | Torque máximo do rolo 2 | 0-2000 (0.0-200.0%) |
| SPEED_MAX_ROLO2 | SpeedMax_rolo2 | UINT | 0.1 Hz | Velocidade máxima do rolo 2 | 0-10000 (0.0-100.0 Hz) |
| SPEED_MIN_ROLO2 | SpeedMin_rolo2 | UINT | 0.1 Hz | Velocidade mínima do rolo 2 | 0-10000 (0.0-100.0 Hz) |

### Rolo 3 (Node 3)
| Tag HMI Sugerido | Variável Micro850 | Tipo | Unidade | Descrição | Faixa Válida |
|------------------|-------------------|------|---------|-----------|-------------|
| TORQUE_MAX_ROLO3 | TorqueMax_rolo3 | UINT | 0.1% | Torque máximo do rolo 3 | 0-2000 (0.0-200.0%) |
| SPEED_MAX_ROLO3 | SpeedMax_rolo3 | UINT | 0.1 Hz | Velocidade máxima do rolo 3 | 0-10000 (0.0-100.0 Hz) |
| SPEED_MIN_ROLO3 | SpeedMin_rolo3 | UINT | 0.1 Hz | Velocidade mínima do rolo 3 | 0-10000 (0.0-100.0 Hz) |

## Variáveis de Controle por Botão

### Rolo 1 (Node 1)
| Tag HMI Sugerido | Variável Micro850 | Tipo | Descrição | Valores |
|------------------|-------------------|------|-----------|---------|
| LIGA_ROLO1 | EnableDrive_rolo1 | BOOL | Controle de habilitação do drive | FALSE=Desligado, TRUE=Ligado |
| ENABLE_P0498_ROLO1 | P0498Set_rolo1 | UINT | Controle P0498 (habilitar/desabilitar função) | 0=Desabilitado, 1=Habilitado |
| WRITE_TRIGGER_ROLO1 | WriteTrigger_rolo1 | BOOL | Gatilho manual para escrita de parâmetros | FALSE=Normal, TRUE=Forçar escrita |

### Rolo 2 (Node 2)
| Tag HMI Sugerido | Variável Micro850 | Tipo | Descrição | Valores |
|------------------|-------------------|------|-----------|---------|
| LIGA_ROLO2 | EnableDrive_rolo2 | BOOL | Controle de habilitação do drive | FALSE=Desligado, TRUE=Ligado |
| ENABLE_P0498_ROLO2 | P0498Set_rolo2 | UINT | Controle P0498 (habilitar/desabilitar função) | 0=Desabilitado, 1=Habilitado |
| WRITE_TRIGGER_ROLO2 | WriteTrigger_rolo2 | BOOL | Gatilho manual para escrita de parâmetros | FALSE=Normal, TRUE=Forçar escrita |

### Rolo 3 (Node 3)
| Tag HMI Sugerido | Variável Micro850 | Tipo | Descrição | Valores |
|------------------|-------------------|------|-----------|---------|
| LIGA_ROLO3 | EnableDrive_rolo3 | BOOL | Controle de habilitação do drive | FALSE=Desligado, TRUE=Ligado |
| ENABLE_P0498_ROLO3 | P0498Set_rolo3 | UINT | Controle P0498 (habilitar/desabilitar função) | 0=Desabilitado, 1=Habilitado |
| WRITE_TRIGGER_ROLO3 | WriteTrigger_rolo3 | BOOL | Gatilho manual para escrita de parâmetros | FALSE=Normal, TRUE=Forçar escrita |

## Detalhes Técnicos

### Validação e Limites
- **Torque**: Limitado entre TORQUE_MIN_LIMIT (0.0%) e TORQUE_MAX_LIMIT (200.0%)
- **Velocidade**: Limitado entre SPEED_MIN_LIMIT (0.0 Hz) e SPEED_MAX_LIMIT (100.0 Hz)
- **Validação**: Min ≤ Max para velocidades (SpeedMin ≤ SpeedMax)

### Conversão para Unidades do Inversor
- Torque: Valor em % × 10 (ex: 150.0% → 1500 UINT)
- Velocidade: Valor em Hz × 100 (ex: 60.0 Hz → 6000 UINT)

### Comportamento do Sistema
1. O IHM escreve diretamente nas variáveis globais do Micro850
2. O código ST detecta mudanças e valida os valores
3. Valores validados são convertidos para unidades do CFW500
4. Parâmetros são escritos no inversor via Modbus RTU
5. Sistema verifica periodicamente se os valores foram aplicados corretamente

### Comportamento dos Botões e Gatilhos
- **LIGA_ROLOX**: Controle principal de habilitação do drive - deve ser integrado com lógica Ladder para controle de partida/parada
- **P0498 (Enable/Disable)**: Controla uma função específica do CFW500. Quando alterado, dispara automaticamente a escrita no inversor
- **Write Trigger**: Gatilho manual para forçar reescrita de todos os parâmetros quando necessário (ex: após falha de comunicação)
- **Auto-reset**: Os gatilhos WriteTrigger são automaticamente resetados após conclusão da operação

### Mapeamento Modbus (Referência)
- P0134: Velocidade Máxima (Speed Max)
- P0133: Velocidade Mínima (Speed Min)
- P0169: Torque Máximo (Torque Max)
- P0170: Torque Mínimo (Torque Min) - Fixo em 0
- P0498: Controle de função (Enable/Disable)

### Configuração no Connected Components Workbench (CCW)
- **Escopo**: 
  - Setpoints (TorqueMax, SpeedMax, SpeedMin): Global Variables
  - Controles por botão (P0498Set, WriteTrigger): Variáveis locais do POU
  - Constantes globais (SPEED_TORQUE_RATIO, SPEED_TORQUE_ALARM_DELAY): Global Variables
- **Tipo de Dados**: UINT para setpoints, BOOL para gatilhos, REAL para constantes
- **Inicialização**: Conforme valores padrão do sistema
- **Acesso HMI**: Leitura/Escrita via tags do PV800

## Notas para Implementação no PV800
1. Criar tags no PV800 com os nomes sugeridos acima
2. Configurar comunicação Modbus TCP/IP com o Micro850
3. Mapear endereços das variáveis globais (setpoints) e locais do POU (controles)
4. Implementar botões liga/desliga (toggle) para LIGA_ROLOX (controle principal do drive)
5. Implementar botões/momentary switches para os gatilhos WriteTrigger
6. Implementar botões toggle/on-off para controle P0498
7. Implementar indicadores visuais (luzes/ícones) para alarmes SpeedTorqueAlarm_roloX
8. Implementar validação no IHM (opcional, já existe no PLC)
9. Considerar interface amigável com unidades em % e Hz (não valores UINT)

## Monitoramento e Diagnóstico
As seguintes variáveis podem ser lidas no IHM para monitoramento:
- CommunicationOK_roloX: Status de comunicação Modbus
- WriteError_roloX: Erro de escrita
- ReadError_roloX: Erro de leitura
- SpeedTorqueAlarm_roloX: Alarme velocidade vs torque (TRUE=alarme ativo)
- OutputFreqScaled_roloX: Frequência de saída atual (Hz)
- TorquePercentScaled_roloX: Torque atual (%)
- OutputCurrentScaled_roloX: Corrente de saída (A)

## Sistema de Alarmes

### Alarme Velocidade vs Torque
- **Descrição**: Detecta quando a velocidade está muito baixa em relação ao torque aplicado
- **Lógica**: Ativado quando torque > 20% E velocidade < (torque% × 0.5) E drive habilitado
- **Objetivo**: Identificar motor travado, torque insuficiente ou problemas mecânicos
- **Atraso**: 5 segundos para evitar alarmes falsos durante aceleração/desaceleração
- **Reset**: Automático quando velocidade retorna ao nível adequado ou drive desabilitado

## Integração com Lógica Ladder
- **EnableDrive_roloX**: Deve ser integrada com lógica Ladder para controle efetivo de partida/parada do drive
- **Intertravamento**: Implementar lógica de segurança para evitar operações simultâneas conflitantes
- **Sequenciamento**: Considerar ordem de partida e parada dos rolos conforme processo produtivo