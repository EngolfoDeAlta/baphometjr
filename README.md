# Automated Pixel-Based Interaction System

Este projeto é um sistema de automação baseado em leitura de pixels e interação por simulação de dispositivos de entrada (mouse e teclado), com arquitetura desacoplada e suporte a drivers em modo kernel.

## Requisitos

Antes de começar, certifique-se de instalar os seguintes componentes:

* [Python 3.x](https://www.python.org/)
* [AutoHotkey v1.1](https://www.autohotkey.com/)

  > ⚠️ Observação: Vale considerar migração futura para a versão 2.0.
* [GRF Editor](https://rathena.org/board/files/file/2766-grf-editor/)
* [ACT Editor](https://rathena.org/board/files/file/3304-act-editor/)
* [Resource Hacker](https://resource-hacker.br.download.it/)
* [pyinterception](https://github.com/kennyhml/pyinterception)
* [Interception Driver](https://github.com/oblitum/Interception) --> Esse é um driver customizado, é meio chato de instalar e precisa reiniciar depois. Boa sorte 

## Passo a passo para uso

1. **Instalação e dependências**

   * Instale o Python.
   * Instale AutoHotkey v1.1.
   * Instale o Interception Driver.
   * Instale a lib `pyinterception` via pip:

     ```bash
     pip install pyinterception
     ```

2. **Modifique o AutoHotkey**

   * Use o Resource Hacker para alterar o nome de assinatura e identificadores do AutoHotkey para algo genérico.

3. **Substituição de arquivos**

   * Substitua o arquivo `.grf` original do jogo pelo fornecido em:
     `\res\grf\data-demo-1.grf`

4. **Inicialize o servidor de comandos**

   * Execute o script Python localizado em:

     ```
     python CommandCenter.py
     ```

5. **Abra o jogo**

   * Entre no mapa previamente configurado no `.grf`.

6. **Execute o script principal**

   * Rode o script `ahk\hunt.ahk` com privilégios de administrador.

## Como funciona

O sistema é baseado em **máquina de estados**. O fluxo é:

1. Busca por elementos visuais modificados (definidos no `.grf`)
2. Se não encontrados:

   * Move-se aleatoriamente entre quatro quadrantes
   * Garante que o próximo movimento nunca seja na direção oposta da anterior
3. Busca novamente
4. Quando encontrado:

   * Simula interação (ataque)
   * Verifica continuamente se a interação ainda está ocorrendo
   * Quando finalizada, inicia coleta de elementos no cenário (loot)
5. Repete o ciclo

## Arquitetura

* **Scripts AHK**: núcleo da automação; fazem leitura de pixel e lógica de estados.
* **Script Python (CommandCenter.py)**: cria servidor local que envia comandos para o driver customizado.
* **Driver de Interceptação**: permite simular HID (dispositivo de entrada) em nível de hardware.

> Este design evita completamente leitura ou escrita de memória ou pacotes de rede, tornando-o mais difícil de ser detectado.

## Importante

* Sempre execute os scripts AutoHotkey como **Administrador**
* **Não execute o jogo simultaneamente com o GRF Editor ou ACT Editor abertos**

## Limitações e Solução

Este projeto foi desenvolvido para funcionar em ambientes com anti-cheat de nível kernel, que bloqueiam entradas a nível de usuário. Com o driver customizado, é possível simular entradas como se fossem de um dispositivo físico, contornando essa limitação.

## Futuro

Nos próximos dias, estão previstos os seguintes aprimoramentos:

* Melhorias no script e substituição da `.grf` de mais mapas.
* Novo script AHK para monitorar a vida e utilizar poções automaticamente.
* Novo script Python para detectar situações críticas (morte, inventário cheio, desconexão) e enviar alerta via bot no Telegram.
