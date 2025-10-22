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

| Parâmetro | Registro | Descrição           | Escala | Unidades | Tipo de Dados | Taxa de Atualização |
| --------- | -------- | ------------------- | ------ | -------- | ------------- | ------------------- |
| P0002     | 2        | Frequência de Saída | ×0.1   | Hz       | UINT          | 1 segundo           |
| P0003     | 3        | Corrente de Saída   | ×0.1   | A        | UINT          | 1 segundo           |
| P0009     | 9        | Torque do Motor     | ×0.1   | %        | UINT          | 1 segundo           |

### Parâmetros de Controle (Leitura/Escrita)

| Parâmetro | Registro | Descrição                       | Escala | Unidades | Tipo de Dados | Padrão | Faixa       |
| --------- | -------- | ------------------------------- | ------ | -------- | ------------- | ------ | ----------- |
| P0100     | 100      | Tipo de Controle                | 1:1    | -        | UINT          | 2      | 0-5         |
| P0133     | 133      | Referência de Velocidade Mínima | ×0.01  | Hz       | UINT          | 0      | 0-VelMax    |
| P0134     | 134      | Referência de Velocidade Máxima | ×0.01  | Hz       | UINT          | 6000   | VelMin-6500 |
| P0169     | 169      | Limite Máximo de Torque         | ×0.1   | %        | UINT          | 1500   | 0-2000      |
| P0170     | 170      | Limite Mínimo de Torque         | ×0.1   | %        | UINT          | 0      | -2000-0     |
| P0498     | 498      | Salvar Parâmetro                | 0/1    | -        | UINT          | 0      | 0-1         |

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

## Detalhes do Protocolo de Comunicação

### Operações de Leitura

- **Código de Função**: 3 (Ler Registradores de Retenção)
- **Registro Único**: ElementCnt = 1
- **Múltiplos Registros**: ElementCnt = 2 (para parâmetros consecutivos)

### Operações de Escrita

- **Código de Função**: 6 (Predefinir Registro Único) para parâmetros únicos
- **Código de Função**: 16 (Predefinir Múltiplos Registradores) para parâmetros consecutivos
- **ElementCnt**: Número de registradores a escrever

## Tratamento de Erros

- **Timeout**: Sistema tenta novamente operações com falha até 3 vezes
- **Flags de Erro**: Rastreamento separado para erros de leitura/escrita/verificação
- **Recuperação**: Limpeza automática de erros após 30 segundos de comunicação bem-sucedida

## Uso Específico da Aplicação

### Lógica de Controle dos Rolos

Cada rolo (rolo1, rolo2, rolo3) implementa lógica de controle idêntica:

1. **Monitoramento Periódico**: Lê P0002, P0003, P0009 a cada 1 segundo
2. **Validação de Parâmetros**: Entradas HMI limitadas a faixas seguras antes da escala
3. **Detecção de Mudanças**: Só escreve parâmetros quando valores HMI diferem dos valores do inversor
4. **Verificação**: Verifica parâmetros críticos a cada 10 segundos e força correção se necessário

### Limites de Segurança

- **Faixa de Velocidade**: 0.0 - 100.0 Hz (configurável via SPEED_MAX_LIMIT)
- **Faixa de Torque**: 0.0 - 200.0% (configurável via TORQUE_MAX_LIMIT)
- **Inter-Travamento**: VelMin ≤ VelMax imposto automaticamente

## Solução de Problemas

### Problemas Comuns

1. **Timeout de Comunicação**: Verificar fiação Modbus, taxa de transmissão e endereços de nó
2. **Parâmetro Não Atualizando**: Verificar se valor HMI difere do valor atual do inversor
3. **Valores Inválidos**: Verificar cálculos de escala e faixas de entrada HMI

### Parâmetros de Diagnóstico

- Monitorar `CommunicationOK_roloX` para status geral de comunicação
- Verificar contadores de tentativa (`WriteRetryCount_roloX`, etc.) para qualidade da comunicação
- Revisar flags de erro para modos específicos de falha

## Referências

- Manual do Usuário CFW500 - Comunicação Modbus RTU
- Controlador Allen Bradley Micro850 - Configuração Mestre Modbus
- Diretrizes de Programação IEC 61131-3 Structured Text

---

_Versão do Documento: 1.0_
_Última Atualização: 22 de outubro de 2025_
_Sistema: Máquina de Perfilamento de Polímeros - Controle CFW500_</content>
<parameter name="filePath">c:\Users\mauro.bueno\Downloads\PerfilBobinadeira\CFW500_Mapeamento_Modbus_Portugues.md
