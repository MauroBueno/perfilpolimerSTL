# Documentação de Mapeamento de Registros Modbus RTU CFW500

## Visão Geral

Este documento fornece mapeamento detalhado dos parâmetros do inversor CFW500 utilizados no sistema de controle da máquina de perfilamento de polímeros. Todos os registros são acessados via protocolo Modbus RTU com a seguinte configuração:

- **Protocolo**: Modbus RTU
- **Taxa de Transmissão**: Configurada nas configurações de canal do Micro850
- **Paridade**: Nenhuma (típico para aplicações industriais)
- **Bits de Dados**: 8
- **Bits de Parada**: 1
- **Endereços de Nó**: 1, 2, 3 (um por rolo/inversor)

## Convenção de Endereçamento de Registros

- Todos os endereços são registradores de retenção (código de função 3 para leitura, 16 para escrita)
- Parâmetro CFW500 PXXXX mapeia para registro Modbus XXXX
- Exemplo: P0009 (Torque) = Registro 9

## Tabela de Mapeamento de Parâmetros

### Parâmetros de Monitoramento (Somente Leitura)

| Parâmetro | Registro | Descrição               | Escala   | Unidades | Tipo de Dados | Taxa de Atualização |
| --------- | -------- | ----------------------- | -------- | -------- | ------------- | ------------------- |
| P0002     | 2        | Frequência de Saída     | ×0.1     | Hz       | UINT          | 10 segundos         |
| P0003     | 3        | Corrente de Saída       | ×0.1     | A        | UINT          | 10 segundos         |
| P0009     | 9        | Torque do Motor         | ×0.1     | %        | UINT          | 10 segundos         |
| P0409     | 409      | Parâmetro Adicional 1\* | Variável | Variável | UINT          | 10 segundos         |
| P0410     | 410      | Parâmetro Adicional 2\* | Variável | Variável | UINT          | 10 segundos         |

**Nota sobre P0409 e P0410**: A função exata destes parâmetros depende da configuração e versão de firmware do CFW500. Consulte o manual específico do seu inversor para:

- Função e descrição detalhada
- Fator de escala apropriado
- Faixa de valores válidos
- Unidades de medida

Possíveis usos comuns:

- Temperatura do inversor
- Tensão do barramento CC
- Potência ativa/reativa
- Estados operacionais adicionais

### Parâmetros de Controle (Leitura/Escrita)

| Parâmetro | Registro | Descrição                       | Escala | Unidades | Tipo de Dados | Padrão | Faixa       |
| --------- | -------- | ------------------------------- | ------ | -------- | ------------- | ------ | ----------- |
| P0100     | 100      | Tipo de Controle                | 1:1    | -        | UINT          | 2      | 0-5         |
| P0133     | 133      | Referência de Velocidade Mínima | ×0.01  | Hz       | UINT          | 0      | 0-VelMax    |
| P0134     | 134      | Referência de Velocidade Máxima | ×0.01  | Hz       | UINT          | 6000   | VelMin-6500 |
| P0169     | 169      | Limite Máximo de Torque         | ×0.1   | %        | UINT          | 1500   | 0-2000      |
| P0170     | 170      | Limite Mínimo de Torque         | ×0.1   | %        | UINT          | 0      | -2000-0     |
| P0498     | 498      | Salvar Parâmetro                | 0/1    | -        | UINT          | 0      | 0-1         |

### Parâmetros Adicionais Úteis (Não Implementados Atualmente)

Os seguintes parâmetros podem ser úteis para expansão futura do sistema:

| Parâmetro | Registro | Descrição               | Escala | Unidades | Acesso          |
| --------- | -------- | ----------------------- | ------ | -------- | --------------- |
| P0001     | 1        | Velocidade do Motor     | ×1     | RPM      | Somente Leitura |
| P0004     | 4        | Tensão de Saída         | ×1     | V        | Somente Leitura |
| P0005     | 5        | Frequência de Entrada   | ×0.01  | Hz       | Somente Leitura |
| P0006     | 6        | Tensão DC Link          | ×1     | V        | Somente Leitura |
| P0007     | 7        | Temperatura do Inversor | ×1     | °C       | Somente Leitura |
| P0011     | 11       | Estado do Inversor      | Bitmap | -        | Somente Leitura |
| P0220     | 220      | Tempo de Aceleração     | ×0.1   | s        | Leitura/Escrita |
| P0221     | 221      | Tempo de Desaceleração  | ×0.1   | s        | Leitura/Escrita |

## Valores do Tipo de Controle (P0100)

- **0**: Controle V/F
- **1**: V/F com Encoder
- **2**: Vetorial Sensorless (Utilizado nesta aplicação)
- **3**: Vetorial com Encoder
- **4**: V/F Quadrático
- **5**: V/F com Encoder Quadrático

## Detalhes de Escala

### Parâmetros de Frequência (P0133, P0134)

- **Entrada HMI**: Número real em Hz (ex.: 60.0 Hz)
- **Escala**: Multiplicar por 100 para obter UINT (ex.: 60.0 × 100 = 6000)
- **Armazenamento CFW500**: UINT representando unidades de 0.01 Hz
- **Fórmula**: `Valor_Registro = Valor_HMI × 100`

### Parâmetros de Torque (P0169, P0170)

- **Entrada HMI**: Número real em % (ex.: 150.0%)
- **Escala**: Multiplicar por 10 para obter UINT (ex.: 150.0 × 10 = 1500)
- **Armazenamento CFW500**: UINT representando unidades de 0.1%
- **Fórmula**: `Valor_Registro = Valor_HMI × 10`

### Parâmetros de Monitoramento (P0002, P0003, P0009)

- **Saída CFW500**: UINT em unidades escaladas
- **Exibição HMI**: Dividir por 10 para valores reais
- **Fórmula**: `Valor_Exibição = Valor_Registro ÷ 10`

### Parâmetros P0409 e P0410

- **Armazenamento**: Valores brutos (UINT) e escalados (REAL) mantidos
- **Escala**: Depende da configuração específica - consulte manual do CFW500
- **Uso no Código**:
  - `P0409_roloX`: Valor bruto do registro
  - `P0409Scaled_roloX`: Valor após conversão UINT_TO_REAL (escala a ser aplicada conforme necessário)
  - `P0410_roloX`: Valor bruto do registro
  - `P0410Scaled_roloX`: Valor após conversão UINT_TO_REAL (escala a ser aplicada conforme necessário)

## Detalhes do Protocolo de Comunicação

### Operações de Leitura

- **Código de Função**: 3 (Ler Registradores de Retenção)
- **Registro Único**: ElementCnt = 1
- **Múltiplos Registros**: ElementCnt = 2 (para parâmetros consecutivos)

**Ciclos de Leitura Implementados**:

1. **Ciclo de Monitoramento Principal** (10s): P0009 → P0002/P0003
2. **Ciclo P0409/P0410** (10s): P0409/P0410 (leitura consecutiva)
3. **Ciclo de Verificação** (10s): P0100 → P0134/P0133 → P0169/P0170

### Operações de Escrita

- **Código de Função**: 6 (Predefinir Registro Único) para parâmetros únicos
- **Código de Função**: 16 (Predefinir Múltiplos Registradores) para parâmetros consecutivos
- **ElementCnt**: Número de registradores a escrever

## Tratamento de Erros

- **Timeout**: Sistema tenta novamente operações com falha até 3 vezes
- **Flags de Erro**: Rastreamento separado para erros de leitura/escrita/verificação
- **Contadores de Retry Independentes**:
  - `WriteRetryCount_roloX`
  - `ReadRetryCount_roloX`
  - `ReadRetryCount_P0409_P0410_roloX`
  - `VerificationRetryCount_roloX`
- **Recuperação**: Limpeza automática de erros após 30 segundos de comunicação bem-sucedida

## Uso Específico da Aplicação

### Lógica de Controle dos Rolos

Cada rolo (rolo1, rolo2, rolo3) implementa lógica de controle idêntica:

1. **Monitoramento Periódico**:
   - Lê P0002, P0003, P0009 a cada 10 segundos
   - Lê P0409, P0410 a cada 10 segundos (ciclo separado)
2. **Validação de Parâmetros**: Entradas HMI limitadas a faixas seguras antes da escala
3. **Detecção de Mudanças**: Só escreve parâmetros quando valores HMI diferem dos valores do inversor
4. **Verificação**: Verifica parâmetros críticos a cada 10 segundos e força correção se necessário

### Limites de Segurança

- **Faixa de Velocidade**: 0.0 - 100.0 Hz (configurável via SPEED_MAX_LIMIT)
- **Faixa de Torque**: 0.0 - 200.0% (configurável via TORQUE_MAX_LIMIT)
- **Inter-Travamento**: VelMin ≤ VelMax imposto automaticamente

### Alarme de Velocidade vs Torque

- **Condição**: `TorquePercentScaled > 20.0% AND OutputFreqScaled < (TorquePercentScaled × SPEED_TORQUE_RATIO)`
- **Limiar**: 20% de torque
- **Razão**: 0.5 Hz/% (configurável)
- **Atraso**: 5 segundos antes da ativação
- **Propósito**: Detectar travamento do motor ou potência insuficiente

## Arbitragem de Barramento Modbus

- **Flag Global**: `ModbusBusy` compartilhado entre todos os rolos
- **Propósito**: Previne operações Modbus simultâneas
- **Uso**: Verificado antes de cada operação de leitura/escrita
- **Liberação**: Após conclusão de cada operação

## Solução de Problemas

### Problemas Comuns

1. **Timeout de Comunicação**:
   - Verificar fiação Modbus e terminação
   - Confirmar taxa de transmissão e endereços de nó
   - Verificar se apenas um dispositivo usa Modbus por vez
2. **Parâmetro Não Atualizando**:
   - Verificar se P0498 = 1 (habilitado)
   - Confirmar que valor HMI difere do valor do inversor
   - Verificar se inversor não está em modo local
3. **Valores Inválidos**:
   - Verificar cálculos de escala
   - Confirmar faixas de entrada HMI
   - Validar conversões de tipo de dados (UINT ↔ REAL)
4. **P0409/P0410 com Valores Inesperados**:
   - Consultar manual específico do CFW500 para definição destes parâmetros
   - Verificar versão de firmware do inversor
   - Ajustar escala de acordo com a função real do parâmetro

### Parâmetros de Diagnóstico

- Monitorar `CommunicationOK_roloX` para status geral de comunicação
- Verificar contadores de tentativa para qualidade da comunicação
- Revisar flags de erro (`WriteError_roloX`, `ReadError_roloX`) para modos específicos de falha
- Observar tempo de recuperação de erros (30s após comunicação bem-sucedida)

## Expansão Futura

Para adicionar novos parâmetros ao sistema:

1. **Identificar Parâmetro**: Consultar manual do CFW500 para número e função
2. **Adicionar Variáveis**: Criar variáveis raw (UINT) e scaled (REAL)
3. **Criar MSG_MODBUS**: Instanciar novo bloco de função
4. **Adicionar ao Ciclo**: Integrar no ciclo de leitura apropriado
5. **Implementar Retry**: Adicionar contador de retry específico
6. **Atualizar HMI**: Criar telas de exibição/entrada conforme necessário

## Referências

- Manual do Usuário CFW500 - Comunicação Modbus RTU
- Manual de Parâmetros CFW500 (versão específica do firmware)
- Controlador Allen Bradley Micro850 - Configuração Mestre Modbus
- Diretrizes de Programação IEC 61131-3 Structured Text
- Especificação do Protocolo Modbus RTU

---

_Versão do Documento: 2.2_
_Última Atualização: Outubro de 2025_
_Sistema: Máquina de Perfilamento de Polímeros - Controle CFW500_
_Changelog: Adicionados P0409/P0410, lista de parâmetros úteis para expansão futura, detalhes de arbitragem de barramento_
