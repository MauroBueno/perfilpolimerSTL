# Monitoramento Velocidade vs Torque - CFW500

# Sistema de Alarme para Detecção de Problemas Mecânicos

## Visão Geral

Este sistema implementa um monitoramento inteligente que detecta quando a velocidade do motor está inadequada em relação ao torque aplicado. Isso ajuda a identificar problemas como:

- Motor travado ou com torque insuficiente
- Chapa presa no processo de enrolamento
- Problemas mecânicos que impedem o movimento adequado
- Ajustes incorretos de torque máximo

## Lógica de Funcionamento

### Condições de Ativação

- **Torque > 20%**: Só monitora quando há torque significativo aplicado
- **Drive Habilitado**: Só funciona quando o drive está em operação
- **Velocidade Baixa**: Quando velocidade atual < velocidade esperada

### Cálculo da Velocidade Esperada

```
Velocidade_Esperada = Torque_Atual(%) × Fator_Relacao
```

Onde:

- **Fator_Relacao** = 0.5 (configurável via SPEED_TORQUE_RATIO)
- Exemplo: Torque = 80% → Velocidade esperada = 40 Hz

### Exemplo Prático

- Torque aplicado: 80%
- Velocidade esperada: 80% × 0.5 = 40 Hz
- Se velocidade atual < 40 Hz → ALARME ativado

## Parâmetros Configuráveis

### Constantes Globais

- **SPEED_TORQUE_RATIO**: Relação velocidade/torque (padrão: 0.5)
- **SPEED_TORQUE_ALARM_DELAY**: Atraso para ativação do alarme (padrão: 5s)

### Ajuste do Fator de Relação

- Valores típicos: 0.3 a 0.8
- Depende das características do processo e equipamento
- Valores mais baixos = alarme mais sensível
- Valores mais altos = alarme menos sensível

## Variáveis de Monitoramento

### Flags de Alarme

- **SpeedTorqueAlarm_rolo1**: TRUE quando alarme ativo no rolo 1
- **SpeedTorqueAlarm_rolo2**: TRUE quando alarme ativo no rolo 2
- **SpeedTorqueAlarm_rolo3**: TRUE quando alarme ativo no rolo 3

### Timers de Debouncing

- **SpeedTorqueAlarmTimer_roloX**: Timer para evitar alarmes falsos
- Atraso de 5 segundos antes de ativar alarme

## Implementação no HMI

### Indicadores Visuais

- Luz vermelha/lampada para cada rolo quando alarme ativo
- Mensagem de texto: "VELOCIDADE BAIXA - VERIFICAR TORQUE/OBSTRUÇÃO"
- Possibilidade de reset manual do alarme

### Ações Recomendadas no Alarme

1. **Parar o processo** imediatamente
2. **Verificar obstruções** mecânicas
3. **Ajustar torque máximo** se necessário
4. **Verificar integridade** da chapa/material
5. **Reset manual** após correção

## Diagnóstico e Manutenção

### Verificação Periódica

- Monitorar frequência de alarmes
- Ajustar SPEED_TORQUE_RATIO conforme necessário
- Verificar se alarmes são falsos positivos

### Logs Recomendados

- Timestamp dos alarmes
- Valores de torque e velocidade no momento do alarme
- Duração do alarme
- Ações tomadas pelo operador

## Segurança

- **ALARME NÃO PARA O DRIVE AUTOMATICAMENTE** - decisão do operador
- Sistema apenas **AVISA** sobre condição anormal
- Operador deve avaliar situação e tomar ação apropriada

## Configuração no CCW

- Declarar constantes globais SPEED_TORQUE_RATIO e SPEED_TORQUE_ALARM_DELAY
- Declarar variáveis SpeedTorqueAlarm_roloX e SpeedTorqueAlarmTimer_roloX em cada POU
- Integrar lógica no código ST conforme implementado
